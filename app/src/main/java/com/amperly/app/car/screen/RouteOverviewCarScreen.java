package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.car.app.CarContext;
import androidx.car.app.CarToast;
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
import androidx.lifecycle.LifecycleOwner;

import com.amperly.app.R;
import com.amperly.app.car.CarBridge;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.RoutePlan;
import com.amperly.app.data.repository.AmperlyRepository;

import java.util.ArrayList;
import java.util.List;

/**
 * The main car screen: a real map on the display with a left-hand content pane carrying the trip
 * summary and every car action.
 *
 * <p>{@link MapWithContentTemplate} is the only template in the car app library that draws content
 * next to a map, and the host puts that content pane on the left of a wide display. The map itself
 * is painted by {@link CarMap} into the host's surface; without that the template reserves the map
 * area but leaves it black.
 *
 * <p>The template needs car API level 7, so on older hosts this screen falls back to the plain
 * list it used before instead of handing the host a template it cannot draw.
 */
public class RouteOverviewCarScreen extends Screen {

    /** Car API level that introduced {@link MapWithContentTemplate}. */
    private static final int CAR_API_LEVEL_MAP_WITH_CONTENT = 7;

    private final AmperlyRepository repo;
    private final CarMap carMap;
    private CarBridge.Snapshot snapshot;

    public RouteOverviewCarScreen(@NonNull CarContext carContext) {
        super(carContext);
        this.repo = AmperlyRepository.getInstance(carContext);
        this.carMap = new CarMap(carContext);
        getLifecycle().addObserver(new DefaultLifecycleObserver() {
            @Override
            public void onDestroy(@NonNull LifecycleOwner owner) {
                carMap.stop();
            }
        });
    }

    @NonNull
    @Override
    @OptIn(markerClass = ExperimentalCarApi.class)
    public Template onGetTemplate() {
        carMap.start();

        if (snapshot == null) {
            CarBridge.load(repo, value -> {
                snapshot = value;
                updateMap();
                invalidate();
            });
        }

        ListTemplate sidebar = buildSidebar();

        if (getCarContext().getCarAppApiLevel() < CAR_API_LEVEL_MAP_WITH_CONTENT) {
            // A host below car API 7 cannot draw a map with side content; the list is the fallback.
            return sidebar;
        }

        MapController mapController = new MapController.Builder().build();

        return new MapWithContentTemplate.Builder()
                .setContentTemplate(sidebar)
                .setMapController(mapController)
                .setActionStrip(buildActionStrip())
                .build();
    }

