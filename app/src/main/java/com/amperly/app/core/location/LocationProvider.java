package com.amperly.app.core.location;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import androidx.core.content.ContextCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationAvailability;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.Priority;
import com.google.android.gms.tasks.CancellationTokenSource;

/**
 * One place that turns the platform's location services into a coordinate.
 *
 * <p>{@link #requestCurrentLocation} asks for the position now and reports
 * {@link LocationCallback#onLocationUnavailable()} when there is genuinely none. It never invents a
 * coordinate: there is deliberately no pilot-area fallback here, because silently substituting a
 * fixed point for the driver's real position is forbidden — the screens must show an unavailable
 * state (or let the user pick an explicit map origin) instead.
 *
 * <p>{@link #startUpdates} is the streaming counterpart used by the projected car experience. It
 * keeps one registered listener at a time, reports every fix through {@link UpdateListener}, and
 * remembers the newest fix (with its age and bearing) so a freshly created car screen can draw the
 * driver immediately instead of waiting for the next callback.
 */
public final class LocationProvider {

    public interface LocationCallback {
        void onLocationRetrieved(double latitude, double longitude);

        /** The device has no fix to give and permission is not the problem. */
        default void onLocationUnavailable() {
        }
    }

    /** Receives streaming fixes and availability changes. */
    public interface UpdateListener {
        /**
         * @param bearingDegrees the direction of travel, meaningful only when {@code hasBearing}
         * @param hasBearing     true when the platform supplied a bearing for this fix
         */
        void onLocation(double latitude, double longitude, float bearingDegrees, boolean hasBearing);

        /** The platform currently has no usable fix; the listener should show an honest state. */
        default void onLocationUnavailable() {
        }
    }

    private LocationProvider() {
    }

    private static final String PREFS_NAME = "amperly.location";
    private static final String KEY_PERMISSION_ASKED = "permission_asked";

    /** A fix this recent is safe to reuse for route arithmetic while the app is only starting. */
    private static final long FRESH_FIX_MS = 2L * 60L * 1000L;

    /**
     * The most recent fix in this process, or null.
     *
     * <p>Address search uses it only to bias suggestions towards where the driver is; it never
     * prompts for a permission and never blocks a search. Filled by the success paths below.
     */
    @Nullable
    private static volatile double[] lastFix;
    private static volatile long lastFixAtMs;
    private static volatile float lastFixBearing;
    private static volatile boolean lastFixHasBearing;

    /**
     * The one streaming registration owned by this process, or null. Only one car screen is
     * resumed at a time, so a single slot is enough and prevents duplicate registrations when a
     * screen is rebuilt by the host.
     */
    @Nullable
    private static volatile com.google.android.gms.location.LocationCallback activeUpdates;

