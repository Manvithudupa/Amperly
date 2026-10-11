package com.amperly.app.data.local;

import android.content.Context;

import com.amperly.app.communication.ChatManager;
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.data.local.entity.AndroidAutoSession;
import com.amperly.app.data.local.entity.AvailabilitySchedule;
import com.amperly.app.data.local.entity.ChargerPort;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.ChatMessage;
import com.amperly.app.data.local.entity.CommunicationThread;
import com.amperly.app.data.local.entity.Dispute;
import com.amperly.app.data.local.entity.Invoice;
import com.amperly.app.data.local.entity.MeterReading;
import com.amperly.app.data.local.entity.Notification;
import com.amperly.app.data.local.entity.Payment;
import com.amperly.app.data.local.entity.Report;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.RoutePlan;
import com.amperly.app.data.local.entity.RouteStop;
import com.amperly.app.data.local.entity.SafetyEvent;
import com.amperly.app.data.local.entity.TripEstimate;
import com.amperly.app.data.local.entity.TrustedContact;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.UUID;

/**
 * Seeds the controlled pilot: one college campus, one apartment community, two chargers along the
 * Mysore → Mangalore corridor (one fast DC, one slower AC backup) and one discovery-only café
 * charger with no verified meter. Everything is written on a background thread because Room forbids
 * synchronous queries on the main thread.
 */
public class PilotDataSeeder {

    public static final String USER_CAMPUS_ADMIN = "user_campus_admin";
    public static final String USER_STUDENT = "user_student_1";
    public static final String USER_APT_HOST = "user_apt_association";
    public static final String USER_PLATFORM_ADMIN = "user_platform_admin";
    public static final String VEHICLE_STUDENT = "veh_101";

    public static final String STATION_CAMPUS = "st_campus_1";
    public static final String STATION_APARTMENT = "st_apt_1";
    public static final String STATION_HIGHWAY = "st_highway_1";
    public static final String STATION_ROADSIDE = "st_roadside_1";
    public static final String STATION_CAFE = "st_cafe_1";
    public static final String STATION_OFFICE_PENDING = "st_office_pending";

    public static final String SESSION_DEMO_1 = "sess_demo_1";
    public static final String SESSION_DEMO_2 = "sess_demo_2";
    public static final String PLAN_DEMO = "plan_demo_1";
    public static final String RESERVATION_DEMO_DONE = "res_demo_done";
    public static final String RESERVATION_DEMO_PENDING = "res_demo_pending";
    public static final String DISPUTE_DEMO = "dsp_demo_1";
    public static final String THREAD_DEMO = "thread_demo_1";
    public static final String INVOICE_DEMO_1 = "inv_demo_1";

    private PilotDataSeeder() {
    }

