package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
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
import com.amperly.app.data.local.entity.RoutePlan;
import com.amperly.app.data.repository.AmperlyRepository;

import java.util.Collections;
import java.util.List;

/**
 * The trips the driver has already planned, listed for the car display.
 *
 * <p>Only the trip the phone already planned is shown: the car never plans a new route, it only
 * makes the ones that exist glanceable while the vehicle is moving.
 */
public class TripHistoryCarScreen extends Screen {

    private static final int DESIRED_ROWS = 6;

    private final AmperlyRepository repo;
    private List<RoutePlan> plans;
    private boolean loaded;

    public TripHistoryCarScreen(@NonNull CarContext carContext) {
        super(carContext);
        this.repo = AmperlyRepository.getInstance(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        if (!loaded) {
            loaded = true;
            final String userId = AuthManager.getInstance().getCurrentUserId();
            repo.background(() -> repo.getRoutePlansSync(userId), value -> {
                plans = value == null ? Collections.emptyList() : value;
                if (getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.STARTED)) {
                    invalidate();
                }
            });
        }

        ItemList.Builder list = new ItemList.Builder();

        if (plans == null) {
            list.addItem(new Row.Builder()
                    .setTitle(getCarContext().getString(R.string.car_trip_history_loading))
                    .build());
        } else if (plans.isEmpty()) {
            list.addItem(new Row.Builder()
                    .setTitle(getCarContext().getString(R.string.car_trip_history_empty_title))
                    .addText(getCarContext().getString(R.string.car_trip_history_empty_text))
                    .build());
        } else {
            int limit = CarConstraints.listLimit(getCarContext(), DESIRED_ROWS);
            for (int i = 0; i < plans.size() && i < limit; i++) {
                RoutePlan plan = plans.get(i);
                String destination = plan.getDestination();
                if (destination == null || destination.isEmpty()) {
                    destination = getCarContext().getString(R.string.car_trip_history_untitled);
                }
                String origin = plan.getOrigin() == null ? "" : plan.getOrigin();
                list.addItem(new Row.Builder()
                        .setTitle(destination)
                        .addText(getCarContext().getString(R.string.car_trip_history_line,
                                origin, destination))
                        .addText(getCarContext().getString(R.string.car_trip_history_meta,
                                Math.round(plan.getTotalDistanceKm()),
                                Math.round(plan.getTotalJourneyMinutes()),
                                plan.getPlannedStartSoc()))
                        .build());
            }
        }

        return new ListTemplate.Builder()
                .setTitle(getCarContext().getString(R.string.car_more_trip_history))
                .setHeaderAction(Action.BACK)
                .setSingleList(list.build())
                .build();
    }
}
