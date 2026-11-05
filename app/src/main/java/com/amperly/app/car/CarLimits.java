package com.amperly.app.car;

/**
 * Pure sizing rules for the projected car experience.
 *
 * <p>The host decides how many rows it can draw and reports that through
 * {@code ConstraintManager}. This class contains only the arithmetic, with no Android types, so the
 * rules can be unit tested without a device.
 */
public final class CarLimits {

    /** The main map screen never carries more than four rows, whatever the host allows. */
    public static final int MAIN_PANE_MAX_ROWS = 4;

    /** Car API level that introduced MapWithContentTemplate. */
    public static final int MAP_WITH_CONTENT_API_LEVEL = 7;

    /** Dashboard battery values offered on the car display: eight large, tappable choices. */
    private static final int[] BATTERY_OPTIONS = {10, 20, 30, 40, 50, 60, 80, 90};

    private CarLimits() {
    }

    /**
     * How many rows a list may actually contain.
     *
     * @param hostLimit the limit reported by the host, or a non-positive value when unavailable
     * @param desired   the maximum this screen is willing to draw
     * @return a value between 0 and {@code desired}
     */
    public static int listLimit(int hostLimit, int desired) {
        if (desired <= 0) {
            return 0;
        }
        if (hostLimit <= 0) {
            return desired;
        }
        return Math.min(hostLimit, desired);
    }

    /** True when the host can draw a map next to the content pane. */
    public static boolean supportsMapWithContent(int carAppApiLevel) {
        return carAppApiLevel >= MAP_WITH_CONTENT_API_LEVEL;
    }

    /** The battery values in ascending order. The array is copied so callers cannot mutate it. */
    public static int[] batteryOptions() {
        return BATTERY_OPTIONS.clone();
    }
}
