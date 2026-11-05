package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.car.app.CarContext;
import androidx.car.app.Screen;
import androidx.car.app.annotations.ExperimentalCarApi;
import androidx.car.app.model.Action;
import androidx.car.app.model.ActionStrip;
import androidx.car.app.model.ItemList;
import androidx.car.app.model.ListTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;
import androidx.car.app.navigation.model.MapController;
import androidx.car.app.navigation.model.MapWithContentTemplate;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import com.amperly.app.R;
import com.amperly.app.car.CarBridge;
import com.amperly.app.car.CarConstraints;
import com.amperly.app.car.CarLimits;
import com.amperly.app.car.CarLocation;
import com.amperly.app.car.CarSessionAuth;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.RoutePlan;
import com.amperly.app.data.repository.AmperlyRepository;

import java.util.ArrayList;
import java.util.List;

/**
 * The main car screen: a live map on the display with a left-hand content pane carrying the trip
 * summary and the four safe actions.
 *
 * <p>{@link MapWithContentTemplate} is the only template in the car app library that draws content
 * next to a map, and the host puts that content pane on the left of a wide display. The map itself
 * is painted by {@link CarMap} into the host's surface; without that the template reserves the map
 * area but leaves it black.
 *
 * <p>The pane is capped at four rows through the host's {@code ConstraintManager}. Everything else
 * (battery update, reservation, trip history, vehicle, settings) lives on {@link MoreCarScreen}, so
 * the main glance never becomes a wall of text.
 *
 * <p>The template needs car API level 7, so on older hosts this screen falls back to the plain list
 * it used before instead of handing the host a template it cannot draw.
 */
public class RouteOverviewCarScreen extends Screen {

    private final AmperlyRepository repo;
    private final CarMap carMap;

    @Nullable private CarBridge.Snapshot snapshot;
    @Nullable private CarLocation.Fix fix;
    private boolean permissionDenied;
    private boolean loading;
    private boolean authStarted;
    private boolean authReady;
    private boolean authFailed;

    public RouteOverviewCarScreen(@NonNull CarContext carContext) {
        super(carContext);
        this.repo = AmperlyRepository.getInstance(carContext);
        this.carMap = new CarMap(carContext);

        // The helper registers itself on this screen's lifecycle, so fixes start and stop with the
        // projection instead of running in the background.
        new CarLocation(this, (location, denied) -> {
            fix = location;
            permissionDenied = denied;
            updateMap();
            invalidate();
        });

        getLifecycle().addObserver(new DefaultLifecycleObserver() {
            @Override
            public void onStart(@NonNull LifecycleOwner owner) {
                carMap.start();
                updateMap();
            }

            @Override
            public void onStop(@NonNull LifecycleOwner owner) {
                carMap.stop();
            }
        });
    }

    @NonNull
    @Override
    @OptIn(markerClass = ExperimentalCarApi.class)
    public Template onGetTemplate() {
        if (!authStarted) {
            authStarted = true;
            CarSessionAuth.ensureSignedIn(getCarContext(), signedIn -> {
                authReady = signedIn;
                authFailed = !signedIn;
                if (signedIn) {
                    loadSnapshot();
                }
                updateMap();
                invalidateIfStarted();
            });
        }
        loadSnapshot();

        updateMap();
        ItemList rows = buildRows();
        String title = getCarContext().getString(R.string.car_title);

        if (!CarLimits.supportsMapWithContent(getCarContext().getCarAppApiLevel())) {
            // A host below car API 7 cannot draw a map with side content; the list is the fallback.
            return new ListTemplate.Builder()
                    .setTitle(title)
                    .setHeaderAction(Action.APP_ICON)
                    .setSingleList(rows)
                    .setActionStrip(buildActionStrip())
                    .build();
        }

        // The list inside MapWithContentTemplate carries no action strip of its own: the template
        // strip below is the single strip on screen.
        ListTemplate sidebar = new ListTemplate.Builder()
                .setTitle(title)
                .setHeaderAction(Action.APP_ICON)
                .setSingleList(rows)
                .build();

        return new MapWithContentTemplate.Builder()
                .setContentTemplate(sidebar)
                .setMapController(new MapController.Builder().build())
                .setActionStrip(buildActionStrip())
                .build();
    }

    private void loadSnapshot() {
        if (!authReady || snapshot != null || loading) {
            return;
        }
        loading = true;
        CarBridge.load(repo, value -> {
            snapshot = value;
            loading = false;
            updateMap();
            invalidateIfStarted();
        });
    }

    /**
     * The side pane: the live trip, the recommended stop, the charger list and More. Four rows at
     * most, whatever the host would allow.
     */
    @NonNull
    private ItemList buildRows() {
        List<Row> rows = new ArrayList<>();

        if (authFailed) {
            rows.add(new Row.Builder()
                    .setTitle(getString(R.string.car_session_unavailable_title))
                    .addText(getString(R.string.car_session_unavailable_text))
                    .build());
        } else if (!authReady || snapshot == null) {
            rows.add(new Row.Builder()
                    .setTitle(getString(R.string.car_loading_trip_title))
                    .addText(getString(R.string.car_loading_trip_text))
                    .build());
        } else {
            RoutePlan plan = snapshot.getPlan();
            if (plan == null) {
                rows.add(new Row.Builder()
                        .setTitle(getString(R.string.car_no_trip_title))
                        .addText(getString(R.string.car_no_trip_text))
                        .build());
            } else {
                rows.add(tripRow(plan));
                rows.add(recommendedRow());
            }

            int reachable = snapshot.getReachableStations().size();
            rows.add(new Row.Builder()
                    .setTitle(getString(R.string.car_chargers_title))
                    .addText(getString(R.string.car_chargers_text, reachable))
                    .setOnClickListener(() -> getScreenManager().push(
                            new ChargerListCarScreen(getCarContext())))
                    .build());

            rows.add(new Row.Builder()
                    .setTitle(getString(R.string.car_more_title))
                    .addText(getString(R.string.car_more_text))
                    .setOnClickListener(() -> getScreenManager().push(
                            new MoreCarScreen(getCarContext())))
                    .build());
        }

        int limit = CarConstraints.listLimit(getCarContext(), CarLimits.MAIN_PANE_MAX_ROWS);
        ItemList.Builder list = new ItemList.Builder();
        for (int i = 0; i < rows.size() && i < limit; i++) {
            list.addItem(rows.get(i));
        }
        return list.build();
    }

