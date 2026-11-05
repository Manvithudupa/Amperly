package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.car.app.CarContext;
import androidx.car.app.CarToast;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.Pane;
import androidx.car.app.model.PaneTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;
import androidx.lifecycle.Lifecycle;

import com.amperly.app.R;
import com.amperly.app.car.CarBridge;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.repository.AmperlyRepository;

/**
 * Charger details, kept to two glanceable rows and two safe actions. Reserving here is a single tap
 * on the next published free slot — never a multi-step form.
 */
public class ChargerDetailsCarScreen extends Screen {

    private final AmperlyRepository repo;
    private final String stationId;
    private ChargerStation station;
    private boolean loaded;
    private boolean reserving;

    public ChargerDetailsCarScreen(@NonNull CarContext carContext, @Nullable String stationId) {
        super(carContext);
        this.repo = AmperlyRepository.getInstance(carContext);
        this.stationId = stationId;
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        if (!loaded) {
            loaded = true;
            if (stationId != null) {
                repo.background(() -> repo.getStationSync(stationId), loadedStation -> {
                    station = loadedStation;
                    if (getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.STARTED)) {
                        invalidate();
                    }
                });
            }
            return singleRowPane(getCarContext().getString(R.string.car_charger_details_title),
                    getCarContext().getString(R.string.car_charger_details_loading));
        }

        if (station == null) {
            return singleRowPane(getCarContext().getString(R.string.car_charger_details_title),
                    getCarContext().getString(R.string.car_charger_details_missing));
        }

        Row stationRow = new Row.Builder()
                .setTitle(valueOr(station.getName(),
                        getCarContext().getString(R.string.car_charger_details_title)))
                .addText(connectorPowerLine(station))
                .addText(priceLine(station))
                .build();

        Row accessRow = new Row.Builder()
                .setTitle(getCarContext().getString(R.string.car_charger_access_title))
                .addText(accessLine(station))
                .addText(meterLine(station))
                .build();

        Pane.Builder paneBuilder = new Pane.Builder()
                .addRow(stationRow)
                .addRow(accessRow)
                .addAction(new Action.Builder()
                        .setTitle(getCarContext().getString(R.string.car_navigate_action))
                        .setOnClickListener(() -> Navigator.navigateToCar(getCarContext(),
                                station.getLatitude(), station.getLongitude()))
                        .build());

        if (station.supportsPaidEnergyBilling()) {
            paneBuilder.addAction(new Action.Builder()
                    .setTitle(getCarContext().getString(R.string.car_reserve_action))
                    .setOnClickListener(this::reserve)
                    .build());
        }

        return new PaneTemplate.Builder(paneBuilder.build())
                .setTitle(getCarContext().getString(R.string.car_charger_details_title))
                .setHeaderAction(Action.BACK)
                .build();
    }

    private void reserve() {
        if (reserving || station == null) {
            return;
        }
        reserving = true;
        CarBridge.reserveNextFreeSlotResult(repo, station.getId(), result -> {
            reserving = false;
            if (!getLifecycle().getCurrentState().isAtLeast(Lifecycle.State.STARTED)) {
                return;
            }
            String message;
            if (result.isReserved()) {
                message = getCarContext().getString(R.string.car_reserved,
                        valueOr(result.getPortLabel(), ""),
                        valueOr(result.getBookingCode(), ""));
            } else if (CarBridge.ReservationAttempt.PROBLEM_NO_METER.equals(result.getProblem())) {
                message = getCarContext().getString(R.string.car_reserve_no_meter);
            } else if (CarBridge.ReservationAttempt.PROBLEM_NO_SLOT.equals(result.getProblem())) {
                message = getCarContext().getString(R.string.car_reserve_no_slot);
            } else if (CarBridge.ReservationAttempt.PROBLEM_SERVER.equals(result.getProblem())) {
                message = result.getServerMessage() == null
                        ? getCarContext().getString(R.string.car_reserve_failed)
                        : result.getServerMessage();
            } else {
                message = getCarContext().getString(R.string.car_reserve_unavailable);
            }
            CarToast.makeText(getCarContext(), message, CarToast.LENGTH_LONG).show();
            invalidate();
        });
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

    @NonNull
    private String priceLine(@NonNull ChargerStation station) {
        return getCarContext().getString(R.string.car_charger_price,
                Formatters.moneyShort(station.getPricePerKwh()),
                Formatters.moneyShort(station.getServiceFee()),
                Formatters.moneyShort(station.getGatewayFee()));
    }

    @NonNull
    private String accessLine(@NonNull ChargerStation station) {
        String rules = station.getAccessRules();
        return rules == null || rules.trim().isEmpty()
                ? getCarContext().getString(R.string.car_charger_access_none)
                : rules;
    }

    @NonNull
    private String meterLine(@NonNull ChargerStation station) {
        if (!station.supportsPaidEnergyBilling()) {
            return getCarContext().getString(R.string.car_charger_no_meter_line);
        }
        return getCarContext().getString(R.string.car_charger_meter_verified_line,
                Formatters.verificationLevel(station.getVerificationLevel()));
    }

    @NonNull
    private Template singleRowPane(@NonNull String title, @NonNull String message) {
        Pane pane = new Pane.Builder()
                .addRow(new Row.Builder().setTitle(message).build())
                .build();
        return new PaneTemplate.Builder(pane)
                .setTitle(title)
                .setHeaderAction(Action.BACK)
                .build();
    }

    @NonNull
    private static String valueOr(@Nullable String value, @NonNull String fallback) {
        return value == null || value.isEmpty() ? fallback : value;
    }
}
