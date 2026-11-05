package com.amperly.app.car;

import android.Manifest;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.car.app.CarContext;
import androidx.car.app.Screen;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.amperly.app.core.location.LocationProvider;

import java.util.Collections;

/**
 * Live position for one car screen.
 *
 * <p>The helper owns no static state: it follows the screen lifecycle, starting updates when the
 * screen is projected and stopping them when it is no longer visible. That is the whole background
 * location decision for the car experience — updates exist only while the driver is looking at the
 * car display, so no foreground service and no background-location permission are needed.
 *
 * <p>When permission is missing it asks through the car host once. If the driver declines, the
 * listener is told so the screen can name the reason and point at the phone's settings; no
 * coordinate is ever invented.
 */
public final class CarLocation implements DefaultLifecycleObserver {

    /** How often the car asks for a fix while the map is on screen. */
    public static final long UPDATE_INTERVAL_MS = 5_000L;

    /** One real fix. */
    public static final class Fix {
        public final double latitude;
        public final double longitude;
        public final float bearingDegrees;
        public final boolean hasBearing;
        public final long timeMs;

        public Fix(double latitude, double longitude, float bearingDegrees, boolean hasBearing,
                   long timeMs) {
            this.latitude = latitude;
            this.longitude = longitude;
            this.bearingDegrees = bearingDegrees;
            this.hasBearing = hasBearing;
            this.timeMs = timeMs;
        }
    }

    /** Screen-side callback. Always invoked on the main thread. */
    public interface Listener {
        /**
         * @param fix              the newest real fix, or null before the first one
         * @param permissionDenied true when the driver has declined/revoked location access
         */
        void onCarLocationChanged(@Nullable Fix fix, boolean permissionDenied);
    }

    private final CarContext carContext;
    private final Listener listener;
    private final LocationProvider.UpdateListener updateListener =
            new LocationProvider.UpdateListener() {
                @Override
                public void onLocation(double latitude, double longitude, float bearingDegrees,
                                       boolean hasBearing) {
                    latest = new Fix(latitude, longitude, bearingDegrees, hasBearing,
                            System.currentTimeMillis());
                    permissionDenied = false;
                    notifyListener();
                }

                @Override
                public void onLocationUnavailable() {
                    notifyListener();
                }
            };

    private boolean started;
    private boolean permissionDenied;
    @Nullable
    private Fix latest;

    public CarLocation(@NonNull Screen screen, @NonNull Listener listener) {
        this.carContext = screen.getCarContext();
        this.listener = listener;
        screen.getLifecycle().addObserver(this);
    }

    /** The newest fix, or null when none has arrived yet. */
    @Nullable
    public Fix latest() {
        return latest;
    }

    /** True when the driver has declined or revoked location access. */
    public boolean isPermissionDenied() {
        return permissionDenied;
    }

    @Override
    public void onStart(@NonNull LifecycleOwner owner) {
        start();
    }

    @Override
    public void onStop(@NonNull LifecycleOwner owner) {
        stop();
    }

    @Override
    public void onDestroy(@NonNull LifecycleOwner owner) {
        stop();
    }

    /** Starts updates, or asks for permission when the app does not hold it yet. */
    public void start() {
        if (started) {
            return;
        }
        started = true;

        if (LocationProvider.hasLocationPermission(carContext)) {
            permissionDenied = false;
            LocationProvider.startUpdates(carContext, UPDATE_INTERVAL_MS, true, updateListener);
            notifyListener();
            return;
        }

        permissionDenied = LocationProvider.hasAskedForPermission(carContext);
        notifyListener();
        if (!permissionDenied) {
            requestPermission();
        }
    }

    /** Stops updates. The last fix is kept so a resumed screen can draw immediately. */
    public void stop() {
        started = false;
        LocationProvider.stopUpdates(carContext);
    }

    private void requestPermission() {
        LocationProvider.markPermissionAsked(carContext);
        try {
            carContext.requestPermissions(
                    Collections.singletonList(Manifest.permission.ACCESS_FINE_LOCATION),
                    (granted, denied) -> {
                        boolean nowGranted = LocationProvider.hasLocationPermission(carContext);
                        permissionDenied = !nowGranted;
                        if (nowGranted && started) {
                            LocationProvider.startUpdates(carContext, UPDATE_INTERVAL_MS, true,
                                    updateListener);
                        }
                        notifyListener();
                    });
        } catch (RuntimeException e) {
            // A host without a permission surface still gets the honest unavailable state.
            permissionDenied = true;
            notifyListener();
        }
    }

    private void notifyListener() {
        if (!started) {
            return;
        }
        listener.onCarLocationChanged(latest, permissionDenied);
    }
}
