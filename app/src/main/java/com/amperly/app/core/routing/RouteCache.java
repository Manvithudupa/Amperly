package com.amperly.app.core.routing;

import androidx.annotation.Nullable;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * A small, time-limited cache of calculated routes.
 *
 * <p>Re-planning the same journey (a battery correction, a preference change, a screen reopened)
 * used to ask the routing service again every time. Geoapify's free plan allows roughly 3,000
 * credits a day, so repeating an identical request is both wasteful and, on a busy day, the reason
 * a driver is told the routing service is out of credits.
 *
 * <p>Keyed by mode plus coordinates rounded to four decimals (about 11 m), holding at most the
 * newest 20 entries for ten minutes. It lives in memory only and is never written to disk.
 *
 * <p>Pure Java and clock-injected, so its eviction and expiry rules can be unit tested.
 */
public final class RouteCache {

    public static final int DEFAULT_CAPACITY = 20;
    public static final long DEFAULT_TTL_MS = 10L * 60L * 1000L;

    private static final class CachedRoute {
        private final DirectionsRoute route;
        private final long expiresAtMs;

        private CachedRoute(DirectionsRoute route, long expiresAtMs) {
            this.route = route;
            this.expiresAtMs = expiresAtMs;
        }
    }

    private final int capacity;
    private final long ttlMs;
    private final LinkedHashMap<String, CachedRoute> entries;

    public RouteCache() {
        this(DEFAULT_CAPACITY, DEFAULT_TTL_MS);
    }

    public RouteCache(int capacity, long ttlMs) {
        this.capacity = Math.max(1, capacity);
        this.ttlMs = Math.max(1L, ttlMs);
        this.entries = new LinkedHashMap<String, CachedRoute>(16, 0.75f, true) {
            @Override
            protected boolean removeEldestEntry(Map.Entry<String, CachedRoute> eldest) {
                return size() > RouteCache.this.capacity;
            }
        };
    }

    /** The cached route for a key, or null when it is absent or older than the time to live. */
    @Nullable
    public synchronized DirectionsRoute get(@Nullable String key, long nowMs) {
        if (key == null) {
            return null;
        }
        CachedRoute entry = entries.get(key);
        if (entry == null) {
            return null;
        }
        if (entry.expiresAtMs <= nowMs) {
            entries.remove(key);
            return null;
        }
        return entry.route;
    }

    /** Stores a route, replacing any older entry for the same key. */
    public synchronized void put(@Nullable String key, @Nullable DirectionsRoute route, long nowMs) {
        if (key == null || route == null) {
            return;
        }
        entries.put(key, new CachedRoute(route, nowMs + ttlMs));
    }

    public synchronized int size() {
        return entries.size();
    }

    public synchronized void clear() {
        entries.clear();
    }
}
