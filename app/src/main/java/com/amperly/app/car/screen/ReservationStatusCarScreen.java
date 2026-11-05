package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.car.app.CarContext;
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
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.repository.AmperlyRepository;

/** The active booking, with one safe action: navigate to the charger. */
public class ReservationStatusCarScreen extends Screen {

    private final AmperlyRepository repo;
    private Reservation reservation;
    private ChargerStation station;
    private boolean loaded;

    public ReservationStatusCarScreen(@NonNull CarContext carContext) {
        super(carContext);
        this.repo = AmperlyRepository.getInstance(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        if (!loaded) {
            loaded = true;
            CarBridge.load(repo, snapshot -> {
                reservation = snapshot.getReservation();
                if (reservation != null && reservation.getStationId() != null) {
                    repo.background(() -> repo.getStationSync(reservation.getStationId()),
                            loadedStation -> {
                                station = loadedStation;
                                if (getLifecycle().getCurrentState()
                                        .isAtLeast(Lifecycle.State.STARTED)) {
                                    invalidate();
                                }
                            });
                } else if (getLifecycle().getCurrentState()
                        .isAtLeast(Lifecycle.State.STARTED)) {
                    invalidate();
                }
            });
            return new PaneTemplate.Builder(new Pane.Builder()
                    .addRow(new Row.Builder()
                            .setTitle(getCarContext().getString(R.string.car_reservation_loading))
                            .build())
                    .build())
                    .setTitle(getCarContext().getString(R.string.car_reservation_title))
                    .setHeaderAction(Action.BACK)
                    .build();
        }

        if (reservation == null) {
            Pane pane = new Pane.Builder()
                    .addRow(new Row.Builder()
                            .setTitle(getCarContext().getString(R.string.car_reservation_none_title))
                            .addText(getCarContext().getString(R.string.car_reservation_none_text))
                            .build())
                    .build();
            return new PaneTemplate.Builder(pane)
                    .setTitle(getCarContext().getString(R.string.car_reservation_title))
                    .setHeaderAction(Action.BACK)
                    .build();
        }

        String stationName = reservation.getStationName();
        if (stationName == null || stationName.isEmpty()) {
            stationName = getCarContext().getString(R.string.car_reservation_unknown_station);
        }
        String port = valueOr(reservation.getPortLabel(), "");

        Row statusRow = new Row.Builder()
                .setTitle(getCarContext().getString(R.string.car_reservation_booking,
                        valueOr(reservation.getBookingCode(), "")))
                .addText(getCarContext().getString(R.string.car_reservation_where,
                        stationName, port))
                .addText(valueOr(Formatters.bookingStatus(reservation.getStatus()), ""))
                .build();

        Row checkInRow = new Row.Builder()
                .setTitle(getCarContext().getString(R.string.car_reservation_on_arrival_title))
                .addText(getCarContext().getString(R.string.car_reservation_on_arrival_text))
                .build();

        Pane.Builder paneBuilder = new Pane.Builder()
                .addRow(statusRow)
                .addRow(checkInRow);

        String slot = Formatters.dayAndSlot(reservation.getStartTimeMs(), reservation.getEndTimeMs());
        if (slot != null && !slot.isEmpty()) {
            paneBuilder.addRow(new Row.Builder().setTitle(slot).build());
        }

        if (station != null) {
            paneBuilder.addAction(new Action.Builder()
                    .setTitle(getCarContext().getString(R.string.car_navigate_action))
                    .setOnClickListener(() -> Navigator.navigateToCar(getCarContext(),
                            station.getLatitude(), station.getLongitude()))
                    .build());
        }

        return new PaneTemplate.Builder(paneBuilder.build())
                .setTitle(getCarContext().getString(R.string.car_reservation_title))
                .setHeaderAction(Action.BACK)
                .build();
    }

    @NonNull
    private static String valueOr(@Nullable String value, @NonNull String fallback) {
        return value == null ? fallback : value;
    }
}
