package com.amperly.app.core.common;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/**
 * The prototype resolves route endpoints from a small place list instead of a routing API. Anything
 * unknown falls back to the pilot corridor, and the planner records that assumption.
 */
public final class PilotPlaces {

    private static final Map<String, double[]> PLACES = new HashMap<>();

    static {
        put("mysore", 12.2958, 76.6394);
        put("mysuru", 12.2958, 76.6394);
        put("mangalore", 12.9141, 74.8560);
        put("mangaluru", 12.9141, 74.8560);
        put("bengaluru", 12.9716, 77.5946);
        put("bangalore", 12.9716, 77.5946);
        put("hassan", 13.0072, 76.0962);
        put("sakleshpur", 12.9417, 75.7851);
        put("madikeri", 12.4244, 75.7382);
        put("kodagu", 12.4244, 75.7382);
        put("coorg", 12.4244, 75.7382);
        put("udupi", 13.3409, 74.7421);
        put("chikmagalur", 13.3161, 75.7720);
    }

    private PilotPlaces() {
    }

    private static void put(String key, double lat, double lng) {
        PLACES.put(key, new double[]{lat, lng});
    }

    /** @return {lat, lng} or null when the place is not in the pilot list. */
    public static double[] resolve(String name) {
        if (name == null) {
            return null;
        }
        String key = name.trim().toLowerCase(Locale.US);
        double[] direct = PLACES.get(key);
        if (direct != null) {
            return direct;
        }
        for (Map.Entry<String, double[]> entry : PLACES.entrySet()) {
            if (key.contains(entry.getKey())) {
                return entry.getValue();
            }
        }
        return null;
    }

    public static double[] resolveOrPilot(String name) {
        double[] resolved = resolve(name);
        if (resolved != null) {
            return resolved;
        }
        return new double[]{AppConstants.PILOT_CENTER_LAT, AppConstants.PILOT_CENTER_LNG};
    }

    public static boolean isKnown(String name) {
        return resolve(name) != null;
    }
}
