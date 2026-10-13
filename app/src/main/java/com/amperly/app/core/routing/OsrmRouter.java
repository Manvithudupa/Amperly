package com.amperly.app.core.routing;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amperly.app.BuildConfig;
import com.amperly.app.core.common.GeoUtils;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

/**
 * Road-based routing with OSRM (the Open Source Routing Machine), the public demo server by
 * default.
 *
 * <p>This is what turns "here to there" into a real path that follows roads, with a distance and a
 * travel time, instead of the straight line {@link com.amperly.app.core.map.MapHelper} used to
 * draw. It needs no API key, which is the reason it was chosen over a commercial routing SDK.
 *
 * <p>Travel modes map to OSRM profiles: {@code driving} for cars and {@code foot} for walking. The
 * public demo server runs the car profile only and answers a {@code foot} request with the same car
 * geometry, so a walking request against it would be a lie. When no server is configured the router
 * therefore returns the labelled straight-line {@link #estimate} for walking instead; point
 * {@code OSRM_BASE_URL} at a server that carries the foot profile to get real walking routes.
 *
 * <p>Point the app at a different routing server with {@code OSRM_BASE_URL} in
 * {@code local.properties} (or the environment). That is also how a self-hosted OSRM with a foot
 * profile gets real walking directions.
 */
public final class OsrmRouter {

    public enum TravelMode {
        DRIVING("driving", 45.0),
        WALKING("foot", 5.0);

        private final String profile;
        private final double estimateSpeedKmh;

        TravelMode(String profile, double estimateSpeedKmh) {
            this.profile = profile;
            this.estimateSpeedKmh = estimateSpeedKmh;
        }

        public String getProfile() {
            return profile;
        }

        public String label() {
            return this == WALKING ? "walking" : "driving";
        }
    }

    /** A computed route: the road geometry plus the numbers shown to the driver. */
    public static class Route {
        private final TravelMode mode;
        private final List<double[]> points;
        private final double distanceKm;
        private final double durationMinutes;
        private final boolean approximate;

        public Route(TravelMode mode, List<double[]> points, double distanceKm,
                     double durationMinutes, boolean approximate) {
            this.mode = mode;
            this.points = points;
            this.distanceKm = distanceKm;
            this.durationMinutes = durationMinutes;
            this.approximate = approximate;
        }

        public TravelMode getMode() {
            return mode;
        }

        /** Latitude/longitude pairs, in order, one per point of the path. */
        @NonNull
        public List<double[]> getPoints() {
            return points;
        }

        public double getDistanceKm() {
            return distanceKm;
        }

        public double getDurationMinutes() {
            return durationMinutes;
        }

        /** True when this is a straight-line estimate, not a road route. */
        public boolean isApproximate() {
            return approximate;
        }
    }

    public interface Callback {
        void onRoute(@NonNull Route route);

        void onError(@NonNull String message);
    }

    private static final String DEFAULT_BASE_URL = "https://router.project-osrm.org";
    private static final int ESTIMATE_POINTS = 32;

    private static final OkHttpClient HTTP = new OkHttpClient.Builder()
            .connectTimeout(8, TimeUnit.SECONDS)
            .readTimeout(12, TimeUnit.SECONDS)
            .build();

    private OsrmRouter() {
    }

    /**
     * Asks the routing service for a road route. The callback fires on the main thread, so callers
     * can touch the UI directly.
     */
    public static void route(@Nullable Context context, @NonNull TravelMode mode,
                             double fromLat, double fromLng, double toLat, double toLng,
                             @NonNull Callback callback) {
        // Created lazily: a static Looper reference would break plain JVM unit tests that only
        // exercise the parser.
        final Handler main = new Handler(Looper.getMainLooper());
        if (requiresLocalEstimate(mode, usesDefaultServer())) {
            // The public demo server would hand back a car route for a walking request. Return a
            // clearly-labelled estimate rather than pass off driving geometry as walking.
            Route walkingEstimate = estimate(mode, fromLat, fromLng, toLat, toLng);
            main.post(() -> callback.onRoute(walkingEstimate));
            return;
        }
        new Thread(() -> {
            try {
                Route route = fetch(mode, fromLat, fromLng, toLat, toLng);
                main.post(() -> callback.onRoute(route));
            } catch (Exception e) {
                String message = describe(e);
                main.post(() -> callback.onError(message));
            }
        }, "osrm-route").start();
    }

    @NonNull
    static Route fetch(@NonNull TravelMode mode, double fromLat, double fromLng,
                       double toLat, double toLng) throws Exception {
        String url = String.format(Locale.US,
                "%s/route/v1/%s/%.6f,%.6f;%.6f,%.6f?overview=full&geometries=geojson&steps=false",
                baseUrl(), mode.getProfile(), fromLng, fromLat, toLng, toLat);
        Request request = new Request.Builder()
                .url(url)
                .header("User-Agent", BuildConfig.APPLICATION_ID + " (Amperly Android)")
                .build();
        try (Response response = HTTP.newCall(request).execute()) {
            ResponseBody body = response.body();
            String json = body == null ? "" : body.string();
            if (!response.isSuccessful()) {
                throw new IllegalStateException("The routing service returned HTTP "
                        + response.code() + ".");
            }
            return parseRoute(mode, json);
        }
    }