    /** True when the app currently holds a usable location permission. */
    public static boolean hasLocationPermission(Context context) {
        if (context == null) {
            return false;
        }
        return ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
                == PackageManager.PERMISSION_GRANTED
                || ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)
                == PackageManager.PERMISSION_GRANTED;
    }

    /**
     * True once the system permission prompt has been shown at least once. Screens use this to ask
     * a single time rather than on every visit.
     */
    public static boolean hasAskedForPermission(Context context) {
        return context != null
                && context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getBoolean(KEY_PERMISSION_ASKED, false);
    }

    /** Records that the system permission prompt has been shown. */
    public static void markPermissionAsked(Context context) {
        if (context != null) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    .edit().putBoolean(KEY_PERMISSION_ASKED, true).apply();
        }
    }

    /**
     * Asks for a fresh, high-accuracy fix. If the platform cannot deliver one it falls back to the
     * last known position and, failing that, reports the location as unavailable rather than
     * returning a made-up coordinate.
     */
    public static void requestCurrentLocation(Context context, LocationCallback callback) {
        if (context == null || callback == null) {
            return;
        }
        if (!hasLocationPermission(context)) {
            callback.onLocationUnavailable();
            return;
        }
        try {
            FusedLocationProviderClient client =
                    LocationServices.getFusedLocationProviderClient(context);
            CancellationTokenSource cancellation = new CancellationTokenSource();
            client.getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, cancellation.getToken())
                    .addOnSuccessListener(location -> {
                        if (location != null) {
                            rememberFix(location);
                            callback.onLocationRetrieved(location.getLatitude(), location.getLongitude());
                        } else {
                            useLastKnown(client, callback);
                        }
                    })
                    .addOnFailureListener(e -> useLastKnown(client, callback));
        } catch (SecurityException e) {
            callback.onLocationUnavailable();
        } catch (Exception e) {
            callback.onLocationUnavailable();
        }
    }

    /**
     * Starts (or replaces) the single stream of updates.
     *
     * <p>Callers are responsible for stopping it when the screen is no longer projected. The car
     * experience intentionally does not request background location: updates run only while a car
     * screen is started, so the vehicle display can never track the driver in the background.
     *
     * @param intervalMs requested interval between fixes
     */
    public static void startUpdates(Context context, long intervalMs, UpdateListener listener) {
        startUpdates(context, intervalMs, false, listener);
    }

    /**
     * Starts updates with an explicit accuracy choice. The car uses high accuracy while the map is
     * visible; callers that only need a coarse position can keep the battery-friendly default.
     */
    public static void startUpdates(Context context, long intervalMs, boolean highAccuracy,
                                    UpdateListener listener) {
        if (context == null || listener == null) {
            return;
        }
        if (!hasLocationPermission(context)) {
            listener.onLocationUnavailable();
            return;
        }
        stopUpdates(context);

        final long interval = Math.max(2_000L, intervalMs);
        try {
            FusedLocationProviderClient client =
                    LocationServices.getFusedLocationProviderClient(context);
            LocationRequest request = new LocationRequest.Builder(interval)
                    .setPriority(highAccuracy
                            ? Priority.PRIORITY_HIGH_ACCURACY
                            : Priority.PRIORITY_BALANCED_POWER_ACCURACY)
                    .setMinUpdateIntervalMillis(Math.max(1_000L, Math.min(interval, 5_000L)))
                    .setMinUpdateDistanceMeters(10f)
                    .build();

            com.google.android.gms.location.LocationCallback callback =
                    new com.google.android.gms.location.LocationCallback() {
                        @Override
                        public void onLocationResult(@NonNull LocationResult result) {
                            Location location = result == null ? null : result.getLastLocation();
                            if (location == null) {
                                return;
                            }
                            rememberFix(location);
                            listener.onLocation(location.getLatitude(), location.getLongitude(),
                                    location.getBearing(), location.hasBearing());
                        }

                        @Override
                        public void onLocationAvailability(@NonNull LocationAvailability availability) {
                            if (availability != null && !availability.isLocationAvailable()) {
                                listener.onLocationUnavailable();
                            }
                        }
                    };

            activeUpdates = callback;
            client.requestLocationUpdates(request, callback, Looper.getMainLooper())
                    .addOnFailureListener(e -> {
                        if (activeUpdates == callback) {
                            activeUpdates = null;
                        }
                        listener.onLocationUnavailable();
                    });
        } catch (SecurityException e) {
            listener.onLocationUnavailable();
            return;
        } catch (RuntimeException e) {
            listener.onLocationUnavailable();
            return;
        }

        // Paint the last known position immediately; waiting for the first callback would leave
        // the car map blank for several seconds on every reconnect.
        double[] fix = lastFix;
        if (fix != null && lastFixAgeMs() <= FRESH_FIX_MS) {
            listener.onLocation(fix[0], fix[1], lastFixBearing, lastFixHasBearing);
        }
    }

    /** Removes the streaming registration owned by this process, if any. */
    public static void stopUpdates(Context context) {
        com.google.android.gms.location.LocationCallback callback = activeUpdates;
        activeUpdates = null;
        if (callback == null || context == null) {
            return;
        }
        try {
            LocationServices.getFusedLocationProviderClient(context)
                    .removeLocationUpdates(callback);
        } catch (RuntimeException ignored) {
            // The client or the Play Services process already went away.
        }
    }

    /** The latest successful fix, as {@code {lat, lng}}, or null when none has been seen. */
    @Nullable
    public static double[] lastKnownFix() {
        double[] fix = lastFix;
        return fix == null ? null : new double[]{fix[0], fix[1]};
    }

    /** Age of the newest fix in milliseconds, or {@link Long#MAX_VALUE} when there is none. */
    public static long lastFixAgeMs() {
        if (lastFix == null) {
            return Long.MAX_VALUE;
        }
        long age = System.currentTimeMillis() - lastFixAtMs;
        return age < 0 ? 0 : age;
    }

    /** Bearing in degrees of the newest fix; meaningful only with {@link #hasLastKnownBearing()}. */
    public static float lastKnownBearing() {
        return lastFixBearing;
    }

    /** True when the newest fix carried a real bearing rather than a placeholder zero. */
    public static boolean hasLastKnownBearing() {
        return lastFix != null && lastFixHasBearing;
    }

    private static void rememberFix(Location location) {
        rememberFix(location.getLatitude(), location.getLongitude(), location.getBearing(),
                location.hasBearing(), location.getTime());
        if (lastFixAtMs <= 0 || lastFixAtMs > System.currentTimeMillis()) {
            lastFixAtMs = System.currentTimeMillis();
        }
    }

    private static void rememberFix(double latitude, double longitude) {
        rememberFix(latitude, longitude, 0f, false, System.currentTimeMillis());
    }

    private static void rememberFix(double latitude, double longitude, float bearing,
                                    boolean hasBearing, long timeMs) {
        lastFix = new double[]{latitude, longitude};
        lastFixBearing = bearing;
        lastFixHasBearing = hasBearing;
        lastFixAtMs = timeMs > 0 ? timeMs : System.currentTimeMillis();
    }

    @SuppressWarnings("MissingPermission")
    private static void useLastKnown(FusedLocationProviderClient client, LocationCallback callback) {
        try {
            client.getLastLocation()
                    .addOnSuccessListener(location -> {
                        if (location != null) {
                            rememberFix(location);
                            callback.onLocationRetrieved(location.getLatitude(), location.getLongitude());
                        } else {
                            callback.onLocationUnavailable();
                        }
                    })
                    .addOnFailureListener(e -> callback.onLocationUnavailable());
        } catch (SecurityException e) {
            callback.onLocationUnavailable();
        }
    }

}
