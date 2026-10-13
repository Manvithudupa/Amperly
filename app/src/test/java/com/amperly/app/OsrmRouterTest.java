package com.amperly.app;

import com.amperly.app.core.routing.OsrmRouter;

import org.junit.Test;

import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

/**
 * The routing response parser and the offline fallback.
 *
 * <p>Worth testing without a network: a mistake in the GeoJSON axis order (longitude before
 * latitude) or in the metres/seconds conversion puts the route in the wrong place or reports a
 * wildly wrong travel time, and both are easy to get subtly wrong.
 */
public class OsrmRouterTest {

    private static final String OK_RESPONSE = "{"
            + "\"code\":\"Ok\","
            + "\"routes\":[{"
            + "\"distance\":1234.5,"
            + "\"duration\":300.0,"
            + "\"geometry\":{\"type\":\"LineString\",\"coordinates\":["
            + "[76.60,12.30],[76.61,12.31],[76.62,12.32]]}"
            + "}],"
            + "\"waypoints\":[]"
            + "}";

    @Test
    public void parsesDistanceAndDurationIntoKilometresAndMinutes() {
        OsrmRouter.Route route = OsrmRouter.parseRoute(OsrmRouter.TravelMode.DRIVING, OK_RESPONSE);
        assertEquals(1.2345, route.getDistanceKm(), 1e-6);
        assertEquals(5.0, route.getDurationMinutes(), 1e-6);
        assertFalse("a server response is a real route, not an estimate", route.isApproximate());
        assertEquals(OsrmRouter.TravelMode.DRIVING, route.getMode());
    }

    @Test
    public void readsCoordinatesAsLatitudeThenLongitude() {
        OsrmRouter.Route route = OsrmRouter.parseRoute(OsrmRouter.TravelMode.DRIVING, OK_RESPONSE);
        List<double[]> points = route.getPoints();
        assertEquals(3, points.size());
        // GeoJSON is [longitude, latitude]; the map expects [latitude, longitude].
        assertEquals(12.30, points.get(0)[0], 1e-6);
        assertEquals(76.60, points.get(0)[1], 1e-6);
        assertEquals(12.32, points.get(2)[0], 1e-6);
        assertEquals(76.62, points.get(2)[1], 1e-6);
    }

    @Test
    public void aServerErrorCodeIsReportedAsAFailure() {
        String response = "{\"code\":\"NoRoute\",\"message\":\"Impossible route between points\"}";
        try {
            OsrmRouter.parseRoute(OsrmRouter.TravelMode.WALKING, response);
            fail("expected a routing failure for a non-Ok code");
        } catch (IllegalStateException e) {
            assertTrue(e.getMessage().contains("Impossible route"));
        }
    }

    @Test
    public void anEmptyRouteListIsReportedAsAFailure() {
        try {
            OsrmRouter.parseRoute(OsrmRouter.TravelMode.DRIVING, "{\"code\":\"Ok\",\"routes\":[]}");
            fail("expected a routing failure with no routes");
        } catch (IllegalStateException expected) {
            // handled
        }
    }

    @Test
    public void walkingOnThePublicServerIsEstimatedRatherThanMisreportedAsDriving() {
        assertTrue(OsrmRouter.requiresLocalEstimate(OsrmRouter.TravelMode.WALKING, true));
        assertFalse(OsrmRouter.requiresLocalEstimate(OsrmRouter.TravelMode.DRIVING, true));
        // A configured server that carries the foot profile gets a real walking request.
        assertFalse(OsrmRouter.requiresLocalEstimate(OsrmRouter.TravelMode.WALKING, false));
    }

    @Test
    public void theEstimateSpansTheTwoEndpointsAndSaysItIsApproximate() {
        OsrmRouter.Route route = OsrmRouter.estimate(OsrmRouter.TravelMode.WALKING,
                12.30, 76.60, 12.40, 76.70);
        assertTrue(route.isApproximate());
        List<double[]> points = route.getPoints();
        assertTrue(points.size() > 2);
        assertEquals(12.30, points.get(0)[0], 1e-4);
        assertEquals(76.60, points.get(0)[1], 1e-4);
        double[] last = points.get(points.size() - 1);
        assertEquals(12.40, last[0], 1e-4);
        assertEquals(76.70, last[1], 1e-4);
        assertTrue("the straight-line distance must be positive", route.getDistanceKm() > 0);
    }
}
