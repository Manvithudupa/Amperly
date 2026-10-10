package com.amperly.app;

import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.engine.billing.BillingEngine;
import com.amperly.app.engine.routing.RoutePlannerEngine;
import com.amperly.app.engine.soc.SoCEstimatorEngine;

import org.junit.Test;

import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

public class EngineUnitTest {

    @Test
    public void testRoutePlannerEngine() {
        Vehicle vehicle = new Vehicle(
                "v1", "u1", "Tata", "Nexon EV", "Max",
                2023, 40.5, "CCS_2_DC", 7.2, 30.0, 6.5, 2.0, 15, 80, "KA09EV1234"
        );

        List<ChargerStation> candidateStations = new ArrayList<>();
        candidateStations.add(new ChargerStation(
                "s1", "h1", "Highway Hub Charger", "Mysore-Mangalore Rd",
                12.3, 76.6, "COMMERCIAL", "24/7", 18.0, 5.0, 4.0, "LEVEL_1", true, false, 4.8, System.currentTimeMillis()
        ));

        RoutePlannerEngine.RoutePlanResult result = RoutePlannerEngine.planRoute(
                "Mysore", "Mangalore", 140.0, 100, vehicle, candidateStations
        );

        assertNotNull(result);
        assertEquals("Mysore", result.getOrigin());
        assertEquals("Mangalore", result.getDestination());
        assertEquals(140.0, result.getTotalDistanceKm(), 0.1);
        assertNotNull(result.getRecommendedStop());
        assertTrue(result.getRecommendedStop().isReachable());
    }

    @Test
    public void testSoCEstimatorEngineOverride() {
        Vehicle vehicle = new Vehicle(
                "v1", "u1", "Tata", "Nexon EV", "Max",
                2023, 40.5, "CCS_2_DC", 7.2, 30.0, 6.5, 2.0, 15, 80, "KA09EV1234"
        );

        List<ChargerStation> candidateStations = new ArrayList<>();
        candidateStations.add(new ChargerStation(
                "s1", "h1", "Highway Hub Charger", "Mysore-Mangalore Rd",
                12.3, 76.6, "COMMERCIAL", "24/7", 18.0, 5.0, 4.0, "LEVEL_1", true, false, 4.8, System.currentTimeMillis()
        ));

        SoCEstimatorEngine.RecalculationResult recalculation = SoCEstimatorEngine.applyAuthoritativeSocOverride(
                "v1", "trip_101", 35, 25, 60.0, 80.0,
                12.3, 76.6, vehicle, candidateStations
        );

        assertNotNull(recalculation);
        assertEquals(25, recalculation.getActualDashboardSoc());
        assertTrue(recalculation.isWasOverrideApplied());
        assertNotNull(recalculation.getRecommendedNextCharger());
    }

    @Test
    public void testBillingEngineCalculation() {
        ChargerStation station = new ChargerStation(
                "st_campus_1", "user_campus_admin", "ABC College Campus Charger",
                "Gate 2 Parking, ABC Campus, Mysore", 12.301, 76.652, "CAMPUS",
                "08:00 - 20:00", 18.0, 5.0, 4.0, "LEVEL_1", true, false, 4.9, System.currentTimeMillis()
        );

        double startMeter = 100.0;
        double endMeter = 110.0;

        BillingEngine.BillingCalculationResult result = BillingEngine.calculateBill(
                "sess_101", "cons_1", "host_1", station, startMeter, endMeter
        );

        assertTrue(result.isValid());
        assertEquals(10.0, result.getVerifiedKwh(), 0.01);
        assertEquals(180.0, result.getEnergyCharge(), 0.01);
        assertEquals(5.0, result.getServiceFee(), 0.01);
        assertEquals(4.0, result.getGatewayFee(), 0.01);
        assertEquals(189.0, result.getFinalTotal(), 0.01);
        assertNotNull(result.getInvoice());
    }
}
