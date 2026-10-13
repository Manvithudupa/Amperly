package com.amperly.app.core.map;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.view.ViewGroup;


import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.data.local.entity.ChargerStation;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.WeakHashMap;

/**
 * Puts a map inside a screen and draws amperly's own content on it.
 *
 * <p>The map is {@link OsmTileMapView}: OpenStreetMap raster tiles drawn directly, so there is no
 * API key, no Play Services and no third-party map SDK to configure. Host-registered chargers show
 * up here the moment they are approved, because this class plots whatever
 * {@code repo.getApprovedStationsSync()} returns.
 *
 * <p>The view is a plain child of the screen's own container, so asking for the map twice — as the
 * discovery screen does, once when the view is created and again in {@code onResume} — reuses the
 * same panel instead of tearing it down and rebuilding it.
 */
public final class MapHelper {

    /** A ready-to-use map. */
    public interface MapReady {
        void onReady(@NonNull OsmTileMapView map);
    }

    /** Reports a charger location the host picked on the map. */
    public interface LocationPick {
        void onPicked(double latitude, double longitude);
    }

    /** One panel per container, so asking twice reuses the same view. */
    private static final Map<ViewGroup, OsmTileMapView> PANELS = new WeakHashMap<>();

    private MapHelper() {
    }

    // --------------------------------------------------------------- attaching

    /**
     * Shows a map inside {@code container}.
     *
     * <p>Building the view is deferred to the container's first layout: creating a map is not free
     * and it must not delay the rest of the screen from painting.
     */
    public static void attach(@NonNull Fragment parent, @Nullable ViewGroup container,
                              @NonNull MapReady callback) {
        if (container == null) {
            return;
        }
        container.post(() -> {
            OsmTileMapView map = panelFor(parent, container);
            if (map != null) {
                callback.onReady(map);
            }
        });
    }

    /**
     * A map the host can touch to place a charger, with a pin at the current coordinates.
     * Tapping anywhere moves the pin and reports the new point.
     */
    public static void attachPicker(@NonNull Fragment parent, @Nullable ViewGroup container,
                                    double latitude, double longitude, @NonNull String label,
                                    @NonNull LocationPick picker) {
        if (container == null) {
            return;
        }
        container.post(() -> {
            OsmTileMapView map = panelFor(parent, container);
            if (map == null) {
                return;
            }
            final double[] pin = {latitude, longitude};
            map.setPins(java.util.Collections.singletonList(pinAt(map, pin[0], pin[1], label)));
            map.setMapTapListener((lat, lng) -> {
                pin[0] = lat;
                pin[1] = lng;
                map.setPins(java.util.Collections.singletonList(pinAt(map, lat, lng, label)));
                picker.onPicked(lat, lng);
            });
            map.setCamera(pin[0], pin[1], 16f);
        });
    }

    /** Moves an already attached map, used when the host types coordinates by hand. */
    public static void moveTo(@Nullable ViewGroup container, double latitude, double longitude,
                              float zoom) {
        OsmTileMapView map = PANELS.get(container);
        if (map == null) {
            return;
        }
        map.setCamera(latitude, longitude, zoom);
        if (map.isEmpty()) {
            map.setPins(java.util.Collections.singletonList(
                    pinAt(map, latitude, longitude, null)));
        }
    }

