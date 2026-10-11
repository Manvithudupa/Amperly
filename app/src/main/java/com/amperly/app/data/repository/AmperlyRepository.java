package com.amperly.app.data.repository;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.lifecycle.LiveData;

import com.amperly.app.data.local.AmperlyDatabase;
import com.amperly.app.data.local.entity.AndroidAutoSession;
import com.amperly.app.data.local.entity.AvailabilitySchedule;
import com.amperly.app.data.local.entity.BatteryUpdate;
import com.amperly.app.data.local.entity.ChargerPort;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.ChatMessage;
import com.amperly.app.data.local.entity.CommunicationThread;
import com.amperly.app.data.local.entity.Dispute;
import com.amperly.app.data.local.entity.HostEnforcementAction;
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
import com.amperly.app.engine.analytics.HostAnalyticsEngine;
import com.amperly.app.engine.availability.AvailabilityEngine;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Single entry point for reading and writing Amperly data. Room queries that would block are pushed
 * onto a background executor and their results are delivered back on the main thread.
 */
public class AmperlyRepository {

    public interface Callback<T> {
        void onResult(T value);
    }

    private static volatile AmperlyRepository INSTANCE;

    private final AmperlyDatabase db;
    private final ExecutorService executor = Executors.newFixedThreadPool(4);
    private final Handler mainHandler = new Handler(Looper.getMainLooper());

    private AmperlyRepository(Context context) {
        db = AmperlyDatabase.getInstance(context);
    }

