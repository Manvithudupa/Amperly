package com.amperly.app.core.location;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;

import androidx.core.content.ContextCompat;

import com.amperly.app.core.common.AppConstants;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.Priority;
import com.google.android.gms.tasks.CancellationTokenSource;

/**
 * One place that turns the platform's location services into a coordinate.
 *
 * <p>{@link #requestCurrentLocation} asks for the position now and reports
 * {@link LocationCallback#onLocationUnavailable()} when there is genuinely none — it never invents a
 * coordinate. The older {@link #getCurrentLocation} entry point is kept for callers that only need
 * "a point to start from" and can live with the pilot-area fallback.
 */
public final class LocationProvider {

    public interface LocationCallback {
        void onLocationRetrieved(double latitude, double longitude);

        /** The device has no fix to give and permission is not the problem. */
        default void onLocationUnavailable() {
        }
    }

    private LocationProvider() {
    }

    private static final String PREFS_NAME = "amperly.location";
    private static final String KEY_PERMISSION_ASKED = "permission_asked";

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

    @SuppressWarnings("MissingPermission")
    private static void useLastKnown(FusedLocationProviderClient client, LocationCallback callback) {
        try {
            client.getLastLocation()
                    .addOnSuccessListener(location -> {
                        if (location != null) {
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

    /**
     * The original entry point: always reports a coordinate. Kept because a host registering a
     * charger only needs a starting point, and the pilot centre is a sensible one when the fix is
     * missing.
     */
    @SuppressWarnings("MissingPermission")
    public static void getCurrentLocation(Context context, LocationCallback callback) {
        if (context == null || callback == null) {
            return;
        }
        if (!hasLocationPermission(context)) {
            callback.onLocationRetrieved(AppConstants.PILOT_CENTER_LAT, AppConstants.PILOT_CENTER_LNG);
            return;
        }
        try {
            FusedLocationProviderClient client = LocationServices.getFusedLocationProviderClient(context);
            client.getLastLocation().addOnSuccessListener(location -> {
                if (location != null) {
                    callback.onLocationRetrieved(location.getLatitude(), location.getLongitude());
                } else {
                    requestCurrentLocation(context, new PilotFallbackCallback(callback));
                }
            }).addOnFailureListener(e -> requestCurrentLocation(context,
                    new PilotFallbackCallback(callback)));
        } catch (SecurityException e) {
            callback.onLocationRetrieved(AppConstants.PILOT_CENTER_LAT, AppConstants.PILOT_CENTER_LNG);
        }
    }

    /** Turns an unavailable fix into the pilot centre, for callers that need a point no matter what. */
    private static final class PilotFallbackCallback implements LocationCallback {
        private final LocationCallback delegate;

        PilotFallbackCallback(LocationCallback delegate) {
            this.delegate = delegate;
        }

        @Override
        public void onLocationRetrieved(double latitude, double longitude) {
            delegate.onLocationRetrieved(latitude, longitude);
        }

        @Override
        public void onLocationUnavailable() {
            delegate.onLocationRetrieved(AppConstants.PILOT_CENTER_LAT, AppConstants.PILOT_CENTER_LNG);
        }
    }
}
