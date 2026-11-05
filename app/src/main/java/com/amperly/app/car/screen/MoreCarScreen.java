package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.car.app.CarContext;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.ItemList;
import androidx.car.app.model.ListTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;

import com.amperly.app.R;
import com.amperly.app.car.CarConstraints;
import com.amperly.app.core.state.AppStateStore;

/**
 * Everything that does not fit in the four-row main pane.
 *
 * <p>The main screen stays glanceable; these destinations are one tap deeper. Nothing here edits
 * account, payment or meter settings.
 */
public class MoreCarScreen extends Screen {

    private static final int DESIRED_ROWS = 5;

    public MoreCarScreen(@NonNull CarContext carContext) {
        super(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        boolean hasReservation = AppStateStore.get().getActiveReservationId() != null
                && !AppStateStore.get().getActiveReservationId().isEmpty();

        Row[] rows = new Row[]{
                new Row.Builder()
                        .setTitle(getCarContext().getString(R.string.nav_car_battery_action))
                        .addText(getCarContext().getString(R.string.car_more_battery_text))
                        .setOnClickListener(() -> getScreenManager().push(
                                new SoCUpdateCarScreen(getCarContext())))
                        .build(),
                new Row.Builder()
                        .setTitle(getCarContext().getString(R.string.car_more_reservation))
                        .addText(getCarContext().getString(hasReservation
                                ? R.string.car_more_reservation_active
                                : R.string.car_more_reservation_none))
                        .setOnClickListener(() -> getScreenManager().push(
                                new ReservationStatusCarScreen(getCarContext())))
                        .build(),
                new Row.Builder()
                        .setTitle(getCarContext().getString(R.string.car_more_trip_history))
                        .addText(getCarContext().getString(R.string.car_more_trip_history_text))
                        .setOnClickListener(() -> getScreenManager().push(
                                new TripHistoryCarScreen(getCarContext())))
                        .build(),
                new Row.Builder()
                        .setTitle(getCarContext().getString(R.string.car_more_vehicle))
                        .addText(getCarContext().getString(R.string.car_more_vehicle_text))
                        .setOnClickListener(() -> getScreenManager().push(
                                new VehicleCarScreen(getCarContext())))
                        .build(),
                new Row.Builder()
                        .setTitle(getCarContext().getString(R.string.car_more_settings))
                        .addText(getCarContext().getString(R.string.car_more_settings_text))
                        .setOnClickListener(() -> getScreenManager().push(
                                new CarSettingsScreen(getCarContext())))
                        .build()
        };

        int limit = CarConstraints.listLimit(getCarContext(), DESIRED_ROWS);
        ItemList.Builder list = new ItemList.Builder();
        for (int i = 0; i < rows.length && i < limit; i++) {
            list.addItem(rows[i]);
        }

        return new ListTemplate.Builder()
                .setTitle(getCarContext().getString(R.string.car_more_title))
                .setHeaderAction(Action.BACK)
                .setSingleList(list.build())
                .build();
    }
}
