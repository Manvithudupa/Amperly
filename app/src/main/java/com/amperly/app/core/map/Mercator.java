package com.amperly.app.core.map;

/**
 * The Web Mercator projection the map tiles are cut in.
 *
 * <p>Kept separate from {@link OsmTileMapView} on purpose: this is the part that is easy to get
 * subtly wrong (a half-tile offset puts every charger in the wrong place) and it is pure
 * arithmetic, so it can be unit tested without an Android device.
 *
 * <p>At zoom {@code z} the world is {@code 256 * 2^z} pixels square, {@code (0,0)} is the top-left
 * corner at 85.05&deg;N / 180&deg;W, and latitude cannot be represented past &plusmn;85.05112878&deg;.
 */
public final class Mercator {

    /** Tile edge length in pixels, as served by OpenStreetMap. */
    public static final int TILE_SIZE = 256;

    /** The latitude limit of the Mercator projection, in degrees. */
    public static final double MAX_LATITUDE = 85.05112878d;

    private Mercator() {
    }

    /** Width and height of the whole world, in pixels, at this zoom. */
    public static double worldSize(float zoom) {
        return TILE_SIZE * Math.pow(2d, zoom);
    }

    /** Horizontal pixel position of a longitude at the given zoom. */
    public static double worldX(double longitude, float zoom) {
        return (longitude + 180d) / 360d * worldSize(zoom);
    }

    /** Vertical pixel position of a latitude at the given zoom. */
    public static double worldY(double latitude, float zoom) {
        return worldY(latitude, worldSize(zoom));
    }

    /** Vertical pixel position of a latitude for a world of the given pixel size. */
    public static double worldY(double latitude, double worldSize) {
        double clamped = Math.max(-MAX_LATITUDE, Math.min(MAX_LATITUDE, latitude));
        double radians = Math.toRadians(clamped);
        double mercator = Math.log(Math.tan(radians) + 1d / Math.cos(radians));
        return (1d - mercator / Math.PI) / 2d * worldSize;
    }

    /** The longitude at a horizontal pixel position. */
    public static double longitudeAt(double worldX, float zoom) {
        return worldX / worldSize(zoom) * 360d - 180d;
    }

    /** The latitude at a vertical pixel position. */
    public static double latitudeAt(double worldY, float zoom) {
        double n = Math.PI - 2d * Math.PI * worldY / worldSize(zoom);
        return Math.toDegrees(Math.atan(Math.sinh(n)));
    }

    /** How many tiles span the world on each axis at this zoom: {@code 2^zoom}. */
    public static int tileCount(int zoom) {
        return 1 << zoom;
    }
}
