package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.car.app.CarContext;
import androidx.car.app.CarToast;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.ActionStrip;
import androidx.car.app.model.ItemList;
import androidx.car.app.model.ListTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;

import com.amperly.app.car.CarBridge;
import com.amperly.app.data.repository.AmperlyRepository;

/**
 * The main car screen: route, the recommended charging stop, and the two safe actions a driver can
 * take — update the actual battery, or open the charger list. Everything else stays on the phone.
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
        ItemList.Builder list = new ItemList.Builder();

        if (snapshot == null) {
            list.addItem(new Row.Builder()
                    .setTitle("Loading your trip")
                    .addText("Amperly is reading the plan you set up on your phone.")
                    .build());
            CarBridge.load(repo, value -> {
                snapshot = value;
                invalidate();
            });
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

            list.addItem(new Row.Builder()
                    .setTitle("Chargers along the route (" + snapshot.getReachableStations().size() + ")")
                    .addText("Safely reachable at your current battery level")
                    .setOnClickListener(() -> getScreenManager().push(new ChargerListCarScreen(getCarContext())))
                    .build());

            list.addItem(new Row.Builder()
                    .setTitle("Update actual battery")
                    .addText("Enter the dashboard value with two taps — no typing while driving")
                    .setOnClickListener(() -> getScreenManager().push(new SoCUpdateCarScreen(getCarContext())))
                    .build());

            if (snapshot.getReservation() != null) {
                list.addItem(new Row.Builder()
                        .setTitle("Reservation " + snapshot.getReservation().getBookingCode())
                        .addText((snapshot.getReservation().getStationName() == null ? ""
                                : snapshot.getReservation().getStationName())
                        + " · " + snapshot.getReservation().getStatus())
                        .setOnClickListener(() -> getScreenManager().push(
                                new ReservationStatusCarScreen(getCarContext())))
                        .build());
            }
        }

        ActionStrip actionStrip = new ActionStrip.Builder()
                .addAction(new Action.Builder()
                        .setTitle("SOS")
                        .setOnClickListener(() -> {
                            CarToast.makeText(getCarContext(),
                                    "Amperly is not an emergency service. Call 112 for help.",
                                    CarToast.LENGTH_LONG).show();
                            getScreenManager().push(new ReservationStatusCarScreen(getCarContext()));
                        })
                        .build())
                .build();

        return new ListTemplate.Builder()
                .setTitle("Amperly route & chargers")
                .setSingleList(list.build())
                .setActionStrip(actionStrip)
                .build();
    }
}
