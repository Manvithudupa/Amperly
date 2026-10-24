package com.amperly.app.core.nav;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amperly.app.core.routing.DirectionsRoute;
import com.amperly.app.core.routing.GeoapifyRoutingClient;

import java.util.UUID;

/**
 * The production {@link NavigationProvider}: Geoapify for the road route and MapLibre for the map.
 *
 * <pre>
 * GeoapifyNavigationProvider
 *     ├── route calculation      → Geoapify routing API (core/routing/GeoapifyRoutingClient)
 *     ├── navigation session     → sessionId + the NavigationState the UI and Android Auto share
 *     ├── reroute from new SOC   → recalculate() after a battery override
 *     ├── charger waypoints      → the request carries waypoints for corridor stops
 *     └── Android Auto bridge     → the same NavigationState is projected in the car
 * </pre>
 *
 * <p>The route geometry is drawn by the MapLibre panel, and the road data is OpenStreetMap's via
 * Geoapify. There is no live-traffic duration: Geoapify does not publish one, so the planner uses
 * its existing labelled estimate rather than inventing a traffic figure.
 *
 * <p>Voice guidance flags mirror the audio configuration a navigation SDK would use
 * ({@link #AUDIO_VOICE_ALERTS_AND_GUIDANCE} | {@link #AUDIO_BLUETOOTH}), so the intent is explicit
 * and no spoken guidance is faked in this build.
 */
public final class GeoapifyNavigationProvider implements NavigationProvider {

    /** Spoken turn-by-turn alerts and guidance. */
    public static final int AUDIO_VOICE_ALERTS_AND_GUIDANCE = 1;
    /** Route guidance through a connected Bluetooth / car speaker where available. */
    public static final int AUDIO_BLUETOOTH = 2;
    /** No spoken guidance. */
    public static final int AUDIO_SILENT = 0;

    public static final String PROVIDER_NAME = "Geoapify (OpenStreetMap data) + MapLibre";

    private final GeoapifyRoutingClient.TravelMode defaultMode;
    private volatile NavigationState state = NavigationState.idle();

    public GeoapifyNavigationProvider() {
        this(GeoapifyRoutingClient.TravelMode.DRIVING);
    }

    public GeoapifyNavigationProvider(@NonNull GeoapifyRoutingClient.TravelMode defaultMode) {
        this.defaultMode = defaultMode;
    }

    @Override
    public void calculateRoute(@NonNull RouteRequest request, @NonNull RouteCallback callback) {
        calculate(request, callback);
    }

    @Override
    public void recalculate(@NonNull RouteRequest request, @NonNull RouteCallback callback) {
        calculate(request, callback);
    }

    private void calculate(@NonNull RouteRequest request, @NonNull RouteCallback callback) {
        GeoapifyRoutingClient.TravelMode mode = request.getMode() == null
                ? defaultMode : request.getMode();
        GeoapifyRoutingClient.Callback inner = new GeoapifyRoutingClient.Callback() {
            @Override
            public void onRoute(@NonNull DirectionsRoute route) {
                callback.onRoute(new RouteResult(route, request, PROVIDER_NAME,
                        System.currentTimeMillis(), false));
            }

            @Override
            public void onError(@NonNull String message) {
                callback.onError(message);
            }
        };
        if (request.hasDestinationQuery()) {
            GeoapifyRoutingClient.routeToAddress(null, mode, request.getOriginLat(),
                    request.getOriginLng(), request.getDestinationQuery(), inner);
            return;
        }
        GeoapifyRoutingClient.route(null, mode, request.getOriginLat(), request.getOriginLng(),
                request.getDestinationLat(), request.getDestinationLng(), inner);
    }

    @Override
    public void startNavigation(@NonNull NavigationRequest request, @NonNull NavigationCallback callback) {
        RouteResult result = request.getRoute();
        DirectionsRoute route = result.getRoute();
        String sessionId = UUID.randomUUID().toString();
        RouteRequest origin = result.getRequest();
        state = new NavigationState(true, sessionId, route, origin.getOriginLat(),
                origin.getOriginLng(), route.getDistanceKm(), route.getEffectiveDurationMinutes(),
                0, false);
        callback.onStarted(state);
    }

    /** Moves the active session along the route. Called from location updates and after a reroute. */
    public void updateProgress(double lat, double lng, double remainingKm, int remainingMinutes,
                               int travelledPercent) {
        NavigationState current = state;
        if (!current.isActive()) {
            return;
        }
        state = current.movedTo(lat, lng, remainingKm, remainingMinutes, travelledPercent,
                remainingKm <= 0.05);
    }

    /** Swaps in a recalculated route without ending the session, then reports the reroute. */
    public void applyReroute(@NonNull DirectionsRoute newRoute, @Nullable NavigationCallback callback) {
        NavigationState current = state;
        if (!current.isActive()) {
            return;
        }
        state = current.withRoute(newRoute);
        if (callback != null) {
            callback.onRerouted(state);
        }
    }

    /** Marks the session as arrived; navigation stops but the state stays readable for the summary. */
    public void markArrived(@Nullable NavigationCallback callback) {
        NavigationState current = state;
        if (!current.isActive()) {
            return;
        }
        state = new NavigationState(false, current.getSessionId(), current.getRoute(),
                current.getCurrentLat(), current.getCurrentLng(), 0, 0, 100, true);
        if (callback != null) {
            callback.onArrived(state);
        }
    }

    @Override
    public void stopNavigation() {
        state = NavigationState.idle();
    }

    @NonNull
    @Override
    public NavigationState getCurrentNavigationState() {
        return state;
    }
}
