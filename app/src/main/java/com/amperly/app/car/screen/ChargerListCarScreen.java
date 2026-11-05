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
import com.amperly.app.car.CarBridge;
import com.amperly.app.car.CarConstraints;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.availability.AvailabilityEngine;

import java.util.List;

/**
 * Short, glanceable list of chargers the car can actually reach at the current battery level.
 * Price per kWh is deliberately left to the details screen.
 */
public class ChargerListCarScreen extends Screen {

    private static final int DESIRED_ROWS = 6;

    private final AmperlyRepository repo;
    private List<ChargerStation> stations;
    private boolean loading;

    public ChargerListCarScreen(@NonNull CarContext carContext) {
        super(carContext);
        this.repo = AmperlyRepository.getInstance(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        if (stations == null && !loading) {
            loading = true;
            CarBridge.load(repo, snapshot -> {
                stations = snapshot.getReachableStations();
                loading = false;
                if (getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.STARTED)) {
                    invalidate();
                }
            });
        }

        ItemList.Builder list = new ItemList.Builder();
        if (stations == null) {
            list.addItem(new Row.Builder()
                    .setTitle(getCarContext().getString(R.string.car_charger_loading))
                    .build());
        } else if (stations.isEmpty()) {
            list.addItem(new Row.Builder()
                    .setTitle(getCarContext().getString(R.string.car_charger_empty_title))
                    .addText(getCarContext().getString(R.string.car_charger_empty_text))
                    .build());
        } else {
            int limit = CarConstraints.listLimit(getCarContext(), DESIRED_ROWS);
            for (int i = 0; i < stations.size() && i < limit; i++) {
                ChargerStation station = stations.get(i);
                final String stationId = station.getId();
                String name = station.getName();
                if (name == null || name.isEmpty()) {
                    name = stationId;
                }
                list.addItem(new Row.Builder()
                        .setTitle(name)
                        .addText(connectorPowerLine(station))
                        .addText(getCarContext().getString(station.supportsPaidEnergyBilling()
                                ? R.string.car_charger_meter_verified
                                : R.string.car_charger_discovery_only))
                        .setOnClickListener(() -> getScreenManager().push(
                                new ChargerDetailsCarScreen(getCarContext(), stationId)))
                        .build());
            }
        }

        return new ListTemplate.Builder()
                .setTitle(getCarContext().getString(R.string.car_charger_list_title))
                .setHeaderAction(Action.BACK)
                .setSingleList(list.build())
                .build();
    }

    @NonNull
    private String connectorPowerLine(@NonNull ChargerStation station) {
        String power = getCarContext().getString(R.string.car_power_kw,
                Math.round(station.getMaxPowerKw()));
        String connectors = Formatters.connectorTypes(station.getConnectorTypes());
        if (connectors.isEmpty()) {
            connectors = getCarContext().getString(R.string.car_charger_connector_unknown);
        }
        return connectors + " · " + power;
    }

    /** Kept for callers that already have a list in hand (for example a deep link). */
    public void setStations(List<ChargerStation> stations) {
        this.stations = stations;
        invalidate();
    }

    public static String portSummary(@Nullable List<com.amperly.app.data.local.entity.ChargerPort> ports) {
        if (ports == null || ports.isEmpty()) {
            return "";
        }
        return AvailabilityEngine.portLabel(ports.get(0));
    }
}
