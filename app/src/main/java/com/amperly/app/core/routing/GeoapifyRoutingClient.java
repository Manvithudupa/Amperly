package com.amperly.app.core.routing;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amperly.app.R;
import com.amperly.app.core.common.GeoapifyErrors;
import com.amperly.app.core.common.MapConfig;
import com.amperly.app.core.common.UserMessages;
import com.amperly.app.core.places.GeoapifyGeocoder;
import com.amperly.app.core.places.PlacesAutocomplete;
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
 * Road routing through Geoapify's routing API, on OpenStreetMap data.
 *
 * <p>It turns an origin and destination into real road geometry, a distance and the ordered
 * turn-by-turn steps that the route screen and the in-app navigation session show. Geoapify
 * publishes no live-traffic ETA, so {@code durationInTrafficMinutes} is always 0 and the planner
 * uses its existing, clearly labelled estimate path instead of pretending to know about traffic.
 *
 * <p>The parser is a pure static method so it can be unit tested against a captured payload; only
 * {@link #route} touches the network. Identical requests are served from {@link RouteCache}, and
 * starts are paced by {@link RequestThrottle}, because the free plan is bounded in credits per day
 * and requests per second. When the key is missing or the call fails the caller is told, and may
 * fall back to a clearly labelled straight-line estimate — the client never passes an estimate off
 * as a real route.
 */
public final class GeoapifyRoutingClient {

    /** How the route is measured. Geoapify exposes these as request modes. */
    public enum TravelMode {
        DRIVING("drive", false, 45.0),
        WALKING("walk", false, 5.0);

        private final String requestMode;
        private final boolean trafficAware;
        private final double estimateSpeedKmh;

        TravelMode(String requestMode, boolean trafficAware, double estimateSpeedKmh) {
            this.requestMode = requestMode;
            this.trafficAware = trafficAware;
            this.estimateSpeedKmh = estimateSpeedKmh;
        }

        /** The value Geoapify expects for the {@code mode} parameter. */
        public String requestMode() {
            return requestMode;
        }

        /** Always false: Geoapify does not publish a traffic-aware duration. */
        public boolean isTrafficAware() {
            return trafficAware;
        }

        /** Speed used only for the labelled straight-line fallback. */
        public double estimateSpeedKmh() {
            return estimateSpeedKmh;
        }

        public String label() {
            return this == WALKING ? "walking" : "driving";
        }
    }

    public interface Callback {
        void onRoute(@NonNull DirectionsRoute route);

        void onError(@NonNull String message);
    }

    private static final String TAG = "GeoapifyRouting";
    private static final String BASE_URL = "https://api.geoapify.com/v1/routing";
    /** Only used when no Context is available (the navigation provider passes none). */
    private static final String MAP_UNAVAILABLE = "The map service is unavailable right now.";
    private static final String NOT_CONFIGURED = "The map service is not configured in this build.";
    private static final OkHttpClient HTTP = new OkHttpClient.Builder()
            .connectTimeout(8, TimeUnit.SECONDS)
            .readTimeout(12, TimeUnit.SECONDS)
            .build();

    private static final RouteCache CACHE = new RouteCache();
    private static final RequestThrottle THROTTLE = new RequestThrottle();

    private GeoapifyRoutingClient() {
    }

    /**
     * Requests a road route between two points. The callback fires on the main thread, so callers
     * can touch the UI directly.
     */
    public static void route(@Nullable Context context, @NonNull TravelMode mode,
                             double fromLat, double fromLng, double toLat, double toLng,
                             @NonNull Callback callback) {
        final Handler main = new Handler(Looper.getMainLooper());
        if (!MapConfig.isConfigured()) {
            final String message = context == null
                    ? NOT_CONFIGURED : MapConfig.setupMessage(context.getApplicationContext());
            main.post(() -> callback.onError(message));
            return;
        }
        final String key = cacheKey(mode, fromLat, fromLng, toLat, toLng);
        DirectionsRoute cached = CACHE.get(key, System.currentTimeMillis());
        if (cached != null) {
            main.post(() -> callback.onRoute(cached));
            return;
        }
        new Thread(() -> {
            try {
                long waitMs = THROTTLE.reserveDelayMs(System.currentTimeMillis());
                if (waitMs > 0) {
                    Thread.sleep(Math.min(waitMs, 1000L));
                }
                DirectionsRoute route = fetch(mode, fromLat, fromLng, toLat, toLng);
                CACHE.put(key, route, System.currentTimeMillis());
                main.post(() -> callback.onRoute(route));
            } catch (Exception e) {
                String message = describe(context, e);
                main.post(() -> callback.onError(message));
            }
        }, "geoapify-route").start();
    }

    /**
     * Requests a route to a free-text destination (a place name, shop, hotel or address), which is
     * what the driver typed when the autocomplete list had no match. The text is resolved to a real
     * place first, because Geoapify routes between coordinates, not names.
     */
    public static void routeToAddress(@Nullable Context context, @NonNull TravelMode mode,
                                      double fromLat, double fromLng, @NonNull String destination,
                                      @NonNull Callback callback) {
        final Handler main = new Handler(Looper.getMainLooper());
        if (!MapConfig.isConfigured()) {
            final String message = context == null
                    ? NOT_CONFIGURED : MapConfig.setupMessage(context.getApplicationContext());
            main.post(() -> callback.onError(message));
            return;
        }
        if (destination.trim().isEmpty()) {
            main.post(() -> callback.onError(context == null
                    ? MAP_UNAVAILABLE
                    : context.getString(R.string.route_needs_destination)));
            return;
        }
        final Context appContext = context == null ? null : context.getApplicationContext();
        GeoapifyGeocoder.forward(context, destination.trim(), fromLat, fromLng,
                new GeoapifyGeocoder.ForwardCallback() {
                    @Override
                    public void onResult(@NonNull PlacesAutocomplete.Selection selection) {
                        route(appContext, mode, fromLat, fromLng, selection.getLatitude(),
                                selection.getLongitude(), callback);
                    }

                    @Override
                    public void onError(@NonNull String message) {
                        // Already a friendly line, and already on the main thread.
                        callback.onError(message);
                    }
                });
    }

    @NonNull
    static DirectionsRoute fetch(@NonNull TravelMode mode, double fromLat, double fromLng,
                                 double toLat, double toLng) throws Exception {
        // waypoints are "lat,lon" pairs separated by a pipe, in the order they are driven.
        String url = String.format(Locale.US,
                "%s?waypoints=%.6f,%.6f|%.6f,%.6f&mode=%s&details=instruction_details&apiKey=%s",
                BASE_URL, fromLat, fromLng, toLat, toLng, mode.requestMode(), MapConfig.apiKey());
        Request request = new Request.Builder().url(url).build();
        try (Response response = HTTP.newCall(request).execute()) {
            ResponseBody body = response.body();
            String json = body == null ? "" : body.string();
            if (!response.isSuccessful()) {
                throw new IllegalStateException(GeoapifyErrors.httpFailure(response.code()));
            }
            return parseRoute(mode, json);
        }
    }

    /**
     * Parses a Geoapify routing response. Public and network-free so it can be unit tested against
     * a captured payload.
     *
     * <p>Coordinate order is inverted here on purpose: GeoJSON stores {@code [lon, lat]}, while
     * {@link DirectionsRoute} points are {@code {lat, lng}} like every other coordinate in the app.
     */
    @NonNull
    public static DirectionsRoute parseRoute(@NonNull TravelMode mode, @NonNull String json) {
        JsonObject root;
        try {
            JsonElement parsed = JsonParser.parseString(json);
            if (!parsed.isJsonObject()) {
                throw new IllegalStateException("Geoapify returned an unexpected response.");
            }
            root = parsed.getAsJsonObject();
        } catch (IllegalStateException e) {
            throw e;
        } catch (RuntimeException e) {
            throw new IllegalStateException("Geoapify returned an unexpected response.");
        }

        JsonArray features = array(root, "features");
        if (features == null || features.size() == 0) {
            throw new IllegalStateException("Geoapify found no route between those points.");
        }
        JsonElement first = features.get(0);
        if (!first.isJsonObject()) {
            throw new IllegalStateException("Geoapify found no route between those points.");
        }
        JsonObject feature = first.getAsJsonObject();
        JsonObject properties = object(feature, "properties");
        if (properties == null) {
            throw new IllegalStateException("Geoapify returned a route with no usable geometry.");
        }

        double distanceMeters = number(properties, "distance", 0d);
        double durationSeconds = number(properties, "time", 0d);
        List<double[]> points = geometryPoints(feature);
        if (points.size() < 2) {
            throw new IllegalStateException("Geoapify returned a route with no usable geometry.");
        }
        List<DirectionsRoute.Step> steps = steps(properties, points);

        int durationMinutes = (int) Math.round(durationSeconds / 60d);
        return new DirectionsRoute(points, distanceMeters / 1000d, durationMinutes,
                // No live traffic data from Geoapify, so the planner's labelled estimate is used.
                0, "", "", steps, false);
    }

    /** Flattens a LineString or MultiLineString into {@code {lat, lng}} points. */
    @NonNull
    private static List<double[]> geometryPoints(@NonNull JsonObject feature) {
        List<double[]> points = new ArrayList<>();
        JsonObject geometry = object(feature, "geometry");
        if (geometry == null) {
            return points;
        }
        String type = string(geometry, "type");
        JsonArray coordinates = array(geometry, "coordinates");
        if (coordinates == null) {
            return points;
        }
        if ("MultiLineString".equalsIgnoreCase(type)) {
            // One array per leg. The joint point is repeated by Geoapify, so it is dropped to stop
            // duplicate zero-length segments in the drawn line.
            for (JsonElement part : coordinates) {
                if (part.isJsonArray()) {
                    appendPoints(points, part.getAsJsonArray());
                }
            }
        } else {
            appendPoints(points, coordinates);
        }
        return points;
    }

    private static void appendPoints(@NonNull List<double[]> target, @NonNull JsonArray coordinates) {
        for (JsonElement element : coordinates) {
            if (!element.isJsonArray()) {
                continue;
            }
            JsonArray pair = element.getAsJsonArray();
            if (pair.size() < 2) {
                continue;
            }
            double lon = pair.get(0).getAsDouble();
            double lat = pair.get(1).getAsDouble();
            double[] point = new double[]{lat, lon};
            if (!target.isEmpty() && samePoint(target.get(target.size() - 1), point)) {
                continue;
            }
            target.add(point);
        }
    }

    private static boolean samePoint(@NonNull double[] a, @NonNull double[] b) {
        return Math.abs(a[0] - b[0]) < 1e-7 && Math.abs(a[1] - b[1]) < 1e-7;
    }

    /**
     * The turn-by-turn steps, placed on the flattened line with each step's {@code from_index}.
     */
    @NonNull
    private static List<DirectionsRoute.Step> steps(@NonNull JsonObject properties,
                                                    @NonNull List<double[]> points) {
        List<DirectionsRoute.Step> steps = new ArrayList<>();
        JsonArray legs = array(properties, "legs");
        if (legs == null) {
            return steps;
        }
        for (JsonElement legElement : legs) {
            if (!legElement.isJsonObject()) {
                continue;
            }
            JsonArray legSteps = array(legElement.getAsJsonObject(), "steps");
            if (legSteps == null) {
                continue;
            }
            for (JsonElement stepElement : legSteps) {
                if (!stepElement.isJsonObject()) {
                    continue;
                }
                JsonObject step = stepElement.getAsJsonObject();
                JsonObject instruction = object(step, "instruction");
                String text = instruction == null ? "" : string(instruction, "text");
                String type = instruction == null ? "" : string(instruction, "type");
                int fromIndex = (int) number(step, "from_index", -1d);
                double startLat = 0;
                double startLng = 0;
                if (fromIndex >= 0 && fromIndex < points.size()) {
                    startLat = points.get(fromIndex)[0];
                    startLng = points.get(fromIndex)[1];
                }
                steps.add(new DirectionsRoute.Step(text,
                        distanceText(number(step, "distance", 0d)),
                        durationText(number(step, "time", 0d)),
                        type, startLat, startLng));
            }
        }
        return steps;
    }

    @NonNull
    private static String distanceText(double metres) {
        if (metres < 1000d) {
            return String.format(Locale.US, "%.0f m", metres);
        }
        return String.format(Locale.US, "%.1f km", metres / 1000d);
    }

    @NonNull
    private static String durationText(double seconds) {
        int minutes = (int) Math.round(seconds / 60d);
        if (minutes < 1) {
            minutes = 1;
        }
        return String.format(Locale.US, "%d min", minutes);
    }

    /** The key for the cache: mode plus coordinates rounded to about 11 m. */
    @NonNull
    static String cacheKey(@NonNull TravelMode mode, double fromLat, double fromLng, double toLat,
                           double toLng) {
        return String.format(Locale.US, "%s:%.4f,%.4f:%.4f,%.4f", mode.requestMode(),
                fromLat, fromLng, toLat, toLng);
    }

    @Nullable
    private static JsonObject object(@NonNull JsonObject parent, @NonNull String key) {
        return parent.has(key) && parent.get(key).isJsonObject()
                ? parent.getAsJsonObject(key) : null;
    }

    @Nullable
    private static JsonArray array(@NonNull JsonObject parent, @NonNull String key) {
        return parent.has(key) && parent.get(key).isJsonArray()
                ? parent.getAsJsonArray(key) : null;
    }

    @NonNull
    private static String string(@NonNull JsonObject parent, @NonNull String key) {
        if (!parent.has(key) || parent.get(key).isJsonNull()) {
            return "";
        }
        JsonElement value = parent.get(key);
        return value.isJsonPrimitive() ? value.getAsString() : "";
    }

    private static double number(@NonNull JsonObject parent, @NonNull String key, double fallback) {
        if (!parent.has(key) || parent.get(key).isJsonNull()) {
            return fallback;
        }
        try {
            JsonElement value = parent.get(key);
            return value.isJsonPrimitive() ? value.getAsDouble() : fallback;
        } catch (RuntimeException e) {
            return fallback;
        }
    }

    /**
     * Logs the technical reason and returns a plain-language line. The raw message never reaches
     * the screen, and never reaches the car display either.
     */
    private static String describe(@Nullable Context context, Exception e) {
        Log.w(TAG, "Route request failed", e);
        if (context == null) {
            return MAP_UNAVAILABLE;
        }
        return UserMessages.from(context.getApplicationContext(), e, R.string.error_map_unavailable);
    }
}
