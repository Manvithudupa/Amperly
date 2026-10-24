package com.amperly.app.core.routing;

import java.util.ArrayDeque;
import java.util.Deque;

/**
 * Caps how many routing requests may start per second.
 *
 * <p>Geoapify's free plan allows about five requests per second. The planner can fire a burst (a
 * reroute, the corridor search and a preference change can land together), and a burst either gets
 * a 429 that the driver reads as "too many requests" or silently spends the day's credits. Four a
 * second leaves headroom.
 *
 * <p>The clock is passed in so the rule is deterministic in a test.
 */
public final class RequestThrottle {

    public static final int DEFAULT_MAX_PER_WINDOW = 4;
    public static final long DEFAULT_WINDOW_MS = 1000L;

    private final int maxPerWindow;
    private final long windowMs;
    private final Deque<Long> starts = new ArrayDeque<>();

    public RequestThrottle() {
        this(DEFAULT_MAX_PER_WINDOW, DEFAULT_WINDOW_MS);
    }

    public RequestThrottle(int maxPerWindow, long windowMs) {
        this.maxPerWindow = Math.max(1, maxPerWindow);
        this.windowMs = Math.max(1L, windowMs);
    }

    /**
     * Reserves a start slot.
     *
     * @return how long the caller must wait before starting, in milliseconds; 0 when it may start
     *         immediately. The slot is reserved either way, so concurrent callers queue in order.
     */
    public synchronized long reserveDelayMs(long nowMs) {
        prune(nowMs);
        if (starts.size() < maxPerWindow) {
            starts.addLast(nowMs);
            return 0L;
        }
        Long oldest = starts.peekFirst();
        long startAt = oldest == null ? nowMs : Math.max(nowMs, oldest + windowMs);
        starts.addLast(startAt);
        return startAt - nowMs;
    }

    /** How many starts are currently counted in the window. */
    public synchronized int inWindow(long nowMs) {
        prune(nowMs);
        return starts.size();
    }

    private void prune(long nowMs) {
        while (!starts.isEmpty() && starts.peekFirst() <= nowMs - windowMs) {
            starts.pollFirst();
        }
    }
}