    public static void seedPilotData(Context context) {
        AmperlyRepository repo = AmperlyRepository.getInstance(context);
        repo.run(() -> {
            AmperlyDatabase db = repo.database();
            if (db.userDao().countUsers() > 0) {
                return; // already seeded
            }
            long now = System.currentTimeMillis();

            // ---------------------------------------------------------------- users
            db.userDao().insertAll(java.util.Arrays.asList(
                    new User(USER_CAMPUS_ADMIN, "ABC College Administration", "host@abccollege.edu",
                            "+919876543210", AppConstants.ROLE_HOST, "ABC College of Engineering",
                            "VERIFIED", false),
                    new User(USER_STUDENT, "Aarav Student", "aarav@abccollege.edu",
                            "+919876543211", AppConstants.ROLE_CONSUMER, null, "VERIFIED", false),
                    new User(USER_APT_HOST, "GreenPark Association", "president@greenpark.org",
                            "+919876543220", AppConstants.ROLE_HOST, "GreenPark Apartments",
                            "VERIFIED", false),
                    new User(USER_PLATFORM_ADMIN, "Amperly Ops", "admin@amperly.app",
                            "+919876543299", AppConstants.ROLE_ADMIN, "Amperly", "VERIFIED", false)
            ));

            // ------------------------------------------------------------- vehicle
            db.vehicleDao().insert(new Vehicle(VEHICLE_STUDENT, USER_STUDENT, "Tata", "Nexon EV",
                    "Max", 2023, 40.5, "CCS_2_DC", 7.2, 30.0, 6.5, 96.0, 0.0, 15, 80,
                    "KA09EV1234"));

            // ------------------------------------------------------------ stations
            ChargerStation campus = ChargerStation.create(STATION_CAMPUS, USER_CAMPUS_ADMIN,
                    "ABC College Administration", "ABC College Campus Charger",
                    "Gate 2 Parking, ABC Campus, Mysore", 12.3010, 76.6450,
                    AppConstants.LOCATION_TYPE_CAMPUS, "08:00 - 20:00", 18.0, 5.0, 4.0,
                    AppConstants.LEVEL_1_VERIFIED_MANUAL, "TYPE_2_AC,CCS_2_DC", 30.0, 4,
                    "Students and staff with a campus vehicle pass. Show the booking code at Gate 2.",
                    4.9);

            ChargerStation apartment = ChargerStation.create(STATION_APARTMENT, USER_APT_HOST,
                    "GreenPark Association", "GreenPark Shared Charger",
                    "Visitor Parking, GreenPark Apartments, Mysore", 12.3105, 76.6402,
                    AppConstants.LOCATION_TYPE_APARTMENT, "24/7", 16.0, 5.0, 4.0,
                    AppConstants.LEVEL_1_VERIFIED_MANUAL, "TYPE_2_AC", 7.2, 2,
                    "Residents and registered visitors. Register the vehicle number with the association.",
                    4.7);

            ChargerStation highway = ChargerStation.create(STATION_HIGHWAY, USER_CAMPUS_ADMIN,
                    "Highway Charge Partners", "Highway Hub Charger",
                    "Mysore - Mangalore Road, Km 68", 12.6000, 75.7900,
                    AppConstants.LOCATION_TYPE_COMMERCIAL, "24/7", 21.0, 6.0, 4.0,
                    AppConstants.LEVEL_2_SIMULATED_SMART_METER, "CCS_2_DC,CHADEMO", 60.0, 2,
                    "Open to the public. Attendant on site between 06:00 and 22:00.", 4.8);

            ChargerStation roadside = ChargerStation.create(STATION_ROADSIDE, USER_APT_HOST,
                    "Kodagu Road Services", "Kodagu Roadside AC Charger",
                    "Kodagu Road, Km 72 near the tea estate", 12.6050, 75.8200,
                    AppConstants.LOCATION_TYPE_PARKING, "06:00 - 22:00", 15.0, 5.0, 4.0,
                    AppConstants.LEVEL_1_VERIFIED_MANUAL, "TYPE_2_AC", 7.2, 1,
                    "Slower AC charger at the parking bay. Ring the bell for the attendant.", 4.4);

            ChargerStation cafe = ChargerStation.create(STATION_CAFE, USER_APT_HOST,
                    "Cafe Owner", "Cafe ChargePoint (no verified meter)",
                    "12 Sayyaji Rao Road, Mysore", 12.3060, 76.6500,
                    AppConstants.LOCATION_TYPE_CAFE, "09:00 - 21:00", 14.0, 0.0, 0.0,
                    AppConstants.LEVEL_3_NO_VERIFIED_METER, "TYPE_2_AC", 3.3, 1,
                    "Discovery only: the café has no verified meter, so no energy-based payment is captured.",
                    4.2);
            cafe.setPaused(false);

            ChargerStation officePending = ChargerStation.create(STATION_OFFICE_PENDING,
                    USER_APT_HOST, "Tech Park Facilities", "Tech Park Tower Charger",
                    "Tower B Basement, Tech Park, Mysore", 12.3200, 76.6600,
                    AppConstants.LOCATION_TYPE_OFFICE, "09:00 - 18:00", 17.0, 5.0, 4.0,
                    AppConstants.LEVEL_1_VERIFIED_MANUAL, "TYPE_2_AC", 11.0, 2,
                    "Employee access only, badge required at the basement gate.", 0.0);
            officePending.setApprovalStatus(AppConstants.APPROVAL_PENDING);
            officePending.setVerified(false);

            db.chargerStationDao().insertAll(java.util.Arrays.asList(campus, apartment, highway,
                    roadside, cafe, officePending));

            // --------------------------------------------------------------- ports
            List<ChargerPort> ports = new ArrayList<>();
            ports.add(new ChargerPort("port_campus_1", STATION_CAMPUS, "1", "TYPE_2_AC", 7.2, false,
                    AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_campus_2", STATION_CAMPUS, "2", "CCS_2_DC", 30.0, true,
                    AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_campus_3", STATION_CAMPUS, "3", "CCS_2_DC", 30.0, true,
                    AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_campus_4", STATION_CAMPUS, "4", "TYPE_2_AC", 7.2, false,
                    AppConstants.PORT_MAINTENANCE));
            ports.add(new ChargerPort("port_apt_1", STATION_APARTMENT, "1", "TYPE_2_AC", 7.2, false,
                    AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_apt_2", STATION_APARTMENT, "2", "TYPE_2_AC", 7.2, false,
                    AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_highway_1", STATION_HIGHWAY, "1", "CCS_2_DC", 60.0, true,
                    AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_highway_2", STATION_HIGHWAY, "2", "CHADEMO", 50.0, true,
                    AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_roadside_1", STATION_ROADSIDE, "1", "TYPE_2_AC", 7.2, false,
                    AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_cafe_1", STATION_CAFE, "1", "TYPE_2_AC", 3.3, false,
                    AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_office_1", STATION_OFFICE_PENDING, "1", "TYPE_2_AC", 11.0,
                    false, AppConstants.PORT_AVAILABLE));
            ports.add(new ChargerPort("port_office_2", STATION_OFFICE_PENDING, "2", "TYPE_2_AC", 11.0,
                    false, AppConstants.PORT_AVAILABLE));
            db.chargerPortDao().insertAll(ports);

            // ------------------------------------------------------- availability
            List<AvailabilitySchedule> schedules = new ArrayList<>();
            for (ChargerPort port : ports) {
                int open = 480;
                int close = 1200;
                if (STATION_APARTMENT.equals(port.getStationId()) || STATION_HIGHWAY.equals(port.getStationId())) {
                    open = 0;
                    close = 24 * 60;
                } else if (STATION_ROADSIDE.equals(port.getStationId())) {
                    open = 360;
                    close = 1320;
                } else if (STATION_CAFE.equals(port.getStationId())) {
                    open = 540;
                    close = 1260;
                } else if (STATION_OFFICE_PENDING.equals(port.getStationId())) {
                    open = 540;
                    close = 1080;
                }
                for (int day = Calendar.SUNDAY; day <= Calendar.SATURDAY; day++) {
                    boolean blocked = AppConstants.PORT_MAINTENANCE.equals(port.getStatus());
                    schedules.add(new AvailabilitySchedule(port.getId() + "_d" + day,
                            port.getStationId(), port.getId(), day, open, close, blocked,
                            blocked ? "Port under maintenance" : null, now));
                }
            }
            db.availabilityScheduleDao().insertAll(schedules);

            // -------------------------------------------------------- demo history
            long threeDaysAgo = now - (3L * 24L * 60L * 60L * 1000L);
            db.reservationDao().insert(new Reservation(RESERVATION_DEMO_DONE, USER_STUDENT,
                    STATION_CAMPUS, campus.getName(), "port_campus_2", "Port 2 · CCS_2_DC · 30 kW DC",
                    "AMP-1001", threeDaysAgo, threeDaysAgo + (90L * 60L * 1000L),
                    AppConstants.STATUS_COMPLETED, 18.0, 5.0, 4.0, 0.0, true, "pay_demo_1",
                    threeDaysAgo, 0, threeDaysAgo - (2L * 60L * 60L * 1000L)));

            db.chargingSessionDao().insert(new ChargingSession(SESSION_DEMO_1, RESERVATION_DEMO_DONE,
                    USER_STUDENT, USER_CAMPUS_ADMIN, STATION_CAMPUS, campus.getName(), "port_campus_2",
                    threeDaysAgo, threeDaysAgo + (90L * 60L * 1000L), 125.40, 137.90, 12.50, 180.0,
                    5.0, 4.0, 189.0, AppConstants.STATUS_COMPLETED, "mr_demo_1", INVOICE_DEMO_1,
                    true, AppConstants.LEVEL_1_VERIFIED_MANUAL));

            db.meterReadingDao().insert(new MeterReading("mr_demo_1", SESSION_DEMO_1, STATION_CAMPUS,
                    125.40, 137.90, "content://amperly.demo/meter_photo_1.jpg",
                    AppConstants.LEVEL_1_VERIFIED_MANUAL, threeDaysAgo + (90L * 60L * 1000L), true));

            db.invoiceDao().insert(new Invoice(INVOICE_DEMO_1, SESSION_DEMO_1, USER_STUDENT,
                    USER_CAMPUS_ADMIN, campus.getName(), 12.50, 180.0, 5.0, 4.0, 0.0, "", 189.0,
                    "pay_demo_1", "PAID", threeDaysAgo + (90L * 60L * 1000L)));

            db.paymentDao().insert(new Payment("pay_demo_1", RESERVATION_DEMO_DONE, SESSION_DEMO_1,
                    USER_STUDENT, USER_CAMPUS_ADMIN, "seed-demo-1", "SANDBOX", "auth_seed_demo_1",
                    226.80, 189.0, 0.0, 0.0, AppConstants.PAYMENT_CAPTURED, null,
                    threeDaysAgo - (2L * 60L * 60L * 1000L), threeDaysAgo + (90L * 60L * 1000L)));

            // Second completed session so host analytics has something to show.
            long yesterday = now - (24L * 60L * 60L * 1000L);
            db.reservationDao().insert(new Reservation("res_demo_done_2", USER_STUDENT,
                    STATION_APARTMENT, apartment.getName(), "port_apt_1", "Port 1 · TYPE_2_AC · 7 kW AC",
                    "AMP-1002", yesterday, yesterday + (120L * 60L * 1000L),
                    AppConstants.STATUS_COMPLETED, 16.0, 5.0, 4.0, 0.0, true, "pay_demo_2",
                    yesterday, 0, yesterday - (60L * 60L * 1000L)));
            db.chargingSessionDao().insert(new ChargingSession(SESSION_DEMO_2, "res_demo_done_2",
                    USER_STUDENT, USER_APT_HOST, STATION_APARTMENT, apartment.getName(), "port_apt_1",
                    yesterday, yesterday + (120L * 60L * 1000L), 240.10, 248.30, 8.20, 131.20, 5.0,
                    4.0, 140.20, AppConstants.STATUS_COMPLETED, "mr_demo_2", "inv_demo_2", true,
                    AppConstants.LEVEL_1_VERIFIED_MANUAL));
            db.meterReadingDao().insert(new MeterReading("mr_demo_2", SESSION_DEMO_2, STATION_APARTMENT,
                    240.10, 248.30, "content://amperly.demo/meter_photo_2.jpg",
                    AppConstants.LEVEL_1_VERIFIED_MANUAL, yesterday + (120L * 60L * 1000L), true));
            db.invoiceDao().insert(new Invoice("inv_demo_2", SESSION_DEMO_2, USER_STUDENT,
                    USER_APT_HOST, apartment.getName(), 8.20, 131.20, 5.0, 4.0, 0.0, "", 140.20,
                    "pay_demo_2", "PAID", yesterday + (120L * 60L * 1000L)));
            db.paymentDao().insert(new Payment("pay_demo_2", "res_demo_done_2", SESSION_DEMO_2,
                    USER_STUDENT, USER_APT_HOST, "seed-demo-2", "SANDBOX", "auth_seed_demo_2", 168.24,
                    140.20, 0.0, 0.0, AppConstants.PAYMENT_CAPTURED, null, yesterday, yesterday));

            // Upcoming reservation so the session and QR screens have live data.
            long slotStart = now + (2L * 60L * 60L * 1000L);
            db.reservationDao().insert(new Reservation(RESERVATION_DEMO_PENDING, USER_STUDENT,
                    STATION_CAMPUS, campus.getName(), "port_campus_3", "Port 3 · CCS_2_DC · 30 kW DC",
                    "AMP-2002", slotStart, slotStart + (90L * 60L * 1000L),
                    AppConstants.STATUS_RESERVED, 18.0, 5.0, 4.0, 0.0, true, "pay_demo_3", 0, 0,
                    now - (30L * 60L * 1000L)));
            db.paymentDao().insert(new Payment("pay_demo_3", RESERVATION_DEMO_PENDING, null,
                    USER_STUDENT, USER_CAMPUS_ADMIN, "seed-demo-3", "SANDBOX", "auth_seed_demo_3",
                    226.80, 0.0, 0.0, 0.0, AppConstants.PAYMENT_AUTHORIZED, null, now, now));

            // ------------------------------------------------------------- dispute
            db.disputeDao().insert(new Dispute(DISPUTE_DEMO, SESSION_DEMO_1, USER_STUDENT,
                    "Aarav Student", USER_CAMPUS_ADMIN, STATION_CAMPUS, campus.getName(),
                    "Incorrect meter reading",
                    "I was charged for 12.5 kWh but the charger display showed 9.8 kWh.",
                    "The meter is a campus submeter; the reading was recorded at the start and end of the slot.",
                    "mr_demo_1", "AWAITING_HOST", AppConstants.ENFORCEMENT_NONE, 0.0, "", true,
                    now - (2L * 60L * 60L * 1000L), 0));

            db.reportDao().insert(new Report("rpt_demo_1", USER_STUDENT, "Aarav Student", STATION_CAFE,
                    USER_APT_HOST, null, "Host requested off-platform payment",
                    "The café asked me to pay cash instead of using the app.",
                    "OPEN", now - (5L * 60L * 60L * 1000L)));

            // ---------------------------------------------------------------- chat
            long threadExpiry = slotStart + (90L * 60L * 1000L) + ChatManager.THREAD_LIFETIME_AFTER_SLOT_MS;
            User student = db.userDao().getUserByIdSync(USER_STUDENT);
            User campusHost = db.userDao().getUserByIdSync(USER_CAMPUS_ADMIN);
            db.communicationThreadDao().insert(new CommunicationThread(THREAD_DEMO,
                    RESERVATION_DEMO_PENDING, USER_STUDENT, student.getName(), USER_CAMPUS_ADMIN,
                    campusHost.getName(), ChatManager.maskPhoneNumber(student.getPhone()),
                    ChatManager.maskPhoneNumber(campusHost.getPhone()), false, false, true,
                    now - (30L * 60L * 1000L), threadExpiry));

            ChatMessage first = ChatManager.createMessage(THREAD_DEMO, RESERVATION_DEMO_PENDING,
                    USER_STUDENT, USER_CAMPUS_ADMIN, "Where is the charging entrance?",
                    student.getPhone(), campusHost.getPhone());
            db.chatMessageDao().insert(first);
            ChatMessage reply = ChatManager.createMessage(THREAD_DEMO, RESERVATION_DEMO_PENDING,
                    USER_CAMPUS_ADMIN, USER_STUDENT,
                    "Gate 2, second level of the parking block. Call me on " + campusHost.getPhone(),
                    campusHost.getPhone(), student.getPhone());
            db.chatMessageDao().insert(reply);
            ChatMessage offPlatform = ChatManager.createMessage(THREAD_DEMO, RESERVATION_DEMO_PENDING,
                    USER_CAMPUS_ADMIN, USER_STUDENT, "You can pay cash at the counter if you prefer.",
                    campusHost.getPhone(), student.getPhone());
            db.chatMessageDao().insert(offPlatform);

            // -------------------------------------------------------------- safety
            db.trustedContactDao().insert(new TrustedContact("tc_demo_1", USER_STUDENT,
                    "Ananya (sister)", "+919812345678"));
            db.safetyEventDao().insert(new SafetyEvent("se_demo_1", USER_STUDENT, STATION_CAMPUS,
                    "SOS", false, "+919812345678", now - (60L * 60L * 1000L),
                    now - (2L * 60L * 60L * 1000L)));

            // ----------------------------------------------------- notification feed
            db.notificationDao().insertAll(java.util.Arrays.asList(
                    new Notification("ntf_demo_1", USER_STUDENT, "Reservation confirmed",
                            "AMP-2002 at " + campus.getName() + " is confirmed. Show the booking code at Gate 2.",
                            false, now - (30L * 60L * 1000L)),
                    new Notification("ntf_demo_2", USER_STUDENT, "Receipt available",
                            "Your session at " + campus.getName() + " was billed on verified meter readings.",
                            true, threeDaysAgo + (95L * 60L * 1000L)),
                    new Notification("ntf_demo_3", USER_CAMPUS_ADMIN, "New reservation",
                            "Aarav Student reserved Port 3 for a 90-minute slot.",
                            false, now - (30L * 60L * 1000L))
            ));

            // ------------------------------------------------------------ route plan
            db.routePlanDao().insert(new RoutePlan(PLAN_DEMO, USER_STUDENT, VEHICLE_STUDENT,
                    "Mysore", "Mangalore", 12.2958, 76.6394, 12.9141, 74.8560, 10.0,
                    "FASTEST", 140.0, 186, 8, 18, 212, 100, 20, true,
                    "140 km at an average 45 km/h; 6.2 km/kWh after the health adjustment; "
                            + "80% of the lower of vehicle and charger peak power for charging time.",
                    "MEDIUM", "COMPLETED", now - (3L * 24L * 60L * 60L * 1000L),
                    now - (2L * 24L * 60L * 60L * 1000L)));

            db.routeStopDao().insert(new RouteStop("rs_demo_1", PLAN_DEMO, 1, STATION_HIGHWAY,
                    highway.getName(), false, true, 68.0, 6.4, 9, 29, 59, 12.1, 30, 259.6,
                    "Detour: +6.4 km / +9 min\nEstimated charge: 30 min\nEstimated energy added: 12.1 kWh\n"
                            + "Expected battery on arrival: 29%\nExpected battery after charging: 59%\n"
                            + "Expected battery at destination: 34%", null));
            db.routeStopDao().insert(new RouteStop("rs_demo_2", PLAN_DEMO, 2, STATION_ROADSIDE,
                    roadside.getName(), true, true, 72.0, 2.0, 4, 27, 45, 7.2, 75, 118.0,
                    "Backup: slower AC charger if the fast port is occupied.", null));

            db.tripEstimateDao().insert(new TripEstimate("te_demo_1", PLAN_DEMO, VEHICLE_STUDENT,
                    140.0, 26.5, 28.4, 22, 20, "MEDIUM",
                    "Reported by the consumer after the trip: actual battery fell slightly faster than planned.",
                    now - (2L * 24L * 60L * 60L * 1000L)));

            db.androidAutoSessionDao().insert(new AndroidAutoSession("aas_demo_1", USER_STUDENT,
                    VEHICLE_STUDENT, PLAN_DEMO, "ROUTE_OVERVIEW", 25,
                    threeDaysAgo, threeDaysAgo + (60L * 60L * 1000L),
                    threeDaysAgo + (3L * 60L * 60L * 1000L)));

            db.batteryUpdateDao().insert(new com.amperly.app.data.local.entity.BatteryUpdate(
                    UUID.randomUUID().toString(), VEHICLE_STUDENT, PLAN_DEMO, 35, 25, 12.45, 76.05,
                    threeDaysAgo + (60L * 60L * 1000L)));
        });
    }
}
