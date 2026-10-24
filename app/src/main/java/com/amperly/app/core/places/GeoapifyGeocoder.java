package com.amperly.app.core.places;

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

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

/**
 * Reverse and forward geocoding through Geoapify (OpenStreetMap data).
 *
 * <p>When a host taps the exact spot of their charger on the map, the app shows a readable address
 * for that point so the host can confirm it before the station is saved. The planner also needs the
 * opposite direction: a free-text destination has to become a coordinate before a route can be
 * requested.
 *
 * <p>Reverse lookups go through Geoapify's reverse endpoint and are cached by coordinate; a host
 * nudging the pin back and forth must not spend three credits on the same view. The parsers are
 * pure static methods so they can be unit tested without a network. Every failure reaches the
 * screen through {@link UserMessages}; the technical detail only ever reaches the log.
 */
public final class GeoapifyGeocoder {

    public interface Callback {
        void onAddress(@NonNull String formattedAddress);

        void onError(@NonNull String message);
    }

    /** The forward lookup's answer: a real coordinate for a place the driver typed. */
    public interface ForwardCallback {
        void onResult(@NonNull PlacesAutocomplete.Selection selection);

        void onError(@NonNull String message);
    }

    private static final String TAG = "GeoapifyGeocoder";
    private static final String BASE_URL = "https://api.geoapify.com/v1/geocode";
    /** The country filter for place search. Change this one line to widen or narrow the market. */
    static final String COUNTRY_FILTER = "countrycode:in";
    private static final int CACHE_SIZE = 64;
    private static final OkHttpClient HTTP = new OkHttpClient.Builder()
            .connectTimeout(8, TimeUnit.SECONDS)
            .readTimeout(12, TimeUnit.SECONDS)
            .build();

    /** Coordinate (rounded to 4 decimals) to formatted address. Bounded, never persisted. */
    private static final Map<String, String> ADDRESS_CACHE =
            Collections.synchronizedMap(new LinkedHashMap<String, String>(CACHE_SIZE, 0.75f, true) {
                @Override
                protected boolean removeEldestEntry(Map.Entry<String, String> eldest) {
                    return size() > CACHE_SIZE;
                }
            });

    private GeoapifyGeocoder() {
    }

    /** Resolves a coordinate to a formatted address. The callback fires on the main thread. */
    public static void reverseGeocode(@NonNull Context context, double latitude, double longitude,
                                      @NonNull Callback callback) {
        final Handler main = new Handler(Looper.getMainLooper());
        final Context appContext = context.getApplicationContext();
        if (!MapConfig.isConfigured()) {
            main.post(() -> callback.onError(MapConfig.setupMessage(appContext)));
            return;
        }
        final String cacheKey = cacheKey(latitude, longitude);
        String cached = ADDRESS_CACHE.get(cacheKey);
        if (cached != null && !cached.isEmpty()) {
            main.post(() -> callback.onAddress(cached));
            return;
        }
        new Thread(() -> {
            try {
                String url = String.format(Locale.US,
                        "%s/reverse?lat=%.6f&lon=%.6f&lang=en&apiKey=%s",
                        BASE_URL, latitude, longitude, MapConfig.apiKey());
                String json = get(url);
                String address = parseFirstAddress(json);
                if (address.isEmpty()) {
                    throw new IllegalStateException("Geoapify found no address for that point.");
                }
                ADDRESS_CACHE.put(cacheKey, address);
                main.post(() -> callback.onAddress(address));
            } catch (Exception e) {
                Log.w(TAG, "Reverse geocoding failed", e);
                String message = UserMessages.from(appContext, e, R.string.error_address_lookup);
                main.post(() -> callback.onError(message));
            }
        }, "geoapify-reverse").start();
    }

    /**
     * Turns free text into the first place Geoapify matches, so the driver's typed destination can
     * be routed to. The callback fires on the main thread.
     */
    public static void forward(@NonNull Context context, @NonNull String text, double biasLat,
                               double biasLng, @NonNull ForwardCallback callback) {
        final Handler main = new Handler(Looper.getMainLooper());
        final Context appContext = context.getApplicationContext();
        final String query = text == null ? "" : text.trim();
        if (!MapConfig.isConfigured()) {
            main.post(() -> callback.onError(MapConfig.setupMessage(appContext)));
            return;
        }
        if (query.isEmpty()) {
            main.post(() -> callback.onError(appContext.getString(R.string.route_needs_destination)));
            return;
        }
        new Thread(() -> {
            try {
                String json = get(autocompleteUrl(query, 1, biasLat, biasLng));
                PlacesAutocomplete.Selection match = GeoapifyPlaceParser.parseFirstMatch(json);
                if (match == null) {
                    throw new IllegalStateException("Geoapify found no matching place.");
                }
                final PlacesAutocomplete.Selection selection = match;
                main.post(() -> callback.onResult(selection));
            } catch (Exception e) {
                Log.w(TAG, "Forward geocoding failed", e);
                String message = UserMessages.from(appContext, e, R.string.error_place_not_found);
                main.post(() -> callback.onError(message));
            }
        }, "geoapify-forward").start();
    }

    /** Builds an autocomplete URL. {@code bias} takes longitude first, as Geoapify documents. */
    @NonNull
    static String autocompleteUrl(@NonNull String text, int limit, double biasLat, double biasLng) {
        StringBuilder url = new StringBuilder(BASE_URL)
                .append("/autocomplete?text=").append(enc(text))
                .append("&limit=").append(Math.max(1, limit))
                .append("&lang=en")
                .append("&filter=").append(COUNTRY_FILTER);
        if (!Double.isNaN(biasLat) && !Double.isNaN(biasLng)) {
            url.append("&bias=proximity:")
                    .append(String.format(Locale.US, "%.6f,%.6f", biasLng, biasLat));
        }
        return url.append("&apiKey=").append(MapConfig.apiKey()).toString();
    }

    /** The first formatted address in a Geoapify reverse response, or an empty string. Pure. */
    @NonNull
    public static String parseFirstAddress(@Nullable String json) {
        return GeoapifyPlaceParser.parseFirstFormattedAddress(json);
    }

    @NonNull
    private static String get(@NonNull String url) throws Exception {
        Request request = new Request.Builder().url(url).build();
        try (Response response = HTTP.newCall(request).execute()) {
            ResponseBody body = response.body();
            String json = body == null ? "" : body.string();
            if (!response.isSuccessful()) {
                throw new IllegalStateException(GeoapifyErrors.httpFailure(response.code()));
            }
            return json;
        }
    }

    @NonNull
    static String cacheKey(double latitude, double longitude) {
        return String.format(Locale.US, "%.4f,%.4f", latitude, longitude);
    }

    private static String enc(String value) {
        try {
            return java.net.URLEncoder.encode(value, "UTF-8");
        } catch (java.io.UnsupportedEncodingException e) {
            return value;
        }
    }
}