    public static AmperlyRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (AmperlyRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new AmperlyRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public AmperlyDatabase database() {
        return db;
    }

    public <T> void background(Callable<T> work, Callback<T> callback) {
        executor.execute(() -> {
            try {
                T value = work.call();
                if (callback != null) {
                    mainHandler.post(() -> callback.onResult(value));
                }
            } catch (Exception e) {
                if (callback != null) {
                    mainHandler.post(() -> callback.onResult(null));
                }
            }
        });
    }

    public void run(Runnable work) {
        executor.execute(work);
    }

    // ---------------------------------------------------------------- users

    public LiveData<User> getUser(String id) {
        return db.userDao().getUserById(id);
    }

    public User getUserSync(String id) {
        return db.userDao().getUserByIdSync(id);
    }

    public List<User> getAllUsersSync() {
        return db.userDao().getAllUsersSync();
    }

    public void insertUser(User user) {
        run(() -> db.userDao().insert(user));
    }

    public void updateUser(User user) {
        run(() -> db.userDao().update(user));
    }

    // ------------------------------------------------------------- vehicles

    public LiveData<Vehicle> observeVehicle(String userId) {
        return db.vehicleDao().getVehicleByUserId(userId);
    }

    public Vehicle getVehicleSync(String userId) {
        return db.vehicleDao().getVehicleByUserIdSync(userId);
    }

    public void saveVehicle(Vehicle vehicle) {
        run(() -> db.vehicleDao().insert(vehicle));
    }

    // ------------------------------------------------------------- stations

    public LiveData<List<ChargerStation>> observeAllStations() {
        return db.chargerStationDao().getAllStations();
    }

    public LiveData<List<ChargerStation>> observePendingStations() {
        return db.chargerStationDao().getPendingStations();
    }

    public LiveData<List<ChargerStation>> observeStationsForHost(String hostId) {
        return db.chargerStationDao().getStationsByHost(hostId);
    }

    public LiveData<ChargerStation> observeStation(String stationId) {
        return db.chargerStationDao().getStationById(stationId);
    }

    public List<ChargerStation> getAllStationsSync() {
        return db.chargerStationDao().getAllStationsSync();
    }

    public List<ChargerStation> getApprovedStationsSync() {
        return db.chargerStationDao().getApprovedStationsSync();
    }

    public List<ChargerStation> getPendingStationsSync() {
        return db.chargerStationDao().getPendingStationsSync();
    }

    public List<ChargerStation> getStationsForHostSync(String hostId) {
        return db.chargerStationDao().getStationsByHostSync(hostId);
    }

    public ChargerStation getStationSync(String stationId) {
        return db.chargerStationDao().getStationByIdSync(stationId);
    }

    public void saveStation(ChargerStation station) {
        run(() -> db.chargerStationDao().insert(station));
    }

    public void updateStation(ChargerStation station) {
        run(() -> db.chargerStationDao().update(station));
    }

    public void setStationPaused(ChargerStation station, boolean paused) {
        run(() -> {
            station.setPaused(paused);
            station.setLastUpdatedMs(System.currentTimeMillis());
            db.chargerStationDao().update(station);
        });
    }

    // ---------------------------------------------------------------- ports

    public LiveData<List<ChargerPort>> observePorts(String stationId) {
        return db.chargerPortDao().getPortsForStation(stationId);
    }

    public List<ChargerPort> getPortsSync(String stationId) {
        return db.chargerPortDao().getPortsForStationSync(stationId);
    }

    public List<ChargerPort> getAllPortsSync() {
        return db.chargerPortDao().getAllPortsSync();
    }

    public void savePort(ChargerPort port) {
        run(() -> db.chargerPortDao().insert(port));
    }

    public void savePorts(List<ChargerPort> ports) {
        run(() -> db.chargerPortDao().insertAll(ports));
    }

    public void setPortStatus(ChargerPort port, String status) {
        run(() -> {
            port.setStatus(status);
            db.chargerPortDao().update(port);
        });
    }

    // ----------------------------------------------------------- schedules

    public List<AvailabilitySchedule> getSchedulesSync(String stationId) {
        return db.availabilityScheduleDao().getSchedulesForStationSync(stationId);
    }

    public List<AvailabilitySchedule> getAllSchedulesSync() {
        return db.availabilityScheduleDao().getAllSchedulesSync();
    }

    public void saveSchedules(List<AvailabilitySchedule> schedules) {
        run(() -> db.availabilityScheduleDao().insertAll(schedules));
    }

    public void blockStation(String stationId, boolean blocked, String reason) {
        run(() -> db.availabilityScheduleDao().setStationBlocked(stationId, blocked, reason,
                System.currentTimeMillis()));
    }

    public void blockPort(String portId, String reason) {
        run(() -> db.availabilityScheduleDao().blockPort(portId, reason, System.currentTimeMillis()));
    }

    // --------------------------------------------------------- availability

    public List<AvailabilityEngine.Slot> getSlots(String stationId, long dayStartMs, int slotMinutes,
                                                 int maxSlots) {
        ChargerStation station = getStationSync(stationId);
        if (station == null) {
            return Collections.emptyList();
        }
        return AvailabilityEngine.generateSlots(station, getPortsSync(stationId),
                getSchedulesSync(stationId), getReservationsForStationSync(stationId),
                dayStartMs, slotMinutes, maxSlots);
    }

    public AvailabilityEngine.AvailabilitySummary getAvailabilitySummary(String stationId) {
        ChargerStation station = getStationSync(stationId);
        if (station == null) {
            return new AvailabilityEngine.AvailabilitySummary(0, 0, 0, System.currentTimeMillis(),
                    false, "Station not found");
        }
        return AvailabilityEngine.summarise(station, getPortsSync(stationId),
                getSchedulesSync(stationId), getReservationsForStationSync(stationId),
                System.currentTimeMillis());
    }

    // --------------------------------------------------------- reservations

    public LiveData<List<Reservation>> observeReservationsForConsumer(String consumerId) {
        return db.reservationDao().getReservationsForConsumer(consumerId);
    }

    public LiveData<List<Reservation>> observeReservationsForHost(String hostId) {
        return db.reservationDao().getReservationsForHost(hostId);
    }

    public List<Reservation> getReservationsForConsumerSync(String consumerId) {
        return db.reservationDao().getReservationsForConsumerSync(consumerId);
    }

    public List<Reservation> getReservationsForHostSync(String hostId) {
        return db.reservationDao().getReservationsForHostSync(hostId);
    }

    public List<Reservation> getReservationsForStationSync(String stationId) {
        return db.reservationDao().getReservationsForStationSync(stationId);
    }

    public Reservation getActiveReservationSync(String consumerId) {
        return db.reservationDao().getActiveReservationForConsumerSync(consumerId);
    }

    public Reservation getReservationSync(String reservationId) {
        return db.reservationDao().getReservationByIdSync(reservationId);
    }

    public Reservation getReservationByCodeSync(String bookingCode) {
        return db.reservationDao().getReservationByBookingCodeSync(bookingCode);
    }

    public int countSlotConflicts(String portId, long startMs, long endMs) {
        return db.reservationDao().countConflicts(portId, startMs, endMs);
    }

    public void saveReservation(Reservation reservation) {
        run(() -> db.reservationDao().insert(reservation));
    }

    public void updateReservation(Reservation reservation) {
        run(() -> db.reservationDao().update(reservation));
    }

    // ------------------------------------------------------------- sessions

    public LiveData<List<ChargingSession>> observeSessionsForConsumer(String consumerId) {
        return db.chargingSessionDao().getSessionsForConsumer(consumerId);
    }

    public LiveData<List<ChargingSession>> observeSessionsForHost(String hostId) {
        return db.chargingSessionDao().getSessionsForHost(hostId);
    }

    public List<ChargingSession> getSessionsForConsumerSync(String consumerId) {
        return db.chargingSessionDao().getSessionsForConsumerSync(consumerId);
    }

    public List<ChargingSession> getSessionsForHostSync(String hostId) {
        return db.chargingSessionDao().getSessionsForHostSync(hostId);
    }

    public List<ChargingSession> getAllSessionsSync() {
        return db.chargingSessionDao().getAllSessionsSync();
    }

    public ChargingSession getSessionSync(String sessionId) {
        return db.chargingSessionDao().getSessionByIdSync(sessionId);
    }

    public ChargingSession getSessionByReservationSync(String reservationId) {
        return db.chargingSessionDao().getSessionByReservationSync(reservationId);
    }

    public void saveSession(ChargingSession session) {
        run(() -> db.chargingSessionDao().insert(session));
    }

    public void updateSession(ChargingSession session) {
        run(() -> db.chargingSessionDao().update(session));
    }

    // -------------------------------------------------------- meter readings

    public void saveMeterReading(MeterReading reading) {
        run(() -> db.meterReadingDao().insert(reading));
    }

    public MeterReading getLatestMeterReadingSync(String sessionId) {
        return db.meterReadingDao().getLatestForSessionSync(sessionId);
    }

    public List<MeterReading> getMeterReadingsSync(String sessionId) {
        return db.meterReadingDao().getReadingsForSessionSync(sessionId);
    }

    public List<MeterReading> getAllMeterReadingsSync() {
        return db.meterReadingDao().getAllReadingsSync();
    }

    // --------------------------------------------------------------- invoices

    public LiveData<List<Invoice>> observeInvoices(String consumerId) {
        return db.invoiceDao().getInvoicesForConsumer(consumerId);
    }

    public void saveInvoice(Invoice invoice) {
        run(() -> db.invoiceDao().insert(invoice));
    }

    public void updateInvoice(Invoice invoice) {
        run(() -> db.invoiceDao().update(invoice));
    }

    public Invoice getInvoiceSync(String invoiceId) {
        return db.invoiceDao().getInvoiceByIdSync(invoiceId);
    }

    public Invoice getInvoiceBySessionSync(String sessionId) {
        return db.invoiceDao().getInvoiceBySessionSync(sessionId);
    }

    public List<Invoice> getInvoicesForHostSync(String hostId) {
        return db.invoiceDao().getInvoicesForHostSync(hostId);
    }

    public List<Invoice> getInvoicesForConsumerSync(String consumerId) {
        return db.invoiceDao().getInvoicesForConsumerSync(consumerId);
    }

    public List<Invoice> getAllInvoicesSync() {
        return db.invoiceDao().getAllInvoicesSync();
    }

    // --------------------------------------------------------------- payments

    public void savePayment(Payment payment) {
        run(() -> db.paymentDao().insert(payment));
    }

    public Payment findPaymentByKey(String idempotencyKey) {
        return db.paymentDao().findByIdempotencyKey(idempotencyKey);
    }

    public Payment getPaymentForReservationSync(String reservationId) {
        return db.paymentDao().getPaymentForReservationSync(reservationId);
    }

    public Payment getPaymentForSessionSync(String sessionId) {
        return db.paymentDao().getPaymentForSessionSync(sessionId);
    }

    public List<Payment> getPaymentsForHostSync(String hostId) {
        return db.paymentDao().getPaymentsForHostSync(hostId);
    }

    // -------------------------------------------------------------- disputes

    public LiveData<List<Dispute>> observeDisputes() {
        return db.disputeDao().getAllDisputes();
    }

    public List<Dispute> getDisputesSync() {
        return db.disputeDao().getAllDisputesSync();
    }

    public List<Dispute> getOpenDisputesSync() {
        return db.disputeDao().getOpenDisputesSync();
    }

    public List<Dispute> getDisputesForHostSync(String hostId) {
        return db.disputeDao().getDisputesForHostSync(hostId);
    }

    public Dispute getDisputeSync(String disputeId) {
        return db.disputeDao().getDisputeByIdSync(disputeId);
    }

    public void saveDispute(Dispute dispute) {
        run(() -> db.disputeDao().insert(dispute));
    }

    public void updateDispute(Dispute dispute) {
        run(() -> db.disputeDao().update(dispute));
    }

    public int countProvenIncidents(String hostId) {
        return db.disputeDao().countProvenIncidentsForHost(hostId);
    }

    // --------------------------------------------------------------- reports

    public LiveData<List<Report>> observeReports() {
        return db.reportDao().getAllReports();
    }

    public List<Report> getAllReportsSync() {
        return db.reportDao().getAllReportsSync();
    }

    public List<Report> getOpenReportsSync() {
        return db.reportDao().getOpenReportsSync();
    }

    public List<Report> getReportsForStationSync(String stationId) {
        return db.reportDao().getReportsForStationSync(stationId);
    }

    public void saveReport(Report report) {
        run(() -> db.reportDao().insert(report));
    }

    // ----------------------------------------------------------- enforcement

    public void saveEnforcementAction(HostEnforcementAction action) {
        run(() -> db.hostEnforcementActionDao().insert(action));
    }

    public List<HostEnforcementAction> getEnforcementForHostSync(String hostId) {
        return db.hostEnforcementActionDao().getActionsForHostSync(hostId);
    }

    public List<HostEnforcementAction> getEnforcementForStationSync(String stationId) {
        return db.hostEnforcementActionDao().getActionsForStationSync(stationId);
    }

    public List<HostEnforcementAction> getAllEnforcementSync() {
        return db.hostEnforcementActionDao().getAllActionsSync();
    }

    // --------------------------------------------------------- notifications

    public LiveData<List<Notification>> observeNotifications(String userId) {
        return db.notificationDao().getNotificationsForUser(userId);
    }

    public List<Notification> getNotificationsSync(String userId) {
        return db.notificationDao().getNotificationsForUserSync(userId);
    }

    public void saveNotification(Notification notification) {
        run(() -> db.notificationDao().insert(notification));
    }

    public void markNotificationsRead(String userId) {
        run(() -> db.notificationDao().markAllRead(userId));
    }

    // ------------------------------------------------------------------ chat

    public LiveData<List<CommunicationThread>> observeThreadsForConsumer(String consumerId) {
        return db.communicationThreadDao().getThreadsForConsumer(consumerId);
    }

    public LiveData<List<CommunicationThread>> observeThreadsForHost(String hostId) {
        return db.communicationThreadDao().getThreadsForHost(hostId);
    }

    public CommunicationThread getThreadByReservationSync(String reservationId) {
        return db.communicationThreadDao().getThreadByReservationSync(reservationId);
    }

    public List<CommunicationThread> getAllThreadsSync() {
        return db.communicationThreadDao().getAllThreadsSync();
    }

    public void saveThread(CommunicationThread thread) {
        run(() -> db.communicationThreadDao().insert(thread));
    }

    public void updateThread(CommunicationThread thread) {
        run(() -> db.communicationThreadDao().update(thread));
    }

    public void reportThread(String threadId) {
        run(() -> db.communicationThreadDao().markReported(threadId));
    }

    public void blockThread(String threadId) {
        run(() -> db.communicationThreadDao().block(threadId));
    }

    public LiveData<List<ChatMessage>> observeMessages(String threadId) {
        return db.chatMessageDao().getMessagesForThread(threadId);
    }

    public List<ChatMessage> getMessagesSync(String threadId) {
        return db.chatMessageDao().getMessagesForThreadSync(threadId);
    }

    public List<ChatMessage> getAllMessagesSync() {
        return db.chatMessageDao().getAllMessagesSync();
    }

    public void saveMessage(ChatMessage message) {
        run(() -> db.chatMessageDao().insert(message));
    }

    public void reportMessage(String messageId) {
        run(() -> db.chatMessageDao().markReported(messageId));
    }

    public void purgeExpiredMessages() {
        run(() -> db.chatMessageDao().purgeExpired(System.currentTimeMillis()));
    }

    // ---------------------------------------------------------------- safety

    public LiveData<List<SafetyEvent>> observeSafetyEvents(String consumerId) {
        return db.safetyEventDao().getEventsForConsumer(consumerId);
    }

    public List<SafetyEvent> getSafetyEventsSync(String consumerId) {
        return db.safetyEventDao().getEventsForConsumerSync(consumerId);
    }

    public SafetyEvent getActiveLocationSharingSync(String consumerId) {
        return db.safetyEventDao().getActiveSharingSync(consumerId, System.currentTimeMillis());
    }

    public void saveSafetyEvent(SafetyEvent event) {
        run(() -> db.safetyEventDao().insert(event));
    }

    public void updateSafetyEvent(SafetyEvent event) {
        run(() -> db.safetyEventDao().update(event));
    }

    public void expireStaleLocationSharing() {
        run(() -> db.safetyEventDao().expireStaleSharing(System.currentTimeMillis()));
    }

    public LiveData<List<TrustedContact>> observeTrustedContacts(String userId) {
        return db.trustedContactDao().getContactsForUser(userId);
    }

    public List<TrustedContact> getTrustedContactsSync(String userId) {
        return db.trustedContactDao().getContactsForUserSync(userId);
    }

    public void saveTrustedContact(TrustedContact contact) {
        run(() -> db.trustedContactDao().insert(contact));
    }

    public void deleteTrustedContact(TrustedContact contact) {
        run(() -> db.trustedContactDao().delete(contact));
    }

    // ---------------------------------------------------------- route plans

    public LiveData<List<RoutePlan>> observeRoutePlans(String consumerId) {
        return db.routePlanDao().getPlansForConsumer(consumerId);
    }

    public RoutePlan getRoutePlanSync(String planId) {
        return db.routePlanDao().getPlanByIdSync(planId);
    }

    public RoutePlan getActiveRoutePlanSync(String consumerId) {
        return db.routePlanDao().getActivePlanSync(consumerId);
    }

    public List<RoutePlan> getRoutePlansSync(String consumerId) {
        return db.routePlanDao().getPlansForConsumerSync(consumerId);
    }

    public void saveRoutePlan(RoutePlan plan) {
        run(() -> db.routePlanDao().insert(plan));
    }

    public void updateRoutePlan(RoutePlan plan) {
        run(() -> db.routePlanDao().update(plan));
    }

    public List<RouteStop> getRouteStopsSync(String planId) {
        return db.routeStopDao().getStopsForPlanSync(planId);
    }

    public List<RouteStop> getBackupStopsSync(String planId) {
        return db.routeStopDao().getBackupStopsSync(planId);
    }

    public void saveRouteStops(List<RouteStop> stops) {
        run(() -> db.routeStopDao().insertAll(stops));
    }

    public void replaceRouteStops(String planId, List<RouteStop> stops) {
        run(() -> {
            db.routeStopDao().deleteStopsForPlan(planId);
            if (stops != null && !stops.isEmpty()) {
                db.routeStopDao().insertAll(stops);
            }
        });
    }

    // -------------------------------------------------------- trip estimates

    public void saveTripEstimate(TripEstimate estimate) {
        run(() -> db.tripEstimateDao().insert(estimate));
    }

    public List<TripEstimate> getTripEstimatesSync(String vehicleId) {
        return db.tripEstimateDao().getEstimatesForVehicleSync(vehicleId);
    }

    public List<TripEstimate> getTripEstimatesForPlanSync(String planId) {
        return db.tripEstimateDao().getEstimatesForPlanSync(planId);
    }

    public List<TripEstimate> getAllTripEstimatesSync() {
        return db.tripEstimateDao().getAllEstimatesSync();
    }

    public double averageDriftKwh(String vehicleId) {
        return db.tripEstimateDao().averageDriftForVehicle(vehicleId);
    }

    // -------------------------------------------------------- battery updates

    public void saveBatteryUpdate(BatteryUpdate update) {
        run(() -> db.batteryUpdateDao().insert(update));
    }

    public List<BatteryUpdate> getBatteryUpdatesSync(String planId) {
        return db.batteryUpdateDao().getUpdatesForTripSync(planId);
    }

    public BatteryUpdate getLatestBatteryUpdateSync(String planId) {
        return db.batteryUpdateDao().getLatestForTripSync(planId);
    }

    public List<BatteryUpdate> getAllBatteryUpdatesSync() {
        return db.batteryUpdateDao().getAllUpdatesSync();
    }

    // --------------------------------------------------- android auto session

    public void saveAutoSession(AndroidAutoSession session) {
        run(() -> db.androidAutoSessionDao().insert(session));
    }

    public AndroidAutoSession getLatestAutoSessionSync(String userId) {
        return db.androidAutoSessionDao().getLatestForUserSync(userId);
    }

    public List<AndroidAutoSession> getAutoSessionsSync(String userId) {
        return db.androidAutoSessionDao().getSessionsForUserSync(userId);
    }

    // ------------------------------------------------------------- analytics

    public HostAnalyticsEngine.HostAnalytics hostAnalytics(String hostId) {
        List<ChargerStation> stations = getStationsForHostSync(hostId);
        List<ChargerPort> ports = new ArrayList<>();
        for (ChargerStation station : stations) {
            ports.addAll(getPortsSync(station.getId()));
        }
        List<Dispute> disputes = getDisputesForHostSync(hostId);
        return HostAnalyticsEngine.compute(stations, ports, getSessionsForHostSync(hostId),
                getReservationsForHostSync(hostId), getInvoicesForHostSync(hostId), disputes);
    }

    public HostAnalyticsEngine.HostAnalytics platformAnalytics() {
        List<ChargerStation> stations = getAllStationsSync();
        List<ChargerPort> ports = getAllPortsSync();
        return HostAnalyticsEngine.compute(stations, ports, getAllSessionsSync(),
                new ArrayList<>(), getAllInvoicesSync(), getDisputesSync());
    }

    public int stationCount() {
        return db.chargerStationDao().countStations();
    }

    public int userCount() {
        return db.userDao().countUsers();
    }
}
