package com.amperly.app;

import com.amperly.app.engine.routing.TripTimeEngine;

import org.junit.Test;

import static org.junit.Assert.assertEquals;

/** Driving, detour and charging time add up the way the route card promises. */
public class TripTimeEngineTest {

    @Test
    public void driveDetourAndChargingAreSummed() {
        TripTimeEngine.TripTimeBreakdown breakdown =
                TripTimeEngine.calculateBreakdown(120.0, 10, 25);

        assertEquals(120, breakdown.getDrivingMinutes());
        assertEquals(10, breakdown.getDetourMinutes());
        assertEquals(25, breakdown.getChargingMinutes());
        assertEquals(155, breakdown.getTotalJourneyMinutes());
    }

    @Test
    public void zeroDistanceTakesNoDrivingTime() {
        TripTimeEngine.TripTimeBreakdown breakdown =
                TripTimeEngine.calculateBreakdown(0, 0, 0);

        assertEquals(0, breakdown.getDrivingMinutes());
        assertEquals(0, breakdown.getTotalJourneyMinutes());
    }

    @Test
    public void minutesAreRoundedToTheNearestWholeMinute() {
        assertEquals(43, TripTimeEngine.calculateBreakdown(42.5, 0, 0).getDrivingMinutes());
        assertEquals(0, TripTimeEngine.calculateBreakdown(0.4, 0, 0).getDrivingMinutes());
        assertEquals(1, TripTimeEngine.calculateBreakdown(0.6, 0, 0).getDrivingMinutes());
    }

    @Test
    public void aShortHopStillCarriesItsChargingStop() {
        TripTimeEngine.TripTimeBreakdown breakdown =
                TripTimeEngine.calculateBreakdown(1.0, 3, 40);

        assertEquals(1, breakdown.getDrivingMinutes());
        assertEquals(44, breakdown.getTotalJourneyMinutes());
    }
}
