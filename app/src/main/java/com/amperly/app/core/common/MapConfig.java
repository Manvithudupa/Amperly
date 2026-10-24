package com.amperly.app.core.common;

import android.content.Context;

import androidx.annotation.NonNull;

import com.amperly.app.BuildConfig;
import com.amperly.app.R;

/**
 * One place that answers "is the map service configured?".
 *
 * <p>The map is drawn by MapLibre Native from an OpenStreetMap-based vector style hosted by
 * Geoapify, and the address search and the routes are plain HTTPS calls to the same service. All
 * three need one key, which lives in {@code local.properties} (gitignored) or an environment
 * variable and reaches the app as {@link BuildConfig#GEOAPIFY_API_KEY}. Nothing about the key is
 * written into Java or XML by hand.
 *
 * <p>Every screen that needs the map or a route asks this class first. When the key is missing the
 * screen shows an actionable setup notice instead of a blank, silently broken map.
 */
public final class MapConfig {

    /**
     * Geoapify's OpenStreetMap-based vector style, used when MAP_STYLE_URL is not set.
     *
     * <p>It is served by Geoapify, never by {@code tile.openstreetmap.org}: the OpenStreetMap
     * Foundation's own tile servers forbid use by a shipped application.
     */
    private static final String DEFAULT_STYLE_URL =
            "https://maps.geoapify.com/v1/styles/osm-bright/style.json";

    private MapConfig() {
    }

    /** True when a non-blank Geoapify key was injected at build time. */
    public static boolean isConfigured() {
        return isEnabled();
    }

    /** The same answer under the name the map panel reads most naturally. */
    public static boolean isEnabled() {
        return BuildConfig.GEOAPIFY_ENABLED && !apiKey().isEmpty();
    }

    /** The injected key, never null (blank when unset). */
    @NonNull
    public static String apiKey() {
        String key = BuildConfig.GEOAPIFY_API_KEY;
        return key == null ? "" : key.trim();
    }

    /**
     * The vector style to render, with the key already appended. A blank MAP_STYLE_URL means the
     * Geoapify OSM-Bright style; any other MapLibre-compatible style URL is used as given.
     */
    @NonNull
    public static String styleUrl() {
        String configured = BuildConfig.MAP_STYLE_URL;
        String base = configured == null || configured.trim().isEmpty()
                ? DEFAULT_STYLE_URL : configured.trim();
        return withKey(base);
    }

    /**
     * Adds {@code apiKey=<key>} to a URL, keeping any query string it already carries.
     *
     * <p>Both shapes occur in practice: the default style above has no query, while a
     * MAP_STYLE_URL copied from the Geoapify dashboard often already has parameters.
     */
    @NonNull
    public static String withKey(@NonNull String url) {
        if (url.isEmpty()) {
            return url;
        }
        String key = apiKey();
        if (key.isEmpty() || url.contains("apiKey=")) {
            return url;
        }
        return url + (url.contains("?") ? "&" : "?") + "apiKey=" + key;
    }

    /** A short, user-facing message explaining how to fix an unconfigured build. */
    @NonNull
    public static String setupMessage(@NonNull Context context) {
        return context.getString(R.string.map_setup_required);
    }
}
