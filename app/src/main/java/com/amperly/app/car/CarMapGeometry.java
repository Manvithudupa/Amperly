package com.amperly.app.car;

/**
 * Pure geometry for the static car map: distance, refetch policy and bounds fitting.
 *
 * <p>No Android or bitmap types are referenced here so every rule can be tested on the JVM.
 */
public final class CarMapGeometry {

    /** The driver must move this far before the static image is fetched again. */
    public static final double REFETCH_DISTANCE_METERS = 150.0;

    /** Never fetch the static image more often than this, even while moving. */
    public static final long MIN_REFETCH_INTERVAL_MS = 10_000L;

    public static final int MIN_ZOOM = 3;
    public static final int MAX_ZOOM = 17;

    /** Street-level zoom when only the driver's position is known. */
    public static final int DRIVER_ZOOM = 15;

    private static final double EARTH_RADIUS_METERS = 6_371_000.0;
    private static final double MAX_MERCATOR_LATITUDE = 85.05112878;
    private static final double LN_2 = Math.log(2.0);

    private CarMapGeometry() {
    }

    /** True when a coordinate is inside the valid latitude/longitude range. */
    public static boolean isValidCoordinate(double latitude, double longitude) {
        if (Double.isNaN(latitude) || Double.isNaN(longitude)
                || Double.isInfinite(latitude) || Double.isInfinite(longitude)) {
            return false;
        }
        return latitude >= -90.0 && latitude <= 90.0
                && longitude >= -180.0 && longitude <= 180.0;
    }

    /** Haversine distance in metres. Returns 0 for two identical or invalid points. */
    public static double distanceMeters(double fromLat, double fromLng,
                                        double toLat, double toLng) {
        if (!isValidCoordinate(fromLat, fromLng) || !isValidCoordinate(toLat, toLng)) {
            return 0.0;
        }
        double lat1 = Math.toRadians(fromLat);
        double lat2 = Math.toRadians(toLat);
        double deltaLat = lat2 - lat1;
        double deltaLng = Math.toRadians(toLng - fromLng);
        double sinLat = Math.sin(deltaLat / 2.0);
        double sinLng = Math.sin(deltaLng / 2.0);
        double a = sinLat * sinLat + Math.cos(lat1) * Math.cos(lat2) * sinLng * sinLng;
        return 2.0 * EARTH_RADIUS_METERS * Math.asin(Math.min(1.0, Math.sqrt(a)));
    }

    /**
     * Whether the static image should be requested again.
     *
     * <p>The image is stale when the visible content changed (pins, viewport or zoom) or when the
     * driver moved more than {@link #REFETCH_DISTANCE_METERS}. Either way at least
     * {@link #MIN_REFETCH_INTERVAL_MS} must have passed since the previous request. The first
     * request (no previous timestamp) always goes through.
     */
    public static boolean shouldRefetch(long nowMs, long lastFetchMs, double movedMeters,
                                        boolean contentChanged, boolean zoomChanged) {
        if (lastFetchMs <= 0L) {
            return true;
        }
        if (!contentChanged && !zoomChanged && movedMeters <= REFETCH_DISTANCE_METERS) {
            return false;
        }
        return nowMs - lastFetchMs >= MIN_REFETCH_INTERVAL_MS;
    }

    /**
     * The highest zoom at which a bounding box still fits the usable part of a surface.
     *
     * @param south      southern latitude
     * @param west       western longitude
     * @param north      northern latitude
     * @param east       eastern longitude
     * @param widthPx    surface width in pixels
     * @param heightPx   surface height in pixels
     * @param paddingPx  padding kept clear on every side
     * @return a zoom between {@link #MIN_ZOOM} and {@link #MAX_ZOOM}
     */
    public static int zoomForBounds(double south, double west, double north, double east,
                                    int widthPx, int heightPx, int paddingPx) {
        if (widthPx <= 0 || heightPx <= 0) {
            return MIN_ZOOM;
        }
        double usableWidth = Math.max(1.0, widthPx - 2.0 * Math.max(0, paddingPx));
        double usableHeight = Math.max(1.0, heightPx - 2.0 * Math.max(0, paddingPx));

        double mercatorNorth = mercatorY(Math.max(north, south));
        double mercatorSouth = mercatorY(Math.min(north, south));
        double lngSpan = Math.abs(normalizeLongitude(east) - normalizeLongitude(west));
        if (lngSpan > 180.0) {
            lngSpan = 360.0 - lngSpan;
        }

        // At zoom 0 the whole world is 256 px wide and tall.
        double spanXPxAtZoomZero = 256.0 * (lngSpan / 360.0);
        double spanYPxAtZoomZero = 256.0 * Math.abs(mercatorSouth - mercatorNorth);

        double zoomX = spanXPxAtZoomZero <= 0.000001
                ? Double.MAX_VALUE
                : Math.log(usableWidth / spanXPxAtZoomZero) / LN_2;
        double zoomY = spanYPxAtZoomZero <= 0.000001
                ? Double.MAX_VALUE
                : Math.log(usableHeight / spanYPxAtZoomZero) / LN_2;

        double zoom = Math.min(zoomX, zoomY);
        if (zoom == Double.MAX_VALUE) {
            return DRIVER_ZOOM;
        }
        int rounded = (int) Math.floor(zoom);
        return Math.max(MIN_ZOOM, Math.min(MAX_ZOOM, rounded));
    }

    /**
     * Pixel offset from {@code from} to {@code to} at the given zoom, using Web Mercator.
     *
     * <p>Used to keep the driver marker in the right place between static-image fetches: the last
     * fetched image is centred on the old position, so a small move is a small pixel offset instead
     * of forcing a new request.
     */
    public static double[] projectOffsetPixels(double fromLat, double fromLng,
                                               double toLat, double toLng, int zoom) {
        if (!isValidCoordinate(fromLat, fromLng) || !isValidCoordinate(toLat, toLng)) {
            return new double[]{0, 0};
        }
        double worldPixels = 256.0 * Math.pow(2.0, Math.max(MIN_ZOOM, Math.min(MAX_ZOOM, zoom)));
        double deltaLng = toLng - fromLng;
        while (deltaLng > 180.0) {
            deltaLng -= 360.0;
        }
        while (deltaLng < -180.0) {
            deltaLng += 360.0;
        }
        double dx = (deltaLng / 360.0) * worldPixels;
        double dy = (mercatorY(toLat) - mercatorY(fromLat)) * worldPixels;
        return new double[]{dx, dy};
    }

    /** Centre of a bounding box as {@code {lat, lng}}. */
    public static double[] centerOfBounds(double south, double west, double north, double east) {
        double mercator = (mercatorY(north) + mercatorY(south)) / 2.0;
        double latitude = Math.toDegrees(
                2.0 * Math.atan(Math.exp((0.5 - mercator) * 2.0 * Math.PI)) - Math.PI / 2.0);
        double longitude = normalizeLongitude((west + east) / 2.0);
        return new double[]{latitude, longitude};
    }

    private static double mercatorY(double latitude) {
        double clamped = Math.max(-MAX_MERCATOR_LATITUDE, Math.min(MAX_MERCATOR_LATITUDE, latitude));
        double radians = Math.toRadians(clamped);
        return 0.5 - Math.log(Math.tan(Math.PI / 4.0 + radians / 2.0)) / (2.0 * Math.PI);
    }

    private static double normalizeLongitude(double longitude) {
        double normalized = ((longitude + 180.0) % 360.0 + 360.0) % 360.0 - 180.0;
        return normalized;
    }
}
