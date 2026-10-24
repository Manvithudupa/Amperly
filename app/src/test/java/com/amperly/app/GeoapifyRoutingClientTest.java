package com.amperly.app;

import com.amperly.app.core.common.GeoapifyErrors;
import com.amperly.app.core.common.UserMessages;
import com.amperly.app.core.routing.DirectionsRoute;
import com.amperly.app.core.routing.GeoapifyRoutingClient;

import org.junit.Test;

import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

/**
 * The Geoapify routing response parser and the failure mapping.
 *
 * <p>Worth testing without a network: GeoJSON stores coordinates longitude-first while every other
 * coordinate in the app is latitude-first, a multi-leg route repeats its joint point, and the
 * metres/seconds conversions are easy to get subtly wrong. Each mistake would show up only as a
 * route in the wrong hemisphere or a wrong ETA on screen.
 */
public class GeoapifyRoutingClientTest {

    /**
     * Two legs, so the joint at (12.35, 76.65) appears at the end of the first and the start of the
     * second. Coordinates are GeoJSON order: [lon, lat].
     */
    private static final String OK_RESPONSE = "{"
            + "\"type\":\"FeatureCollection\","
            + "\"features\":[{"
            + "\"type\":\"Feature\","
            + "\"properties\":{"
            + "\"distance\":12345.0,"
            + "\"time\":900.0,"
            + "\"legs\":["
            + "{\"steps\":["
            + "{\"distance\":100.0,\"time\":20.0,\"from_index\":0,\"to_index\":1,"
            + "\"instruction\":{\"text\":\"Head north on Main St\",\"type\":\"turn\"}},"
            + "{\"distance\":200.0,\"time\":40.0,\"from_index\":1,\"to_index\":2,"
            + "\"instruction\":{\"text\":\"Turn right toward the campus gate\",\"type\":\"turn\"}}"
            + "]},"
            + "{\"steps\":["
            + "{\"distance\":300.0,\"time\":60.0,\"from_index\":2,\"to_index\":3,"
            + "\"instruction\":{\"text\":\"Continue straight\",\"type\":\"continue\"}}"
            + "]}"
            + "]},"
            + "\"geometry\":{\"type\":\"MultiLineString\",\"coordinates\":["
            + "[[76.60,12.30],[76.62,12.32],[76.65,12.35]],"
            + "[[76.65,12.35],[76.68,12.38],[76.70,12.40]]"
            + "]}"
            + "}]}";

    @Test
    public void theTravelModesAskGeoapifyForDriveAndWalk() {
        assertEquals("drive", GeoapifyRoutingClient.TravelMode.DRIVING.requestMode());
        assertEquals("walk", GeoapifyRoutingClient.TravelMode.WALKING.requestMode());
        assertEquals("driving", GeoapifyRoutingClient.TravelMode.DRIVING.label());
        assertEquals("walking", GeoapifyRoutingClient.TravelMode.WALKING.label());
        assertFalse("Geoapify publishes no live-traffic duration",
                GeoapifyRoutingClient.TravelMode.DRIVING.isTrafficAware());
        assertTrue(GeoapifyRoutingClient.TravelMode.DRIVING.estimateSpeedKmh()
                > GeoapifyRoutingClient.TravelMode.WALKING.estimateSpeedKmh());
    }

    @Test
    public void convertsMetresAndSecondsAndLeavesTrafficAtZero() {
        DirectionsRoute route = GeoapifyRoutingClient.parseRoute(
                GeoapifyRoutingClient.TravelMode.DRIVING, OK_RESPONSE);
        assertEquals(12.345, route.getDistanceKm(), 1e-6);
        assertEquals(15, route.getDurationMinutes());
        assertEquals("no traffic duration is invented", 0, route.getDurationInTrafficMinutes());
        assertEquals(15, route.getEffectiveDurationMinutes());
        assertFalse("a real routing response is never approximate", route.isApproximate());
    }

    @Test
    public void flipsGeoJsonCoordinateOrderToLatitudeThenLongitude() {
        DirectionsRoute route = GeoapifyRoutingClient.parseRoute(
                GeoapifyRoutingClient.TravelMode.DRIVING, OK_RESPONSE);
        // Three points per leg, with the repeated joint removed: 5 in total.
        assertEquals(5, route.getPoints().size());
        assertEquals(12.30, route.getOriginLat(), 1e-5);
        assertEquals(76.60, route.getOriginLng(), 1e-5);
        assertEquals(12.40, route.getDestinationLat(), 1e-5);
        assertEquals(76.70, route.getDestinationLng(), 1e-5);
    }

