package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.car.app.CarContext;
import androidx.car.app.CarToast;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.Pane;
import androidx.car.app.model.PaneTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;

public class ReservationStatusCarScreen extends Screen {

    public ReservationStatusCarScreen(@NonNull CarContext carContext) {
        super(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        Row statusRow = new Row.Builder()
                .setTitle("Active Booking: AMP-8921")
                .addText("Highway Hub Charger - Port 1 (CCS2 30kW)")
                .addText("Reserved Slot: Today 10:00 AM - 11:30 AM")
                .build();

        Row checkInRow = new Row.Builder()
                .setTitle("Check-in Instructions")
                .addText("Arrive at charger & scan QR code on phone to initiate session.")
                .build();

        Pane pane = new Pane.Builder()
                .addRow(statusRow)
                .addRow(checkInRow)
                .addAction(new Action.Builder()
                        .setTitle("Navigate")
                        .setOnClickListener(() ->
                                CarToast.makeText(getCarContext(), "Launching Navigation to Highway Hub Charger...", CarToast.LENGTH_SHORT).show())
                        .build())
                .build();

        return new PaneTemplate.Builder(pane)
                .setTitle("Reservation Status")
                .setHeaderAction(Action.BACK)
                .build();
    }
}
