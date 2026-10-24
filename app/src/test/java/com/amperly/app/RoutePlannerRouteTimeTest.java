package com.amperly.app;

import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.engine.routing.RoutePlannerEngine;

import org.junit.Test;

import java.util.ArrayList;
import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

/**
 * The planner must use the drive time the routing service measured, not a flat average-speed guess.
 *
 * <p>Without this the total journey time on the route screen would quietly disagree with the route
 * ETA the driver just saw. When no measured time exists (an estimate, or an offline fallback) the
 * planner must say so instead of presenting the guess as a measurement.
 */
public class RoutePlannerRouteTimeTest {

    private ChargerStation station(double lat, double lng) {
        return ChargerStation.create("st_" + lat, "host_1", "Host", "Charger " + lat, "Address",
                lat, lng, "CAMPUS", "24/7", 18.0, 5.0, 4.0, "LEVEL_1", "TYPE_2_AC", 7.2, 2,
                "Contact the host.", 4.5);
    }

    private Vehicle vehicle() {
        return new Vehicle("veh_1", "user_1", "Tata", "Nexon EV", "Max", 2023, 40.5,
                "CCS_2_DC", 7.2, 30.0, 6.5, 96.0, 0.0, 15, 80, "KA09EV1234");
    }

    @Test
    public void anAverageSpeedEstimateIsUsedWhenTheProviderHasNoTime() {
        List<ChargerStation> stations = new ArrayList<>();
        stations.add(station(12.4, 76.7));
        RoutePlannerEngine.RoutePlanResult result = RoutePlannerEngine.planRoute("A", "B",
                12.30, 76.60, 12.40, 76.70, 90.0, 15.0, 60, true, false,
                RoutePlannerEngine.PREF_FASTEST, vehicle(), stations);
        // 90 km at the 45 km/h planning speed is about 120 minutes.
        assertEquals(120, result.getDriveMinutes());
        assertTrue(result.getAssumptions().get(0).contains("average"));
    }

    @Test
    public void theMeasuredDriveTimeOverridesTheEstimate() {
        List<ChargerStation> stations = new ArrayList<>();
        stations.add(station(12.4, 76.7));
        RoutePlannerEngine.RoutePlanResult result = RoutePlannerEngine.planRoute("A", "B",
                12.30, 76.60, 12.40, 76.70, 90.0, 15.0, 60, true, false,
                RoutePlannerEngine.PREF_FASTEST, vehicle(), stations, 75);
        assertEquals(75, result.getDriveMinutes());
        assertTrue(result.getAssumptions().get(0).contains("Geoapify"));
        assertTrue("no live traffic figure may be claimed",
                result.getAssumptions().get(0).contains("no live traffic"));
    }

    @Test
    public void theTotalJourneyAddsDriveDetourAndCharging() {
        List<ChargerStation> stations = new ArrayList<>();
        stations.add(station(12.4, 76.7));
        RoutePlannerEngine.RoutePlanResult result = RoutePlannerEngine.planRoute("A", "B",
                12.30, 76.60, 12.40, 76.70, 90.0, 15.0, 30, true, false,
                RoutePlannerEngine.PREF_FASTEST, vehicle(), stations, 75);
        assertEquals(result.getDriveMinutes() + result.getDetourMinutes()
                + result.getChargingMinutes(), result.getTotalJourneyMinutes());
    }
}
