package com.amperly.app.car.screen;import androidx.annotation.NonNull;
import androidx.car.app.CarContext;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.ActionStrip;
import androidx.car.app.model.GridTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;
import androidx.car.app.model.Text;

import com.amperly.app.car.CarBridge;
import com.amperly.app.data.repository.AmperlyRepository;


/**
 * The main car screen showing a map view (80%) with a sidebar (20%) containing links
 * to other pages such as trip history, reservations, and settings.
 */
public class RouteOverviewCarScreen extends Screen {

    private final AmperlyRepository repo;
    private CarBridge.Snapshot snapshot;

    public RouteOverviewCarScreen(@NonNull CarContext carContext) {
        super(carContext);
        this.repo = AmperlyRepository.getInstance(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        // Map section taking approximately 80% of the screen        MapSection mapSection = new MapSection(repo, carContext);
        // Sidebar section taking approximately 20% of the screen with links
        SidebarSection sidebar = new SidebarSection(repo, carContext);
        GridTemplate.Builder builder = new GridTemplate.Builder();
        builder.setTitle("Amperly");
        // Add map section occupying first column (80% width)        builder.addColumn(mapSection.getTemplate());        // Add sidebar section occupying second column (20% width)        builder.addColumn(sidebar.getTemplate());        // Set the column weight ratio to approximate 80/20 split        builder.setColumnWeight(0, 4f); // Map column: 4 parts        builder.setColumnWeight(1, 1f); // Sidebar column: 1 part        // Add action strip at the bottom for essential actions        ActionStrip actionStrip = new ActionStrip.Builder()                .addAction(new Action.Builder()                        .setTitle("SOS")                        .setOnClickListener(() -> {                            CarToast.makeText(getCarContext(),                                    "Amperly is not an emergency service. Call 112 for help.",                                    CarToast.LENGTH_LONG).show();
                            getScreenManager().push(new ReservationStatusCarScreen(getCarContext()));                        })                        .build())                .build();        builder.setActionStrip(actionStrip);        return builder.build();    }
}

