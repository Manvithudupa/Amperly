package com.amperly.app;

import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.Invoice;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.engine.analytics.HostAnalyticsEngine;

import org.junit.Test;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/**
 * The host dashboard's numbers come from hand-built lists here, so a change in how a session,
 * invoice or reservation is counted shows up as a test failure rather than as a wrong figure on
 * someone's earnings page.
 */
public class HostAnalyticsEngineTest {

    private static ChargingSession session(String id, String status, String consumerId,
                                           double kwh, long startMs, long endMs) {
        return new ChargingSession(id, "res_" + id, consumerId, "host_1", "st_1", "Campus Charger",
                "port_1", startMs, endMs, 0, kwh, kwh, 0, 0, 0, 0, status, null, null, false,
                "LEVEL_1_VERIFIED_MANUAL");
    }

    private static Invoice invoice(double finalTotal, double adjustment) {
        return new Invoice("inv_1", "sess_1", "c1", "host_1", "Campus Charger", 10, 0, 0, 0,
                adjustment, null, finalTotal, "pay_1", "PAID", 0);
    }

    private static Reservation reservation(String id, String status) {
        return new Reservation(id, "c1", "st_1", "Campus Charger", "port_1", "Port 1", "BK" + id,
                0, 0, status, 15, 0, 0, 0, true, "pay_1", 0, 0, 0);
    }

    @Test
    public void emptyInputsReportZerosRatherThanCrashing() {
        HostAnalyticsEngine.HostAnalytics analytics =
                HostAnalyticsEngine.compute(null, null, null, null, null, null);

        assertEquals(0, analytics.getSessionsCompleted());
        assertEquals(0.0, analytics.getEnergyDeliveredKwh(), 0.001);
        assertEquals(0.0, analytics.getRevenue(), 0.001);
        assertEquals(0.0, analytics.getRefundsAndAdjustments(), 0.001);
        assertEquals(0, analytics.getPorts());
        assertEquals(0, analytics.getActiveReservations());
        assertEquals(0.0, analytics.getCancellationRatePercent(), 0.001);
        assertFalse(analytics.getUtilizationNote().isEmpty());
    }

    @Test
    public void onlyFinishedSessionsCountTowardsEnergyAndAverage() {
        List<ChargingSession> sessions = Arrays.asList(
                session("s1", "COMPLETED", "c1", 10.0, 0, 60L * 60L * 1000L),
                session("s2", "REFUNDED", "c2", 5.0, 0, 30L * 60L * 1000L),
                session("s3", "CHARGING", "c1", 99.0, 0, 30L * 60L * 1000L));

        HostAnalyticsEngine.HostAnalytics analytics =
                HostAnalyticsEngine.compute(null, null, sessions, null, null, null);

        assertEquals(2, analytics.getSessionsCompleted());
        assertEquals(15.0, analytics.getEnergyDeliveredKwh(), 0.001);
        assertEquals(7.5, analytics.getAverageSessionKwh(), 0.001);
        assertEquals(0, analytics.getRepeatConsumers());
    }

    @Test
    public void aConsumerWithTwoFinishedSessionsIsARepeatConsumer() {
        List<ChargingSession> sessions = Arrays.asList(
                session("s1", "COMPLETED", "c1", 4.0, 0, 60L * 60L * 1000L),
                session("s2", "COMPLETED", "c1", 4.0, 0, 60L * 60L * 1000L),
                session("s3", "COMPLETED", "c2", 4.0, 0, 60L * 60L * 1000L));

        HostAnalyticsEngine.HostAnalytics analytics =
                HostAnalyticsEngine.compute(null, null, sessions, null, null, null);

        assertEquals(1, analytics.getRepeatConsumers());
    }

    @Test
    public void revenueSumsFinalTotalsAndAdjustmentsSeparately() {
        List<Invoice> invoices = Arrays.asList(invoice(100.50, 12.25), invoice(49.50, 0));

        HostAnalyticsEngine.HostAnalytics analytics =
                HostAnalyticsEngine.compute(null, null, null, null, invoices, null);

        assertEquals(150.0, analytics.getRevenue(), 0.001);
        assertEquals(12.25, analytics.getRefundsAndAdjustments(), 0.001);
    }

    @Test
    public void cancellationRateCountsCancelledAndExpiredOverAllReservations() {
        List<Reservation> reservations = Arrays.asList(
                reservation("r1", "CANCELLED"),
                reservation("r2", "EXPIRED"),
                reservation("r3", "RESERVED"),
                reservation("r4", "COMPLETED"));

        HostAnalyticsEngine.HostAnalytics analytics =
                HostAnalyticsEngine.compute(null, null, null, reservations, null, null);

        assertEquals(50.0, analytics.getCancellationRatePercent(), 0.001);
        assertEquals(1, analytics.getActiveReservations());
    }

    @Test
    public void utilizationIsCappedAtAHundredPercent() {
        List<ChargingSession> sessions = new ArrayList<>();
        sessions.add(session("s1", "COMPLETED", "c1", 10.0, 0, 40L * 24L * 60L * 60L * 1000L));

        HostAnalyticsEngine.HostAnalytics analytics =
                HostAnalyticsEngine.compute(null, null, sessions, null, null, null);

        assertTrue(analytics.getUtilizationPercent() <= 100.0);
        assertEquals(0, analytics.getPorts());
    }
}
