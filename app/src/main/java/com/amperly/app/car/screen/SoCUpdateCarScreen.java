package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.car.app.CarContext;
import androidx.car.app.CarToast;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.ItemList;
import androidx.car.app.model.ListTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;
import androidx.lifecycle.Lifecycle;

import com.amperly.app.R;
import com.amperly.app.car.CarBridge;
import com.amperly.app.car.CarLimits;
import com.amperly.app.data.repository.AmperlyRepository;

/**
 * Battery correction without typing: eight large predefined percentages. The value the driver picks
 * becomes authoritative, unreachable chargers are dropped and the nearest safe compatible charger is
 * shown.
 */
public class SoCUpdateCarScreen extends Screen {

    private final AmperlyRepository repo;
    private boolean submitting;

    public SoCUpdateCarScreen(@NonNull CarContext carContext) {
        super(carContext);
        this.repo = AmperlyRepository.getInstance(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        ItemList.Builder list = new ItemList.Builder();
        for (final int option : CarLimits.batteryOptions()) {
            list.addItem(new Row.Builder()
                    .setTitle(getCarContext().getString(R.string.car_soc_option, option))
                    .addText(getCarContext().getString(R.string.car_soc_option_text))
                    .setOnClickListener(() -> apply(option))
                    .build());
        }
        return new ListTemplate.Builder()
                .setTitle(getCarContext().getString(R.string.car_soc_title))
                .setHeaderAction(Action.BACK)
                .setSingleList(list.build())
                .build();
    }

    private void apply(int option) {
        if (submitting) {
            return;
        }
        submitting = true;
        CarBridge.applyBatteryUpdateResult(repo, option, result -> {
            submitting = false;
            if (!getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.STARTED)) {
                return;
            }
            if (!result.isApplied()) {
                String message = CarBridge.BatteryUpdate.PROBLEM_NO_PLAN
                        .equals(result.getProblem())
                        ? getCarContext().getString(R.string.car_soc_no_plan)
                        : getCarContext().getString(R.string.car_soc_failed);
                CarToast.makeText(getCarContext(), message, CarToast.LENGTH_LONG).show();
                return;
            }
            CarToast.makeText(getCarContext(),
                    getCarContext().getString(result.isNoSafeCharger()
                            ? R.string.car_soc_no_safe : R.string.car_soc_applied, option),
                    CarToast.LENGTH_LONG).show();
            getScreenManager().pop();
        });
    }
}