/** * Map section showing route and battery information taking ~80% of the screen. */ static class MapSection {    private final AmperlyRepository repo;    private CarContext carContext;    private CarBridge.Snapshot snapshot;    public MapSection(AmperlyRepository repo, CarContext carContext) {        this.repo = repo;
        this.carContext = carContext;
    }
    public Template getTemplate() {        if (snapshot == null) {
            CarBridge.load(repo, value -> {
                snapshot = value;
                invalidate();
            });
            return new Template.Builder().build();        }        // Display route overview in the map area
        ItemList.Builder list = new ItemList.Builder();        if (snapshot == null) {            list.addItem(new Row.Builder()                    .setTitle("Loading your trip")                    .addText("Amperly is reading the plan you set up on your phone.")                    .build());        } else {            list.addItem(new Row.Builder()                    .setTitle(snapshot.routeTitle())                    .addText(snapshot.summaryLine())                    .build());            if (snapshot.getRecommendedStation() != null) {                list.addItem(new Row.Builder()                        .setTitle("Recommended stop: " + snapshot.getRecommendedStation().getName())                        .addText(snapshot.getRecommendedDetail() == null ? ""                                : snapshot.getRecommendedDetail())                        .setOnClickListener(() -> getScreenManager().push(                                new ChargerDetailsCarScreen(getCarContext(),                                        snapshot.getRecommendedStation().getId())))                        .build());            } else if (snapshot.getNoSafeChargerMessage() != null                    && !snapshot.getNoSafeChargerMessage().isEmpty()) {                list.addItem(new Row.Builder()                        .setTitle("No safe charger in range")                        .addText(snapshot.getNoSafeChargerMessage())                        .build());            } else {                list.addItem(new Row.Builder()                        .setTitle("No charging stop needed")                        .addText("Your battery covers this trip down to the arrival reserve.")                        .build());            }            list.addItem(new Row.Builder()                    .setTitle("Start navigation")                    .addText("Driver-safe navigation to the recommended stop and destination")                    .setOnClickListener(() -> getScreenManager().push(                            new NavigationCarScreen(getCarContext())))                    .build());            list.addItem(new Row.Builder()                    .setTitle("Chargers along the route (" + snapshot.getReachableStations().size() + ")")                    .addText("Safely reachable at your current battery level")                    .setOnClickListener(() -> getScreenManager().push(new ChargerListCarScreen(getCarContext())))                    .build());            list.addItem(new Row.Builder()                    .setTitle("Update actual battery")                    .addText("Enter the dashboard value with two taps — no typing while driving")                    .setOnClickListener(() -> getScreenManager().push(new SoCUpdateCarScreen(getCarContext())))                    .build());            if (snapshot.getReservation() != null) {                list.addItem(new Row.Builder()                        .setTitle("Reservation " + snapshot.getReservation().getBookingCode())                        .addText((snapshot.getReservation().getStationName() == null ? ""                                : snapshot.getReservation().getStationName())                        + " · " + snapshot.getReservation().getStatus())                        .setOnClickListener(() -> getScreenManager().push(                                new ReservationStatusCarScreen(getCarContext())))                        .build());            }            // Add estimated range info            list.addItem(new Row.Builder()                    .setTitle("Estimated range")                    .addText("Based on current battery level")                    .build());        }        return new ListTemplate.Builder()                .setTitle("Route & battery")                .setSingleList(list.build())                .build();    }}

/** * Sidebar section showing links to other pages taking ~20% of the screen. */ static class SidebarSection {    private final AmperlyRepository repo;    private CarContext carContext;    public SidebarSection(AmperlyRepository repo, CarContext carContext) {        this.repo = repo;        this.carContext = carContext;    }    public Template getTemplate() {        // Create rows for the sidebar links        ItemList.Builder list = new ItemList.Builder();        // Trip history link        list.addItem(new Row.Builder()                .setTitle("Trip history")                .addText("View past trips")                .setOnClickListener(() -> getScreenManager().push(new RoutePlannerCarScreen(carContext)))                .build());        // Reservations link        list.addItem(new Row.Builder()                .setTitle("Reservations")                .addText("Manage your reservations")                .setOnClickListener(() -> getScreenManager().push(new ReservationStatusCarScreen(carContext)))                .build());        // Settings link        list.addItem(new Row.Builder()                .setTitle("Settings")                .addText("Car settings")                .setOnClickListener(() -> getScreenManager().push(new SettingsCarScreen(carContext)))                .build());        // Vehicle profile link        list.addItem(new Row.Builder()                .setTitle("Vehicle")                .addText("Vehicle settings")                .setOnClickListener(() -> getScreenManager().push(new VehicleProfileCarScreen(carContext)))                .build());        return new ListTemplate.Builder()                .setTitle("Links")                .setSingleList(list.build())                .build();    }}

/** * Placeholder car screens for the sidebar links. */ static class RoutePlannerCarScreen extends Screen {    public RoutePlannerCarScreen(CarContext carContext) {        super(carContext);    }    @NonNull    @Override    public Template onGetTemplate() {        return new ListTemplate.Builder()                .setTitle("Trip history")                .setSingleList(new ItemList.Builder()                        .addItem(new Row.Builder()                                .setTitle("No trip history yet")                                .build())                        .build())                .build();    }}

static class SettingsCarScreen extends Screen {    public SettingsCarScreen(CarContext carContext) {        super(carContext);    }    @NonNull    @Override    public Template onGetTemplate() {        return new ListTemplate.Builder()                .setTitle("Car settings")                .setSingleList(new ItemList.Builder()                        .addItem(new Row.Builder()                                .setTitle("Settings not implemented yet")                                .build())                        .build())                .build();    }}

static class VehicleProfileCarScreen extends Screen {    public VehicleProfileCarScreen(CarContext carContext) {        super(carContext);    }    @NonNull    @Override    public Template onGetTemplate() {        return new ListTemplate.Builder()                .setTitle("Vehicle profile")                .setSingleList(new ItemList.Builder()                        .addItem(new Row.Builder()                                .setTitle("Vehicle info")                                .build())                        .build())                .build();    }}

