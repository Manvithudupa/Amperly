package com.amperly.app;

import com.amperly.app.core.routing.DirectionsRoute;
import com.amperly.app.core.routing.RequestThrottle;
import com.amperly.app.core.routing.RouteCache;

import org.junit.Test;

import java.util.ArrayList;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;

/**
 * The two guards that keep the free Geoapify plan usable: a ten-minute route cache and a per-second
 * request limiter.
 *
 * <p>Both take the clock as a parameter, so these tests are exact rather than timing-dependent.
 */
public class RouteCacheTest {

    private DirectionsRoute route(String label) {
        return new DirectionsRoute(new ArrayList<>(), 1.0, 1, 0, label, label, new ArrayList<>(),
                false);
    }

    @Test
    public void aRouteIsReusedInsideItsTimeToLive() {
        RouteCache cache = new RouteCache(20, 10_000L);
        DirectionsRoute route = route("first");
        cache.put("drive:1,2:3,4", route, 1_000L);
        assertSame(route, cache.get("drive:1,2:3,4", 10_999L));
    }

    @Test
    public void anExpiredRouteIsNotReused() {
        RouteCache cache = new RouteCache(20, 10_000L);
        cache.put("drive:1,2:3,4", route("first"), 1_000L);
        assertNull(cache.get("drive:1,2:3,4", 11_000L));
        assertEquals("an expired entry is dropped, not kept forever", 0, cache.size());
    }

    @Test
    public void theLeastRecentlyUsedRouteIsEvicted() {
        RouteCache cache = new RouteCache(2, 60_000L);
        cache.put("a", route("a"), 0L);
        cache.put("b", route("b"), 0L);
        // Touching "a" makes "b" the least recently used.
        cache.get("a", 0L);
        cache.put("c", route("c"), 0L);
        assertEquals(2, cache.size());
        assertNull("b was the least recently used", cache.get("b", 0L));
        assertNotNull(cache.get("a", 0L));
        assertNotNull(cache.get("c", 0L));
    }

    @Test
    public void nullKeysAndRoutesAreIgnored() {
        RouteCache cache = new RouteCache();
        cache.put(null, route("x"), 0L);
        cache.put("k", null, 0L);
        assertEquals(0, cache.size());
        assertNull(cache.get(null, 0L));
    }

    @Test
    public void fourRequestsStartImmediatelyAndTheFifthWaits() {
        RequestThrottle throttle = new RequestThrottle(4, 1_000L);
        for (int i = 0; i < 4; i++) {
            assertEquals("request " + i + " may start at once", 0L, throttle.reserveDelayMs(0L));
        }
        long delay = throttle.reserveDelayMs(0L);
        assertTrue("the fifth request in the same second must wait", delay > 0L);
        assertEquals(1_000L, delay);
    }

    @Test
    public void theWindowRollsForward() {
        RequestThrottle throttle = new RequestThrottle(4, 1_000L);
        for (int i = 0; i < 4; i++) {
            throttle.reserveDelayMs(0L);
        }
        assertEquals(0L, throttle.reserveDelayMs(1_000L));
        assertEquals("the previous second's starts have aged out of the window", 1,
                throttle.inWindow(1_000L));
    }
}