    @NonNull
    private Row tripRow(@NonNull RoutePlan plan) {
        String kind = getString(snapshot.isSocAuthoritative()
                ? R.string.nav_car_actual : R.string.nav_car_estimated);
        return new Row.Builder()
                .setTitle(getString(R.string.car_trip_title))
                .addText(getString(R.string.car_trip_route, safe(plan.getOrigin()),
                        safe(plan.getDestination())))
                .addText(getString(R.string.car_trip_summary,
                        Math.round(plan.getTotalDistanceKm()),
                        Math.max(0, snapshot.getCurrentSoc()), kind))
                .build();
    }

    @NonNull
    private Row recommendedRow() {
        ChargerStation station = snapshot.getRecommendedStation();
        if (station == null) {
            boolean hasWarning = snapshot.getNoSafeChargerMessage() != null
                    && !snapshot.getNoSafeChargerMessage().isEmpty();
            return new Row.Builder()
                    .setTitle(getString(hasWarning
                            ? R.string.car_no_safe_title : R.string.car_no_stop_title))
                    .addText(getString(hasWarning
                            ? R.string.car_no_safe_text : R.string.car_no_stop_text))
                    .build();
        }

        Row.Builder builder = new Row.Builder()
                .setTitle(getString(R.string.car_recommended_title))
                .addText(safe(station.getName()))
                .addText(recommendedDetail(station))
                .setOnClickListener(() -> getScreenManager().push(
                        new ChargerDetailsCarScreen(getCarContext(), station.getId())));
        return builder.build();
    }

    /** Detour and power only: the price belongs on the charger details screen. */
    @NonNull
    private String recommendedDetail(@NonNull ChargerStation station) {
        String base = getString(R.string.car_detour, snapshot.getRecommendedDetourKm(),
                Math.round(station.getMaxPowerKw()));
        String connectors = Formatters.connectorTypes(station.getConnectorTypes());
        return connectors.isEmpty() ? base : base + " · " + connectors;
    }

    /** Centres the painted map on the driver and marks the chargers and destination. */
    private void updateMap() {
        RoutePlan plan = snapshot == null ? null : snapshot.getPlan();
        List<CarMap.Pin> pins = new ArrayList<>();

        if (plan != null) {
            pins.add(CarMap.destination(plan.getDestinationLat(), plan.getDestinationLng()));
        }
        if (snapshot != null) {
            ChargerStation recommended = snapshot.getRecommendedStation();
            if (recommended != null) {
                pins.add(CarMap.station(recommended.getLatitude(), recommended.getLongitude()));
            }
            for (ChargerStation station : snapshot.getReachableStations()) {
                if (pins.size() >= 6) {
                    break;
                }
                if (recommended != null && station.getId().equals(recommended.getId())) {
                    continue;
                }
                pins.add(CarMap.station(station.getLatitude(), station.getLongitude()));
            }
        }

        String notice;
        if (permissionDenied) {
            notice = getString(R.string.car_location_permission_denied);
        } else if (fix == null) {
            notice = plan == null ? getString(R.string.car_map_waiting_location)
                    : getString(R.string.car_map_waiting_trip);
        } else {
            notice = null;
        }
        carMap.show(fix, pins, notice);
    }

    /**
     * The single strip along the bottom of the whole screen. Navigation hands off to the installed
     * maps app, so no navigation template or navigation category is needed.
     */
    @NonNull
    private ActionStrip buildActionStrip() {
        ActionStrip.Builder strip = new ActionStrip.Builder();
        if (snapshot != null && snapshot.getPlan() != null) {
            strip.addAction(new Action.Builder()
                    .setTitle(getString(R.string.car_start_navigation))
                    .setOnClickListener(this::startNavigation)
                    .build());
        }
        strip.addAction(new Action.Builder()
                .setTitle(getString(R.string.nav_car_battery_action))
                .setOnClickListener(() -> getScreenManager().push(
                        new SoCUpdateCarScreen(getCarContext())))
                .build());
        return strip.build();
    }

    /** Opens the next stop (or the destination) in the driver's installed maps application. */
    private void startNavigation() {
        if (snapshot == null || snapshot.getPlan() == null) {
            return;
        }
        ChargerStation stop = snapshot.getRecommendedStation();
        if (stop != null) {
            Navigator.navigateToCar(getCarContext(), stop.getLatitude(), stop.getLongitude());
            return;
        }
        RoutePlan plan = snapshot.getPlan();
        Navigator.navigateToCar(getCarContext(), plan.getDestinationLat(), plan.getDestinationLng());
    }

    private void invalidateIfStarted() {
        if (getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.STARTED)) {
            invalidate();
        }
    }

    @NonNull
    private String getString(int resourceId, Object... args) {
        return getCarContext().getString(resourceId, args);
    }

    @NonNull
    private static String safe(@Nullable String value) {
        return value == null ? "" : value;
    }
}
