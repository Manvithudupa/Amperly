package com.amperly.app;

import com.amperly.app.core.map.Mercator;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

/**
 * The map's projection.
 *
 * <p>Worth testing because an error here is invisible in code review and obvious to a user: a
 * half-tile offset or a wrong inverse puts every charger on the wrong street, and the pin the host
 * taps stores coordinates that are simply not where they touched.
 */
public class MercatorTest {

    private static final double TOLERANCE = 1e-6;

    @Test
    public void zoomZeroPutsTheOriginAtTheTopLeftCorner() {
        assertEquals(0.0, Mercator.worldX(-180.0, 0f), TOLERANCE);
        assertEquals(0.0, Mercator.worldY(Mercator.MAX_LATITUDE, 0f), TOLERANCE);
    }

    @Test
    public void zoomZeroPutsNullIslandInTheMiddleOfTheWorld() {
        float zoom = 0f;
        assertEquals(128.0, Mercator.worldX(0.0, zoom), TOLERANCE);
        assertEquals(128.0, Mercator.worldY(0.0, zoom), TOLERANCE);
        assertEquals(256.0, Mercator.worldSize(zoom), TOLERANCE);
    }

    @Test
    public void worldSizeDoublesWithEveryZoomLevel() {
        assertEquals(512.0, Mercator.worldSize(1f), TOLERANCE);
        assertEquals(2048.0, Mercator.worldSize(3f), TOLERANCE);
    }

    @Test
    public void tileCountIsTwoToTheZoom() {
        assertEquals(1, Mercator.tileCount(0));
        assertEquals(8, Mercator.tileCount(3));
        assertEquals(1 << 15, Mercator.tileCount(15));
    }

    @Test
    public void projectingThenUnprojectingReturnsTheSamePoint() {
        double[][] places = {
                {12.2958, 76.6394},   // Mysore
                {12.9141, 74.8560},   // Mangalore
                {-33.8688, 151.2093}, // Sydney, southern hemisphere
                {51.5074, -0.1278},   // London, west of Greenwich
                {0.0, 0.0},
        };
        for (double[] place : places) {
            for (float zoom : new float[]{3f, 9f, 12.75f, 18f}) {
                double x = Mercator.worldX(place[1], zoom);
                double y = Mercator.worldY(place[0], zoom);
                assertEquals("latitude " + place[0] + " at zoom " + zoom,
                        place[0], Mercator.latitudeAt(y, zoom), 1e-4);
                assertEquals("longitude " + place[1] + " at zoom " + zoom,
                        place[1], Mercator.longitudeAt(x, zoom), 1e-4);
            }
        }
    }

    @Test
    public void latitudesBeyondTheMercatorLimitAreClampedNotWrapped() {
        double north = Mercator.worldY(89.9, 5f);
        double limit = Mercator.worldY(Mercator.MAX_LATITUDE, 5f);
        assertEquals("the projection limit is the top edge of the world",
                0.0, limit, TOLERANCE);
        assertEquals(limit, north, TOLERANCE);

        double south = Mercator.worldY(-89.9, 5f);
        double southLimit = Mercator.worldY(-Mercator.MAX_LATITUDE, 5f);
        assertEquals("the projection limit is the bottom edge of the world",
                Mercator.worldSize(5f), southLimit, TOLERANCE);
        assertEquals(southLimit, south, TOLERANCE);
    }

    @Test
    public void latitudeIncreasesTowardsTheTopOfTheScreen() {
        // Smaller y is further north in screen coordinates, which is why the map inverts nothing.
        double mysoreY = Mercator.worldY(12.2958, 10f);
        double mangaloreY = Mercator.worldY(12.9141, 10f);
        assertTrue("Mangalore is north of Mysore and must have a smaller y",
                mangaloreY < mysoreY);
    }

    @Test
    public void aDegreeOfLatitudeCoversMoreScreenPixelsThanADegreeOfLongitudeInIndia() {
        // Mercator stretches latitude away from the equator; at 12 degrees north that is about
        // 1/cos(12 deg) = 1.02, and getting this backwards is a classic projection bug.
        float zoom = 12f;
        double oneDegreeOfLongitude = Mercator.worldX(77.0, zoom) - Mercator.worldX(76.0, zoom);
        double oneDegreeOfLatitude = Mercator.worldY(12.0, zoom) - Mercator.worldY(13.0, zoom);
        assertTrue(oneDegreeOfLatitude > oneDegreeOfLongitude);
    }
}