    @Nullable
    private static OsmTileMapView panelFor(@NonNull Fragment parent, @Nullable ViewGroup container) {
        if (container == null) {
            return null;
        }
        Context context;
        try {
            context = parent.requireContext();
        } catch (IllegalStateException e) {
            return null;
        }

        OsmTileMapView map = PANELS.get(container);
        if (map == null) {
            map = new OsmTileMapView(context);
            container.removeAllViews();
            container.addView(map, new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            PANELS.put(container, map);
            pruneCache(context);
        }
        return map;
    }

    private static void pruneCache(@NonNull Context context) {
        final Context appContext = context.getApplicationContext();
        new Thread(() -> OsmTileMapView.pruneDiskCache(appContext), "osm-cache-prune").start();
    }

    // --------------------------------------------------------------- plotting

    public static void plotStations(@Nullable OsmTileMapView map,
                                    @Nullable List<ChargerStation> stations,
                                    @Nullable String highlightStationId) {
        plotStations(map, stations, highlightStationId, null, null);
    }

    /**
     * Draws stations and, when the user's position is known, a distinct "you are here" pin as well.
     * The camera frames both, so opening the screen starts on the user rather than a fixed point.
     */
    public static void plotStations(@Nullable OsmTileMapView map,
                                    @Nullable List<ChargerStation> stations,
                                    @Nullable String highlightStationId,
                                    @Nullable Double userLat, @Nullable Double userLng) {
        if (map == null) {
            return;
        }
        boolean hasUser = userLat != null && userLng != null;
        List<ChargerStation> safeStations = stations == null
                ? java.util.Collections.emptyList() : stations;
        if (safeStations.isEmpty() && !hasUser) {
            return;
        }
        List<OsmTileMapView.Pin> pins = new ArrayList<>();
        double north = -90, south = 90, east = -180, west = 180;
        boolean anyPoint = false;
        for (ChargerStation station : safeStations) {
            boolean highlight = station.getId().equals(highlightStationId);
            int fill = highlight
                    ? R.color.amp_secondary
                    : station.supportsPaidEnergyBilling() ? R.color.amp_primary : R.color.amp_warning;
            pins.add(pinAt(map, station.getLatitude(), station.getLongitude(), station.getName(),
                    fill));
            north = Math.max(north, station.getLatitude());
            south = Math.min(south, station.getLatitude());
            east = Math.max(east, station.getLongitude());
            west = Math.min(west, station.getLongitude());
            anyPoint = true;
        }
        if (hasUser) {
            pins.add(userPin(map, userLat, userLng));
            north = Math.max(north, userLat);
            south = Math.min(south, userLat);
            east = Math.max(east, userLng);
            west = Math.min(west, userLng);
            anyPoint = true;
        }
        if (!anyPoint) {
            return;
        }
        map.setPins(pins);
        if (hasUser && safeStations.isEmpty()) {
            map.setCamera(userLat, userLng, 13f);
        } else {
            map.frameTo(north, south, east, west, 11f);
        }
    }

    /**
     * Draws a real road route (an OSRM polyline) with the user's starting point and the destination.
     */
    public static void plotRoadRoute(@Nullable OsmTileMapView map, @Nullable List<double[]> line,
                                     double fromLat, double fromLng, double toLat, double toLng,
                                     @Nullable String destinationLabel) {
        if (map == null || line == null || line.size() < 2) {
            return;
        }
        map.setRoute(line);
        List<OsmTileMapView.Pin> pins = new ArrayList<>();
        pins.add(userPin(map, fromLat, fromLng));
        pins.add(pinAt(map, toLat, toLng, destinationLabel, R.color.amp_primary));
        map.setPins(pins);
        double north = Math.max(fromLat, toLat);
        double south = Math.min(fromLat, toLat);
        double east = Math.max(fromLng, toLng);
        double west = Math.min(fromLng, toLng);
        map.frameTo(north, south, east, west, 13f);
    }

    /** Places the camera on a single point, used when there is a user position but no stations. */
    public static void centerOn(@Nullable OsmTileMapView map, double latitude, double longitude,
                                float zoom) {
        if (map == null) {
            return;
        }
        map.setCamera(latitude, longitude, zoom);
    }

    /** A "you are here" pin, drawn in the route accent colour so it never reads as a charger. */
    private static OsmTileMapView.Pin userPin(@NonNull OsmTileMapView map, double latitude,
                                              double longitude) {
        return new OsmTileMapView.Pin(latitude, longitude, "Your location",
                ContextCompat.getColor(map.getContext(), R.color.amp_secondary),
                ContextCompat.getColor(map.getContext(), R.color.white));
    }

    /**
     * Draws the corridor: the route line itself, the two endpoints, and every compatible charger
     * along it. The recommended stop is the one drawn in the accent colour.
     */
    public static void plotRoute(@Nullable OsmTileMapView map, double originLat, double originLng,
                                 double destLat, double destLng,
                                 @Nullable List<ChargerStation> corridorStations,
                                 @Nullable String highlightStationId) {
        if (map == null) {
            return;
        }
        List<double[]> line = new ArrayList<>();
        for (int i = 0; i <= 24; i++) {
            line.add(geodesicPoint(originLat, originLng, destLat, destLng, i / 24d));
        }
        map.setRoute(line);

        List<OsmTileMapView.Pin> pins = new ArrayList<>();
        pins.add(pinAt(map, originLat, originLng, "Start", R.color.amp_on_surface_variant));
        pins.add(pinAt(map, destLat, destLng, "Destination", R.color.amp_on_surface_variant));

        double north = Math.max(originLat, destLat);
        double south = Math.min(originLat, destLat);
        double east = Math.max(originLng, destLng);
        double west = Math.min(originLng, destLng);

        if (corridorStations != null) {
            for (ChargerStation station : corridorStations) {
                boolean highlight = station.getId().equals(highlightStationId);
                pins.add(pinAt(map, station.getLatitude(), station.getLongitude(), station.getName(),
                        highlight ? R.color.amp_secondary : R.color.amp_primary));
                north = Math.max(north, station.getLatitude());
                south = Math.min(south, station.getLatitude());
                east = Math.max(east, station.getLongitude());
                west = Math.min(west, station.getLongitude());
            }
        }
        map.setPins(pins);
        map.fitTo(north, south, east, west, 8f);
    }

    private static OsmTileMapView.Pin pinAt(@NonNull OsmTileMapView map, double latitude,
                                            double longitude, @Nullable String title) {
        return pinAt(map, latitude, longitude, title, R.color.amp_primary);
    }

    private static OsmTileMapView.Pin pinAt(@NonNull OsmTileMapView map, double latitude,
                                            double longitude, @Nullable String title, int fillRes) {
        return new OsmTileMapView.Pin(latitude, longitude, title,
                ContextCompat.getColor(map.getContext(), fillRes),
                ContextCompat.getColor(map.getContext(), R.color.white));
    }

    /** A great-circle point, so the drawn route bends the way a real path does. */
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

    /** True when the device currently has a usable network, checked the modern way. */
    public static boolean hasNetwork(@Nullable Context context) {
        if (context == null) {
            return false;
        }
        try {
            ConnectivityManager manager = (ConnectivityManager)
                    context.getSystemService(Context.CONNECTIVITY_SERVICE);
            if (manager == null) {
                return false;
            }
            Network network = manager.getActiveNetwork();
            if (network == null) {
                return false;
            }
            NetworkCapabilities capabilities = manager.getNetworkCapabilities(network);
            return capabilities != null
                    && capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET);
        } catch (Exception e) {
            return false;
        }
    }

}
