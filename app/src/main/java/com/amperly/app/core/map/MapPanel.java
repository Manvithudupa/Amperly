package com.amperly.app.core.map;

import android.content.Context;
import android.graphics.PointF;
import android.os.SystemClock;
import android.util.Log;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;

import com.amperly.app.R;
import com.amperly.app.core.common.MapConfig;
import com.amperly.app.core.routing.DirectionsRoute;
import com.amperly.app.data.local.entity.ChargerStation;
import com.google.gson.JsonObject;

import org.maplibre.android.MapLibre;
import org.maplibre.android.camera.CameraUpdateFactory;
import org.maplibre.android.geometry.LatLng;
import org.maplibre.android.geometry.LatLngBounds;
import org.maplibre.android.maps.MapLibreMap;
import org.maplibre.android.maps.MapView;
import org.maplibre.android.maps.Style;
import org.maplibre.android.style.expressions.Expression;
import org.maplibre.android.style.layers.CircleLayer;
import org.maplibre.android.style.layers.LineLayer;
import org.maplibre.android.style.layers.Property;
import org.maplibre.android.style.layers.PropertyFactory;
import org.maplibre.android.style.sources.GeoJsonSource;
import org.maplibre.geojson.Feature;
import org.maplibre.geojson.FeatureCollection;
import org.maplibre.geojson.LineString;
import org.maplibre.geojson.Point;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.WeakHashMap;

/**
 * The production map: MapLibre Native rendering an OpenStreetMap-based vector style.
 *
 * <p>Everything drawn here — the basemap, the user-registered charger circles, the driver's
 * position, the picker pin and the road route — is a GeoJSON source in the Geoapify style, so the
 * map never touches {@code tile.openstreetmap.org} (whose usage policy forbids use by a shipped
 * app). When no key is configured the panel shows an actionable setup notice instead of a blank
 * map.
 *
 * <p>One {@link MapView} per container, tracked in {@link #PANELS}, so asking for the same panel
 * twice (as the discovery screen does) reuses it. The view's full lifecycle is forwarded from the
 * parent fragment's <em>view</em> lifecycle, and the map is destroyed with that view; calling
 * {@link #attach} again after a configuration change therefore builds a fresh, working map.
 *
 * <p>Attribution: MapLibre's own attribution control stays visible and enabled (it carries the
 * OpenStreetMap and Geoapify credit the data licence and the free plan require), and the planner
 * screen also shows the plain-text credit.
 */
public final class MapPanel {

    /** Reports a charger the driver tapped, so the screen can open its details. */
    public interface MarkerTap {
        void onStation(@Nullable ChargerStation station);
    }

    /** Reports a point the driver tapped on the map, used to place a charger or a trip origin. */
    public interface MapTap {
        void onPoint(double latitude, double longitude);
    }

    /** A ready-to-use map. */
    public interface Ready {
        void onReady(@NonNull MapPanel panel);
    }

    private static final String TAG = "MapPanel";

    // Source and layer ids are constants so a re-applied style can never drift from the code.
    private static final String SOURCE_STATIONS = "amperly-stations";
    private static final String LAYER_STATIONS = "amperly-stations-circles";
    private static final String LAYER_STATIONS_HIGHLIGHT = "amperly-stations-highlight";
    private static final String SOURCE_ROUTE = "amperly-route";
    private static final String LAYER_ROUTE = "amperly-route-line";
    private static final String SOURCE_ROUTE_ENDS = "amperly-route-ends";
    private static final String LAYER_ROUTE_ENDS = "amperly-route-ends-circles";
    private static final String SOURCE_PICKER = "amperly-picker";
    private static final String LAYER_PICKER = "amperly-picker-circle";
    private static final String SOURCE_USER = "amperly-user";
    private static final String LAYER_USER = "amperly-user-circle";

    private static final String COLOR_STROKE = "#FFFFFF";
    /** A soft primary halo behind the selected charger, so the pick is unmistakable. */
    private static final String COLOR_HIGHLIGHT_HALO = "#0F5C4D";
    private static final String COLOR_START = "#0F5C4D";
    private static final String COLOR_DESTINATION = "#B3261E";
    private static final String COLOR_PICKER = "#F2A516";
    private static final String COLOR_USER = "#1D4ED8";
    private static final String COLOR_APPROXIMATE = "#B45309";
    private static final int MAP_PADDING_PX = 120;
    /** How long a finger gesture keeps the camera away from the driver's position. */
    private static final long GESTURE_GRACE_MS = 12_000L;

