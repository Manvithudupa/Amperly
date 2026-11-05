package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.car.app.CarContext;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.ItemList;
import androidx.car.app.model.ListTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;
import androidx.lifecycle.Lifecycle;

import com.amperly.app.R;
import com.amperly.app.car.CarConstraints;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;

/**
 * The vehicle the trip is calculated for: usable battery, consumption and the arrival reserve.
 *
 * <p>Everything here is read-only. Changing the car is a form, and forms belong to the phone.
 */
public class VehicleCarScreen extends Screen {

    private static final int DESIRED_ROWS = 5;

    private final AmperlyRepository repo;
    private Vehicle vehicle;
    private boolean requested;
    private boolean loaded;

    public VehicleCarScreen(@NonNull CarContext carContext) {
        super(carContext);
        this.repo = AmperlyRepository.getInstance(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        if (!requested) {
            requested = true;
            final String userId = AuthManager.getInstance().getCurrentUserId();
            repo.background(() -> repo.getVehicleSync(userId), value -> {
                vehicle = value;
                loaded = true;
                if (getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.STARTED)) {
                    invalidate();
                }
            });
        }

        ItemList.Builder list = new ItemList.Builder();

        if (!loaded) {
            list.addItem(new Row.Builder()
                    .setTitle(getCarContext().getString(R.string.car_vehicle_loading))
                    .build());
        } else if (vehicle == null) {
            list.addItem(new Row.Builder()
                    .setTitle(getCarContext().getString(R.string.car_vehicle_none_title))
                    .addText(getCarContext().getString(R.string.car_vehicle_none_text))
                    .build());
        } else {
            String name = ((vehicle.getMake() == null ? "" : vehicle.getMake()) + " "
                    + (vehicle.getModel() == null ? "" : vehicle.getModel())).trim();
            if (name.isEmpty()) {
                name = getCarContext().getString(R.string.car_vehicle_unnamed);
            }

            Row[] rows = new Row[]{
                    new Row.Builder()
                            .setTitle(name)
                            .addText(vehicle.getVariant() == null ? "" : vehicle.getVariant())
                            .build(),
                    new Row.Builder()
                            .setTitle(getCarContext().getString(R.string.car_vehicle_battery_title))
                            .addText(getCarContext().getString(R.string.car_vehicle_battery_text,
                                    Math.round(vehicle.effectiveCapacityKwh()),
                                    Math.round(vehicle.getBatteryHealthPercent())))
                            .build(),
                    new Row.Builder()
                            .setTitle(getCarContext().getString(
                                    R.string.car_vehicle_consumption_title))
                            .addText(getCarContext().getString(
                                    R.string.car_vehicle_consumption_text,
                                    Math.round(vehicle.effectiveEfficiencyKmPerKwh()),
                                    Math.round(vehicle.getMaxDcKw())))
                            .build(),
                    new Row.Builder()
                            .setTitle(getCarContext().getString(R.string.car_vehicle_reserve_title))
                            .addText(getCarContext().getString(R.string.car_vehicle_reserve_text,
                                    vehicle.getMinArrivalSocPercent(),
                                    vehicle.getMaxChargeSocPercent()))
                            .build(),
                    new Row.Builder()
                            .setTitle(getCarContext().getString(R.string.car_vehicle_plate_title))
                            .addText(valueOr(vehicle.getLicensePlate(), ""))
                            .build()
            };

            int limit = CarConstraints.listLimit(getCarContext(), DESIRED_ROWS);
            for (int i = 0; i < rows.length && i < limit; i++) {
                list.addItem(rows[i]);
            }
        }

        return new ListTemplate.Builder()
                .setTitle(getCarContext().getString(R.string.car_vehicle_title))
                .setHeaderAction(Action.BACK)
                .setSingleList(list.build())
                .build();
    }

    @NonNull
    private static String valueOr(@Nullable String value, @NonNull String fallback) {
        return value == null ? fallback : value;
    }
}
