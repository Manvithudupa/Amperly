package com.amperly.app.core.map;

import androidx.annotation.NonNull;

import com.amperly.app.BuildConfig;

/**
 * Where the map's tiles come from, in one place.
 *
 * <p>OpenStreetMap's public tile server is the default because it needs no account, no key and no
 * billing relationship. A deployment that would rather not use it points {@code OSM_TILE_URL} in
 * {@code local.properties} at its own OSM-compatible server; nothing else in the app changes.
 */
public final class MapTiles {

    private static final String DEFAULT_TILE_URL =
            "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

    private MapTiles() {
    }

    /** An OSM-style URL template containing {@code {z}}, {@code {x}} and {@code {y}}. */
    @NonNull
    public static String tileUrlTemplate() {
        String configured = BuildConfig.OSM_TILE_URL;
        if (configured == null || configured.trim().isEmpty()) {
            return DEFAULT_TILE_URL;
        }
        return configured.trim();
    }

    /**
     * OpenStreetMap's tile usage policy requires a User-Agent that identifies the application, so
     * this is not optional. {@code OSM_USER_AGENT} overrides it for a self-hosted server.
     */
    @NonNull
    public static String userAgent() {
        String configured = BuildConfig.OSM_USER_AGENT;
        if (configured != null && !configured.trim().isEmpty()) {
            return configured.trim();
        }
        return BuildConfig.APPLICATION_ID + "/" + BuildConfig.VERSION_NAME
                + " (Amperly Android)";
    }
}