    /** {@code highlighted} is a string property so the filter needs no boolean expression. */
    private static final String HIGHLIGHTED = "yes";
    private static final String NOT_HIGHLIGHTED = "no";

    /** One map per container, so a re-attach reuses the same map. */
    private static final Map<ViewGroup, MapPanel> PANELS = new WeakHashMap<>();
    private static volatile boolean mapLibreInitialised;

    private final MapView mapView;
    private final Context appContext;
    private final Map<String, ChargerStation> stationsById = new HashMap<>();
    @Nullable private MapLibreMap map;
    @Nullable private Style style;
    @Nullable private MarkerTap markerTap;
    @Nullable private MapTap mapTap;
    @Nullable private double[] picker;
    private boolean pickerDraggable;
    /** Last time the driver moved the camera by hand, so following never fights a gesture. */
    private long lastGestureMs;

    private MapPanel(@NonNull MapView mapView, @NonNull Context appContext) {
        this.mapView = mapView;
        this.appContext = appContext;
    }

    // ------------------------------------------------------------- attaching

    /**
     * Shows a map inside {@code container}. Building the view is deferred to the container's first
     * layout so creating the map never delays the rest of the screen from painting.
     */
    public static void attach(@NonNull Fragment parent, @Nullable ViewGroup container,
                              @NonNull Ready callback) {
        if (container == null) {
            return;
        }
        if (!MapConfig.isConfigured()) {
            showSetupNotice(parent, container);
            return;
        }
        container.post(() -> {
            // The screen may have been replaced before this ran (a tab switch, a back press).
            // Touching requireContext() on a detached fragment throws, and the crash would land on
            // the main thread with no screen left to catch it.
            if (!parent.isAdded() || container.getParent() == null) {
                return;
            }
            MapPanel existing = PANELS.get(container);
            if (existing != null && existing.map != null) {
                callback.onReady(existing);
                return;
            }
            Context context;
            try {
                context = parent.requireContext().getApplicationContext();
            } catch (IllegalStateException e) {
                return;
            }
            MapPanel panel = new MapPanel(createMapView(context), context);
            PANELS.put(container, panel);
            panel.bindLifecycle(parent, container);
            container.removeAllViews();
            container.addView(panel.mapView, new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            panel.mapView.getMapAsync(readyMap -> {
                if (!parent.isAdded()) {
                    return;
                }
                panel.onMapReady(readyMap, callback);
            });
        });
    }

    @NonNull
    private static MapView createMapView(@NonNull Context context) {
        if (!mapLibreInitialised) {
            // Must happen once, before any MapView exists, or the native renderer cannot start.
            MapLibre.getInstance(context);
            mapLibreInitialised = true;
        }
        return new MapView(context);
    }

    /** Forwards the MapView's lifecycle from the fragment's view lifecycle. */
    private void bindLifecycle(@NonNull Fragment parent, @NonNull ViewGroup container) {
        final MapView view = mapView;
        final Lifecycle lifecycle;
        try {
            lifecycle = parent.getViewLifecycleOwner().getLifecycle();
        } catch (IllegalStateException e) {
            // No view lifecycle (the fragment is already gone): the map can still be created, it
            // simply will not receive lifecycle events, and the container is discarded with it.
            view.onCreate(null);
            return;
        }
        lifecycle.addObserver((LifecycleEventObserver) (source, event) -> {
            switch (event) {
                case ON_CREATE:
                    view.onCreate(null);
                    break;
                case ON_START:
                    view.onStart();
                    break;
                case ON_RESUME:
                    view.onResume();
                    break;
                case ON_PAUSE:
                    view.onPause();
                    break;
                case ON_STOP:
                    view.onStop();
                    break;
                case ON_DESTROY:
                    PANELS.remove(container);
                    map = null;
                    style = null;
                    view.onDestroy();
                    break;
                default:
                    break;
            }
        });
    }

    private void onMapReady(@NonNull MapLibreMap readyMap, @NonNull Ready callback) {
        this.map = readyMap;
        readyMap.addOnMapClickListener(this::handleMapClick);
        // A pan or pinch is the driver taking control; auto-follow waits until they stop.
        readyMap.addOnCameraMoveStartedListener(reason -> {
            if (reason == MapLibreMap.OnCameraMoveStartedListener.REASON_API_GESTURE) {
                lastGestureMs = SystemClock.elapsedRealtime();
            }
        });
        readyMap.setStyle(new Style.Builder().fromUri(MapConfig.styleUrl()), loaded -> {
            this.style = loaded;
            installSourcesAndLayers(loaded);
            callback.onReady(this);
        });
    }

    /** Replaces the map with a clear notice when no key was configured at build time. */
    private static void showSetupNotice(@NonNull Fragment parent, @NonNull ViewGroup container) {
        Context context;
        try {
            context = parent.requireContext();
        } catch (IllegalStateException e) {
            return;
        }
        container.removeAllViews();
        TextView notice = new TextView(context);
        notice.setText(MapConfig.setupMessage(context));
        notice.setTextAppearance(R.style.TextAppearance_Amperly_Body);
        notice.setGravity(Gravity.CENTER);
        notice.setPadding(24, 24, 24, 24);
        notice.setTextColor(ContextCompat.getColor(context, R.color.amp_ink_secondary));
        container.addView(notice, new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
    }

    // ------------------------------------------------------------- style setup

    /**
     * Creates every source and layer once, empty, in a stable order.
     *
     * <p>Layers are never removed afterwards: clearing a plot means emptying its source, which
     * keeps the tap handling and the z-order predictable, and avoids the "source is in use" error
     * that removing a source under a live layer would raise.
     */
    private void installSourcesAndLayers(@NonNull Style loaded) {
        loaded.addSource(new GeoJsonSource(SOURCE_STATIONS, emptyCollection()));
        loaded.addSource(new GeoJsonSource(SOURCE_ROUTE, emptyCollection()));
        loaded.addSource(new GeoJsonSource(SOURCE_ROUTE_ENDS, emptyCollection()));
        loaded.addSource(new GeoJsonSource(SOURCE_PICKER, emptyCollection()));
        loaded.addSource(new GeoJsonSource(SOURCE_USER, emptyCollection()));

        loaded.addLayer(new CircleLayer(LAYER_USER, SOURCE_USER).withProperties(
                PropertyFactory.circleColor(COLOR_USER),
                PropertyFactory.circleRadius(7f),
                PropertyFactory.circleStrokeWidth(2f),
                PropertyFactory.circleStrokeColor(COLOR_STROKE)));

        loaded.addLayer(new LineLayer(LAYER_ROUTE, SOURCE_ROUTE).withProperties(
                PropertyFactory.lineColor(Expression.get("color")),
                PropertyFactory.lineWidth(5f),
                PropertyFactory.lineCap(Property.LINE_CAP_ROUND),
                PropertyFactory.lineJoin(Property.LINE_JOIN_ROUND)));

        loaded.addLayer(new CircleLayer(LAYER_ROUTE_ENDS, SOURCE_ROUTE_ENDS).withProperties(
                PropertyFactory.circleColor(Expression.get("color")),
                PropertyFactory.circleRadius(7f),
                PropertyFactory.circleStrokeWidth(2f),
                PropertyFactory.circleStrokeColor(COLOR_STROKE)));

        loaded.addLayer(new CircleLayer(LAYER_STATIONS, SOURCE_STATIONS).withProperties(
                PropertyFactory.circleColor(Expression.get("color")),
                PropertyFactory.circleRadius(9f),
                PropertyFactory.circleStrokeWidth(2f),
                PropertyFactory.circleStrokeColor(COLOR_STROKE)));

        // A translucent primary halo sits under the selected marker: the ring reads at a glance
        // without making the other markers any smaller or hiding the charger's own colour.
        loaded.addLayerBelow(new CircleLayer(LAYER_STATIONS_HIGHLIGHT, SOURCE_STATIONS)
                .withFilter(Expression.eq(Expression.get("highlighted"),
                        Expression.literal(HIGHLIGHTED)))
                .withProperties(
                        PropertyFactory.circleColor(COLOR_HIGHLIGHT_HALO),
                        PropertyFactory.circleOpacity(0.22f),
                        PropertyFactory.circleRadius(22f),
                        PropertyFactory.circleStrokeWidth(2f),
                        PropertyFactory.circleStrokeColor(COLOR_HIGHLIGHT_HALO),
                        PropertyFactory.circleStrokeOpacity(0.9f)),
                LAYER_STATIONS);

        loaded.addLayer(new CircleLayer(LAYER_PICKER, SOURCE_PICKER).withProperties(
                PropertyFactory.circleColor(COLOR_PICKER),
                PropertyFactory.circleRadius(10f),
                PropertyFactory.circleStrokeWidth(3f),
                PropertyFactory.circleStrokeColor(COLOR_STROKE)));
    }

    // ------------------------------------------------------------- plotting

    public void setMarkerTapListener(@Nullable MarkerTap listener) {
        this.markerTap = listener;
    }

    public void setMapTapListener(@Nullable MapTap listener) {
        this.mapTap = listener;
    }

    /** Centres the camera on a point. */
    public void centerOn(double latitude, double longitude, float zoom) {
        MapLibreMap current = map;
        if (current == null) {
            return;
        }
        current.moveCamera(CameraUpdateFactory.newLatLngZoom(
                new LatLng(latitude, longitude), zoom));
    }

    /**
     * Follows the driver while navigating, unless they have just panned the map themselves.
     *
     * <p>Navigation re-reads the position every few seconds; without the gesture check the camera
     * snapped back mid-pan, which read as the map ignoring the finger.
     */
    public void followUser(double latitude, double longitude, float zoom) {
        MapLibreMap current = map;
        if (current == null) {
            return;
        }
        if (SystemClock.elapsedRealtime() - lastGestureMs < GESTURE_GRACE_MS) {
            return;
        }
        current.animateCamera(CameraUpdateFactory.newLatLngZoom(
                new LatLng(latitude, longitude), zoom), 700);
    }

    /** Draws the driver's own position without clearing the route around it. */
    public void plotDriverPosition(double latitude, double longitude) {
        if (map == null || style == null) {
            return;
        }
        setSource(SOURCE_USER, single(pointFeature(null, COLOR_USER, false, longitude, latitude)));
    }

    /**
     * Draws the user-registered chargers and, when known, the driver's own position. The camera
     * follows the driver when there is a fix, otherwise it frames every marker.
     */
    public void plotStations(@Nullable List<ChargerStation> stations,
                             @Nullable String highlightStationId,
                             @Nullable Double userLat, @Nullable Double userLng) {
        if (map == null || style == null) {
            return;
        }
        clearAll();
        List<ChargerStation> safe = stations == null ? new ArrayList<>() : stations;
        List<Feature> features = new ArrayList<>();
        LatLngBounds.Builder bounds = new LatLngBounds.Builder();
        boolean any = false;
        double fallbackLat = 0;
        double fallbackLng = 0;

        for (ChargerStation station : safe) {
            if (!isPlotable(station)) {
                continue;
            }
            boolean highlighted = station.getId().equals(highlightStationId);
            features.add(stationFeature(station, highlighted));
            stationsById.put(station.getId(), station);
            bounds.include(new LatLng(station.getLatitude(), station.getLongitude()));
            if (!any) {
                fallbackLat = station.getLatitude();
                fallbackLng = station.getLongitude();
            }
            any = true;
        }
        setSource(SOURCE_STATIONS, features);

        if (userLat != null && userLng != null) {
            setSource(SOURCE_USER, single(pointFeature(null, COLOR_USER, false, userLng, userLat)));
            bounds.include(new LatLng(userLat, userLng));
            any = true;
        }

        if (!any) {
            return;
        }
        ChargerStation highlighted = highlightStationId == null
                ? null : stationsById.get(highlightStationId);
        if (highlighted != null) {
            // A chosen charger is the thing to look at: point at it, not at the middle of a list.
            centerOn(highlighted.getLatitude(), highlighted.getLongitude(), 15f);
        } else if (userLat != null && userLng != null) {
            // "Where am I, what is near me": the driver's own position wins the camera, and nearby
            // chargers fall inside the view on their own.
            centerOn(userLat, userLng, 13f);
        } else {
            frameTo(bounds, fallbackLat, fallbackLng);
        }
    }

    /** Draws a road route with its endpoints and the charging stops along it. */
    public void plotRoute(@Nullable DirectionsRoute route, double originLat, double originLng,
                          double destinationLat, double destinationLng,
                          @Nullable List<ChargerStation> corridorStations,
                          @Nullable String highlightStationId) {
        if (map == null || style == null) {
            return;
        }
        clearAll();
        LatLngBounds.Builder bounds = new LatLngBounds.Builder();
        bounds.include(new LatLng(originLat, originLng));
        bounds.include(new LatLng(destinationLat, destinationLng));

        if (route != null && route.getPoints().size() >= 2) {
            String colour = route.isApproximate() ? COLOR_APPROXIMATE
                    : hex(ContextCompat.getColor(appContext, R.color.amp_primary));
            List<Point> line = new ArrayList<>();
            for (double[] point : route.getPoints()) {
                line.add(Point.fromLngLat(point[1], point[0]));
                bounds.include(new LatLng(point[0], point[1]));
            }
            JsonObject properties = new JsonObject();
            properties.addProperty("color", colour);
            setSource(SOURCE_ROUTE, single(Feature.fromGeometry(
                    LineString.fromLngLats(line), properties)));
        }

        setSource(SOURCE_ROUTE_ENDS, listOf(
                pointFeature(null, COLOR_START, false, originLng, originLat),
                pointFeature(null, COLOR_DESTINATION, false, destinationLng, destinationLat)));

        if (corridorStations != null) {
            List<Feature> features = new ArrayList<>();
            for (ChargerStation station : corridorStations) {
                if (!isPlotable(station)) {
                    continue;
                }
                boolean highlighted = station.getId().equals(highlightStationId);
                features.add(stationFeature(station, highlighted));
                stationsById.put(station.getId(), station);
                bounds.include(new LatLng(station.getLatitude(), station.getLongitude()));
            }
            setSource(SOURCE_STATIONS, features);
        }

        frameTo(bounds, originLat, originLng);
    }

    /**
     * Shows a single pinned point, used when a host places a charger by hand.
     *
     * <p>MapLibre has no draggable marker, so {@code draggable} means "a tap on the map moves the
     * pin", which is the same deliberate gesture with one finger instead of a drag.
     */
    public void plotPicker(double latitude, double longitude, @Nullable String label,
                           boolean draggable) {
        if (map == null || style == null) {
            return;
        }
        clearAll();
        picker = new double[]{latitude, longitude};
        pickerDraggable = draggable;
        setSource(SOURCE_PICKER, single(pickerFeature(latitude, longitude, label)));
        centerOn(latitude, longitude, 16f);
    }

    /** Moves the picker marker without rebuilding it, used when a host types new coordinates. */
    public void movePickerTo(double latitude, double longitude) {
        if (map == null || style == null) {
            return;
        }
        picker = new double[]{latitude, longitude};
        setSource(SOURCE_PICKER, single(pickerFeature(latitude, longitude, null)));
        centerOn(latitude, longitude, 16f);
    }

    /** The coordinates of the picker marker as {@code {lat, lng}}, or null when there is none. */
    @Nullable
    public double[] pickerPosition() {
        double[] current = picker;
        return current == null ? null : new double[]{current[0], current[1]};
    }

    // ------------------------------------------------------------- taps

    private boolean handleMapClick(@NonNull LatLng point) {
        MapLibreMap current = map;
        if (current == null) {
            return false;
        }
        try {
            PointF screen = current.getProjection().toScreenLocation(point);
            List<Feature> hits = current.queryRenderedFeatures(screen,
                    LAYER_STATIONS, LAYER_STATIONS_HIGHLIGHT);
            if (hits != null && !hits.isEmpty() && markerTap != null) {
                String id = hits.get(0).getStringProperty("id");
                markerTap.onStation(id == null ? null : stationsById.get(id));
                return true;
            }
        } catch (RuntimeException e) {
            // A tap that lands before the first frame is rendered has nothing to hit; treating it
            // as a plain map tap below is the right answer.
            Log.w(TAG, "Could not query the tapped point", e);
        }
        boolean movedPicker = false;
        if (pickerDraggable && picker != null) {
            movePickerTo(point.getLatitude(), point.getLongitude());
            movedPicker = true;
        }
        if (mapTap != null) {
            mapTap.onPoint(point.getLatitude(), point.getLongitude());
            return true;
        }
        return movedPicker;
    }

    // ------------------------------------------------------------- helpers

    private void clearAll() {
        stationsById.clear();
        setSource(SOURCE_STATIONS, new ArrayList<>());
        setSource(SOURCE_ROUTE, new ArrayList<>());
        setSource(SOURCE_ROUTE_ENDS, new ArrayList<>());
        setSource(SOURCE_PICKER, new ArrayList<>());
        setSource(SOURCE_USER, new ArrayList<>());
    }

    private void setSource(@NonNull String sourceId, @NonNull List<Feature> features) {
        Style current = style;
        if (current == null) {
            return;
        }
        GeoJsonSource source = current.getSourceAs(sourceId);
        if (source != null) {
            source.setGeoJson(FeatureCollection.fromFeatures(
                    features.toArray(new Feature[0])));
        }
    }

    private void frameTo(@NonNull LatLngBounds.Builder bounds, double fallbackLat,
                         double fallbackLng) {
        MapLibreMap current = map;
        if (current == null) {
            return;
        }
        try {
            current.moveCamera(CameraUpdateFactory.newLatLngBounds(bounds.build(), MAP_PADDING_PX));
        } catch (RuntimeException e) {
            // A single point or a degenerate bounds cannot be framed; a readable zoom is better
            // than a crash or a map at world scale.
            current.moveCamera(CameraUpdateFactory.newLatLngZoom(
                    new LatLng(fallbackLat, fallbackLng), 14));
        }
    }

    @NonNull
    private static Feature stationFeature(@NonNull ChargerStation station, boolean highlighted) {
        return pointFeature(station.getId(), hex(StationMarkerModel.color(station, highlighted)),
                highlighted, station.getLongitude(), station.getLatitude());
    }

    @NonNull
    private static Feature pickerFeature(double latitude, double longitude, @Nullable String label) {
        JsonObject properties = new JsonObject();
        properties.addProperty("color", COLOR_PICKER);
        properties.addProperty("highlighted", NOT_HIGHLIGHTED);
        if (label != null) {
            properties.addProperty("label", label);
        }
        return Feature.fromGeometry(Point.fromLngLat(longitude, latitude), properties);
    }

    @NonNull
    private static Feature pointFeature(@Nullable String id, @NonNull String color,
                                        boolean highlighted, double longitude, double latitude) {
        JsonObject properties = new JsonObject();
        if (id != null) {
            properties.addProperty("id", id);
        }
        properties.addProperty("color", color);
        properties.addProperty("highlighted", highlighted ? HIGHLIGHTED : NOT_HIGHLIGHTED);
        return Feature.fromGeometry(Point.fromLngLat(longitude, latitude), properties);
    }

    @NonNull
    private static FeatureCollection emptyCollection() {
        return FeatureCollection.fromFeatures(new Feature[0]);
    }

    @NonNull
    private static List<Feature> single(@NonNull Feature feature) {
        List<Feature> features = new ArrayList<>();
        features.add(feature);
        return features;
    }

    @NonNull
    private static List<Feature> listOf(@NonNull Feature... features) {
        List<Feature> list = new ArrayList<>();
        for (Feature feature : features) {
            list.add(feature);
        }
        return list;
    }

    /** {@code #RRGGBB} for a circle layer's data-driven colour. */
    @NonNull
    private static String hex(int color) {
        return String.format(Locale.US, "#%06X", 0xFFFFFF & color);
    }

    /** Marker visibility is owned by {@link StationVisibility} so it can be unit tested. */
    static boolean isPlotable(@Nullable ChargerStation station) {
        return StationVisibility.isPlotable(station);
    }
}