    @Test
    public void readsEveryLegsStepsAndPlacesThemOnTheLine() {
        DirectionsRoute route = GeoapifyRoutingClient.parseRoute(
                GeoapifyRoutingClient.TravelMode.DRIVING, OK_RESPONSE);
        List<DirectionsRoute.Step> steps = route.getSteps();
        assertEquals(3, steps.size());
        assertEquals("Head north on Main St", steps.get(0).getInstruction());
        assertEquals("turn", steps.get(0).getManeuver());
        assertEquals("100 m", steps.get(0).getDistanceText());
        assertEquals("1 min", steps.get(0).getDurationText());
        // from_index 2 on the flattened line is the joint point.
        assertEquals(12.35, steps.get(2).getStartLat(), 1e-5);
        assertEquals(76.65, steps.get(2).getStartLng(), 1e-5);
    }

    @Test
    public void aLineStringRouteIsAcceptedToo() {
        String lineString = "{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\","
                + "\"properties\":{\"distance\":1000.0,\"time\":120.0,\"legs\":[]},"
                + "\"geometry\":{\"type\":\"LineString\","
                + "\"coordinates\":[[76.60,12.30],[76.70,12.40]]}}]}";
        DirectionsRoute route = GeoapifyRoutingClient.parseRoute(
                GeoapifyRoutingClient.TravelMode.WALKING, lineString);
        assertEquals(2, route.getPoints().size());
        assertEquals(1.0, route.getDistanceKm(), 1e-6);
        assertEquals(2, route.getDurationMinutes());
        assertTrue(route.getSteps().isEmpty());
    }

    @Test
    public void anEmptyFeatureCollectionIsReportedAsNoRoute() {
        try {
            GeoapifyRoutingClient.parseRoute(GeoapifyRoutingClient.TravelMode.DRIVING,
                    "{\"type\":\"FeatureCollection\",\"features\":[]}");
            fail("expected a failure when Geoapify returns no route");
        } catch (IllegalStateException e) {
            assertTrue(e.getMessage().toLowerCase().contains("no route"));
        }
    }

    @Test
    public void aRouteWithNoGeometryIsRejected() {
        try {
            GeoapifyRoutingClient.parseRoute(GeoapifyRoutingClient.TravelMode.DRIVING,
                    "{\"type\":\"FeatureCollection\",\"features\":[{\"properties\":"
                            + "{\"distance\":10,\"time\":10},\"geometry\":"
                            + "{\"type\":\"LineString\",\"coordinates\":[]}}]}");
            fail("expected a failure for a route with no geometry");
        } catch (IllegalStateException expected) {
            // handled
        }
    }

    @Test
    public void httpFailuresMapToFriendlyKinds() {
        assertEquals(UserMessages.Kind.MAP_UNAVAILABLE,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(401)));
        assertEquals(UserMessages.Kind.MAP_UNAVAILABLE,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(403)));
        assertEquals(UserMessages.Kind.RATE_LIMIT,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(429)));
        assertEquals(UserMessages.Kind.SERVER,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(503)));
        assertEquals(UserMessages.Kind.VALIDATION,
                UserMessages.classify(-1, GeoapifyErrors.httpFailure(400)));
    }

    @Test
    public void theStraightLineFallbackIsAlwaysLabelledApproximate() {
        DirectionsRoute route = DirectionsRoute.straightLineEstimate(12.30, 76.60, 12.40, 76.70, 45.0);
        assertTrue(route.isApproximate());
        assertTrue(route.getPoints().size() > 2);
        assertTrue(route.getDistanceKm() > 0);
        assertEquals(12.30, route.getOriginLat(), 1e-4);
        assertEquals(12.40, route.getDestinationLat(), 1e-4);
        assertTrue(route.getEffectiveDurationMinutes() > 0);
        assertFalse("the fallback must not claim a provider route",
                route.getSteps().get(0).getInstruction().contains("Geoapify"));
    }
}