    /** Centres the painted map on the trip (or the recommended charger) and marks the chargers. */
    private void updateMap() {
        if (snapshot == null) {
            return;
        }
        RoutePlan plan = snapshot.getPlan();
        List<CarMap.Pin> pins = new ArrayList<>();
        double latitude = 20.5937;
        double longitude = 78.9629;
        int zoom = 4;

        if (plan != null) {
            latitude = plan.getOriginLat();
            longitude = plan.getOriginLng();
            zoom = 11;
            pins.add(CarMap.destination(plan.getDestinationLat(), plan.getDestinationLng()));
        }

        ChargerStation recommended = snapshot.getRecommendedStation();
        if (recommended != null) {
            if (plan == null) {
                latitude = recommended.getLatitude();
                longitude = recommended.getLongitude();
                zoom = 14;
            }
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

        carMap.show(latitude, longitude, zoom, pins);
    }

    /**
     * The side pane: the trip at a glance, the safe actions, and the links to the other car pages.
     */
    private ListTemplate buildSidebar() {
        ItemList.Builder list = new ItemList.Builder();

        if (snapshot == null) {
            list.addItem(new Row.Builder()
                    .setTitle("Loading your trip")
                    .addText("Amperly is reading the plan you set up on your phone.")
                    .build());
        } else if (snapshot.getPlan() == null) {
            list.addItem(new Row.Builder()
                    .setTitle("No active trip")
                    .addText("Plan a trip on your phone, then reconnect.")
                    .build());
        } else {
            list.addItem(new Row.Builder()
                    .setTitle(snapshot.routeTitle())
                    .addText(snapshot.summaryLine())
                    .build());

            if (snapshot.getRecommendedStation() != null) {
                list.addItem(new Row.Builder()
                        .setTitle("Recommended stop: " + snapshot.getRecommendedStation().getName())
                        .addText(snapshot.getRecommendedDetail() == null ? ""
                                : snapshot.getRecommendedDetail())
                        .setOnClickListener(() -> getScreenManager().push(
                                new ChargerDetailsCarScreen(getCarContext(),
                                        snapshot.getRecommendedStation().getId())))
                        .build());
            } else if (snapshot.getNoSafeChargerMessage() != null
                    && !snapshot.getNoSafeChargerMessage().isEmpty()) {
                list.addItem(new Row.Builder()
                        .setTitle("No safe charger in range")
                        .addText(snapshot.getNoSafeChargerMessage())
                        .build());
            } else {
                list.addItem(new Row.Builder()
                        .setTitle("No charging stop needed")
                        .addText("Your battery covers this trip down to the arrival reserve.")
                        .build());
            }
        }

        list.addItem(new Row.Builder()
                .setTitle("Start navigation")
                .addText("Driver-safe navigation to the recommended stop and destination")
                .setOnClickListener(() -> getScreenManager().push(
                        new NavigationCarScreen(getCarContext())))
                .build());

        list.addItem(new Row.Builder()
                .setTitle("Chargers along the route ("
                        + snapshotReachableCount() + ")")
                .addText("Safely reachable at your current battery level")
                .setOnClickListener(() -> getScreenManager().push(
                        new ChargerListCarScreen(getCarContext())))
                .build());

        list.addItem(new Row.Builder()
                .setTitle("Update actual battery")
                .addText("Enter the dashboard value with two taps - no typing while driving")
                .setOnClickListener(() -> getScreenManager().push(
                        new SoCUpdateCarScreen(getCarContext())))
                .build());

        if (snapshot != null && snapshot.getReservation() != null) {
            list.addItem(new Row.Builder()
                    .setTitle("Reservation " + snapshot.getReservation().getBookingCode())
                    .addText((snapshot.getReservation().getStationName() == null ? ""
                            : snapshot.getReservation().getStationName())
                            + " - " + com.amperly.app.core.common.Formatters
                            .bookingStatus(snapshot.getReservation().getStatus()))
                    .setOnClickListener(() -> getScreenManager().push(
                            new ReservationStatusCarScreen(getCarContext())))
                    .build());
        }

        list.addItem(new Row.Builder()
                .setTitle("Trip history")
                .addText("Your recent trips")
                .setOnClickListener(() -> getScreenManager().push(
                        new TripHistoryCarScreen(getCarContext())))
                .build());
        list.addItem(new Row.Builder()
                .setTitle("Reservations")
                .addText("Manage your reservations")
                .setOnClickListener(() -> getScreenManager().push(
                        new ReservationStatusCarScreen(getCarContext())))
                .build());
        list.addItem(new Row.Builder()
                .setTitle("Vehicle")
                .addText("Battery, range and arrival reserve")
                .setOnClickListener(() -> getScreenManager().push(
                        new VehicleCarScreen(getCarContext())))
                .build());
        list.addItem(new Row.Builder()
                .setTitle("Settings")
                .addText("Car connection and app details")
                .setOnClickListener(() -> getScreenManager().push(
                        new CarSettingsScreen(getCarContext())))
                .build());

        return new ListTemplate.Builder()
                .setTitle("Amperly")
                .setHeaderAction(Action.APP_ICON)
                .setSingleList(list.build())
                .setActionStrip(buildActionStrip())
                .build();
    }

    private int snapshotReachableCount() {
        return snapshot == null ? 0 : snapshot.getReachableStations().size();
    }

    /** The strip along the bottom of the whole screen. */
    private ActionStrip buildActionStrip() {
        return new ActionStrip.Builder()
                .addAction(new Action.Builder()
                        .setTitle("SOS")
                        .setOnClickListener(() -> {
                            CarToast.makeText(getCarContext(),
                                    getCarContext().getString(R.string.car_sos_notice),
                                    CarToast.LENGTH_LONG).show();
                            getScreenManager().push(new ReservationStatusCarScreen(getCarContext()));
                        })
                        .build())
                .build();
    }
}
