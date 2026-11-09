package com.amperly.app;

import com.amperly.app.core.common.AppConstants;
import com.amperly.app.data.local.entity.ChargerPort;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.engine.booking.ReservationEngine;

import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class BookingAndMeterTest {

    private ChargerStation station;
    private ChargerPort port;

    @Before
    public void setUp() {
        station = ChargerStation.create("st_1", "host_1", "ABC College", "Campus Charger", "Gate 2",
                12.301, 76.645, AppConstants.LOCATION_TYPE_CAMPUS, "08:00 - 20:00", 18.0, 5.0, 4.0,
                AppConstants.LEVEL_1_VERIFIED_MANUAL, "CCS_2_DC,TYPE_2_AC", 30.0, 2,
                "Campus pass required", 4.9);
        port = new ChargerPort("port_1", "st_1", "2", "CCS_2_DC", 30.0, true,
                AppConstants.PORT_AVAILABLE);
    }

    private Vehicle vehicle() {
        return new Vehicle("veh_1", "cons_1", "Tata", "Nexon EV", "Max", 2023, 40.5, "CCS_2_DC",
                7.2, 30.0, 6.5, 96.0, 0.0, 15, 80, "KA09EV1234", true);
    }

    @Test
    public void aFreeCompatibleSlotCanBeReserved() {
        long now = System.currentTimeMillis();
        ReservationEngine.BookingCheck check = ReservationEngine.check(station, port, vehicle(),
                now, now + 5_400_000L, 0, false);

        assertTrue(check.isAllowed());
        assertTrue(check.isRequiresPaidAuthorization());
    }

    @Test
    public void doubleBookingIsPrevented() {
        long now = System.currentTimeMillis();
        ReservationEngine.BookingCheck check = ReservationEngine.check(station, port, vehicle(),
                now, now + 5_400_000L, 1, false);

        assertFalse(check.isAllowed());
        assertTrue(check.getReason().toLowerCase().contains("double booking"));
    }

    @Test
    public void incompatibleConnectorCannotBeReserved() {
        ChargerPort chademo = new ChargerPort("port_3", "st_1", "3", "CHADEMO", 50.0, true,
                AppConstants.PORT_AVAILABLE);
        long now = System.currentTimeMillis();
        ReservationEngine.BookingCheck check = ReservationEngine.check(station, chademo, vehicle(),
                now, now + 5_400_000L, 0, false);

        assertFalse(check.isAllowed());
        assertTrue(check.getReason().toLowerCase().contains("connector"));
    }

    @Test
    public void pausedOrUnverifiedStationsCannotBeReserved() {
        long now = System.currentTimeMillis();
        ChargerStation paused = ChargerStation.create("st_2", "host_1", "Host", "Paused", "Addr",
                12.30, 76.64, AppConstants.LOCATION_TYPE_OFFICE, "24/7", 18.0, 5.0, 4.0,
                AppConstants.LEVEL_1_VERIFIED_MANUAL, "CCS_2_DC", 30.0, 1, "rules", 4.0);
        paused.setPaused(true);
        assertFalse(ReservationEngine.check(paused, port, vehicle(), now, now + 60_000L, 0, false).isAllowed());

        ChargerStation pending = ChargerStation.create("st_3", "host_1", "Host", "Pending", "Addr",
                12.30, 76.64, AppConstants.LOCATION_TYPE_OFFICE, "24/7", 18.0, 5.0, 4.0,
                AppConstants.LEVEL_1_VERIFIED_MANUAL, "CCS_2_DC", 30.0, 1, "rules", 4.0);
        pending.setApprovalStatus(AppConstants.APPROVAL_PENDING);
        assertFalse(ReservationEngine.check(pending, port, vehicle(), now, now + 60_000L, 0, false).isAllowed());
    }

    @Test
    public void meterlessStationsReserveWithoutAutomaticBilling() {
        ChargerStation cafe = ChargerStation.create("st_4", "host_1", "Cafe", "Cafe ChargePoint", "Addr",
                12.306, 76.650, AppConstants.LOCATION_TYPE_CAFE, "09:00 - 21:00", 14.0, 0.0, 0.0,
                AppConstants.LEVEL_3_NO_VERIFIED_METER, "TYPE_2_AC", 3.3, 1, "Ask at the counter", 4.2);
        ChargerPort acPort = new ChargerPort("port_9", "st_4", "1", "TYPE_2_AC", 3.3, false,
                AppConstants.PORT_AVAILABLE);
        long now = System.currentTimeMillis();

        ReservationEngine.BookingCheck check = ReservationEngine.check(cafe, acPort, null, now,
                now + 5_400_000L, 0, false);
        assertTrue(check.isAllowed());
        assertFalse(check.isRequiresPaidAuthorization());
        assertTrue(check.getReason().toLowerCase().contains("no verified meter"));
    }

    @Test
    public void pricePreviewSeparatesEnergyServiceAndGatewayCharges() {
        ReservationEngine.PricePreview preview = ReservationEngine.preview(station, 12.5);

        assertEquals(225.00, preview.getEnergyCharge(), 0.001);
        assertEquals(5.00, preview.getServiceFee(), 0.001);
        assertEquals(4.00, preview.getGatewayFee(), 0.001);
        assertEquals(234.00, preview.getEstimatedTotal(), 0.001);
        assertTrue(preview.getAuthorizedAmount() > preview.getEstimatedTotal());
    }

    @Test
    public void publishedCancellationPolicyIsAlwaysDisclosed() {
        assertTrue(ReservationEngine.CANCELLATION_POLICY.contains("Free cancellation"));
        assertTrue(ReservationEngine.CANCELLATION_POLICY.contains("late-cancellation"));
        assertTrue(ReservationEngine.CANCELLATION_POLICY.contains("No energy charge"));
    }





}