    /**
     * Parses an OSRM response. Kept public and free of network access so it can be unit tested
     * against a captured payload.
     */
    @NonNull
    public static Route parseRoute(@NonNull TravelMode mode, @NonNull String json) {
        JsonElement parsed = JsonParser.parseString(json);
        if (!parsed.isJsonObject()) {
            throw new IllegalStateException("The routing service returned an unexpected response.");
        }
        JsonObject root = parsed.getAsJsonObject();
        String code = root.has("code") ? root.get("code").getAsString() : "";
        if (!"Ok".equals(code)) {
            String message = root.has("message") ? root.get("message").getAsString() : code;
            throw new IllegalStateException(message == null || message.isEmpty()
                    ? "No route found." : message);
        }
        JsonArray routes = root.getAsJsonArray("routes");
        if (routes == null || routes.size() == 0) {
            throw new IllegalStateException("No route found.");
        }
        JsonObject route = routes.get(0).getAsJsonObject();
        double distanceMeters = route.has("distance") ? route.get("distance").getAsDouble() : 0d;
        double durationSeconds = route.has("duration") ? route.get("duration").getAsDouble() : 0d;

        List<double[]> points = new ArrayList<>();
        if (route.has("geometry") && route.get("geometry").isJsonObject()) {
            JsonObject geometry = route.getAsJsonObject("geometry");
            JsonArray coordinates = geometry.has("coordinates")
                    ? geometry.getAsJsonArray("coordinates") : null;
            if (coordinates != null) {
                for (JsonElement element : coordinates) {
                    if (!element.isJsonArray()) {
                        continue;
                    }
                    JsonArray pair = element.getAsJsonArray();
                    if (pair.size() < 2) {
                        continue;
                    }
                    double longitude = pair.get(0).getAsDouble();
                    double latitude = pair.get(1).getAsDouble();
                    points.add(new double[]{latitude, longitude});
                }
            }
        }
        if (points.size() < 2) {
            throw new IllegalStateException("No route found.");
        }
        return new Route(mode, points, distanceMeters / 1000d, durationSeconds / 60d, false);
    }

    /**
     * A straight-line path between two points, used only when the routing service cannot be
     * reached. It is flagged {@link Route#isApproximate()} so the UI can say so.
     */
    @NonNull
    public static Route estimate(@NonNull TravelMode mode, double fromLat, double fromLng,
                                 double toLat, double toLng) {
        List<double[]> points = new ArrayList<>();
        for (int i = 0; i <= ESTIMATE_POINTS; i++) {
            points.add(geodesicPoint(fromLat, fromLng, toLat, toLng, i / (double) ESTIMATE_POINTS));
        }
        double distanceKm = GeoUtils.distanceKm(fromLat, fromLng, toLat, toLng);
        double minutes = distanceKm / mode.estimateSpeedKmh * 60d;
        return new Route(mode, points, distanceKm, minutes, true);
    }

    /** True when the router is using the built-in public server rather than a configured one. */
    public static boolean usesDefaultServer() {
        String configured = BuildConfig.OSRM_BASE_URL;
        return configured == null || configured.trim().isEmpty();
    }

    /**
     * Whether the request has to be answered locally. The public demo server has no foot profile,
     * so walking is estimated unless a foot-capable server has been configured.
     */
    public static boolean requiresLocalEstimate(@NonNull TravelMode mode, boolean defaultServer) {
        return mode == TravelMode.WALKING && defaultServer;
    }

    @NonNull
    static String baseUrl() {
        String configured = BuildConfig.OSRM_BASE_URL;
        if (configured == null || configured.trim().isEmpty()) {
            return DEFAULT_BASE_URL;
        }
        String trimmed = configured.trim();
        while (trimmed.endsWith("/")) {
            trimmed = trimmed.substring(0, trimmed.length() - 1);
        }
        return trimmed;
    }

    private static String describe(Exception e) {
        String message = e.getMessage();
        if (message == null || message.trim().isEmpty()) {
            return "Could not reach the routing service.";
        }
        return message;
    }

    /** A great-circle point, mirroring the curve {@link com.amperly.app.core.map.MapHelper} draws. */
    private static double[] geodesicPoint(double lat1, double lon1, double lat2, double lon2,
                                          double fraction) {
        double phi1 = Math.toRadians(lat1);
        double lambda1 = Math.toRadians(lon1);
        double phi2 = Math.toRadians(lat2);
        double lambda2 = Math.toRadians(lon2);
        double d = 2 * Math.asin(Math.sqrt(Math.pow(Math.sin((phi2 - phi1) / 2), 2)
                + Math.cos(phi1) * Math.cos(phi2) * Math.pow(Math.sin((lambda2 - lambda1) / 2), 2)));
        if (d == 0 || Double.isNaN(d)) {
            return new double[]{lat1, lon1};
        }
        double a = Math.sin((1 - fraction) * d) / Math.sin(d);
        double b = Math.sin(fraction * d) / Math.sin(d);
        double x = a * Math.cos(phi1) * Math.cos(lambda1) + b * Math.cos(phi2) * Math.cos(lambda2);
        double y = a * Math.cos(phi1) * Math.sin(lambda1) + b * Math.cos(phi2) * Math.sin(lambda2);
        double z = a * Math.sin(phi1) + b * Math.sin(phi2);
        return new double[]{
                Math.toDegrees(Math.atan2(z, Math.sqrt(x * x + y * y))),
                Math.toDegrees(Math.atan2(y, x))};
    }
}
