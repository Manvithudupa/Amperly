package com.amperly.app.car;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/** Rules for when the static map is fetched again, and how its viewport is fitted. */
public class CarMapGeometryTest {

    @Test
    public void theFirstImageAlwaysFetches() {
        assertTrue(CarMapGeometry.shouldRefetch(50_000, 0, 0, false, false));
    }

    @Test
    public void aShortMoveDoesNotRefetch() {
        assertFalse(CarMapGeometry.shouldRefetch(100_000, 80_000, 149.0, false, false));
    }

    @Test
    public void aMoveOverOneHundredAndFiftyMetresRefetches() {
        assertTrue(CarMapGeometry.shouldRefetch(100_000, 90_000, 151.0, false, false));
    }

    @Test
    public void aMoveWaitsForTheTenSecondFloor() {
        assertFalse(CarMapGeometry.shouldRefetch(100_000, 95_000, 500.0, false, false));
    }

    @Test
    public void changedPinsRefetchOnlyAfterTheFloor() {
        assertFalse(CarMapGeometry.shouldRefetch(100_000, 95_000, 0, true, false));
        assertTrue(CarMapGeometry.shouldRefetch(100_000, 90_000, 0, true, false));
    }

    @Test
    public void aZoomChangeRefetches() {
        assertTrue(CarMapGeometry.shouldRefetch(100_000, 90_000, 0, false, true));
    }

    @Test
    public void aWideTripZoomsOutFurtherThanATightOne() {
        int wide = CarMapGeometry.zoomForBounds(8, 68, 35, 97, 800, 480, 80);
        int tight = CarMapGeometry.zoomForBounds(12.90, 77.50, 13.00, 77.60, 800, 480, 80);
        assertTrue(wide < tight);
        assertTrue(wide >= CarMapGeometry.MIN_ZOOM);
        assertTrue(tight <= CarMapGeometry.MAX_ZOOM);
    }

    @Test
    public void aSinglePointUsesStreetLevelZoom() {
        assertEquals(CarMapGeometry.DRIVER_ZOOM,
                CarMapGeometry.zoomForBounds(12.90, 77.50, 12.90, 77.50, 800, 480, 40));
    }

    @Test
    public void theCenterOfABoundsIsTheMiddleOfTheBox() {
        double[] center = CarMapGeometry.centerOfBounds(10, 70, 20, 80);
        assertEquals(15.0, center[0], 0.1);
        assertEquals(75.0, center[1], 0.01);
    }

    @Test
    public void oneDegreeOfLatitudeIsAboutOneHundredAndElevenKilometres() {
        assertEquals(111_195, CarMapGeometry.distanceMeters(0, 0, 1, 0), 500);
        assertEquals(0, CarMapGeometry.distanceMeters(12, 77, 12, 77), 0.001);
    }

    @Test
    public void impossibleCoordinatesAreRejected() {
        assertFalse(CarMapGeometry.isValidCoordinate(91, 77));
        assertFalse(CarMapGeometry.isValidCoordinate(12, 181));
        assertFalse(CarMapGeometry.isValidCoordinate(Double.NaN, 77));
        assertTrue(CarMapGeometry.isValidCoordinate(12.9, 77.5));
    }
}
