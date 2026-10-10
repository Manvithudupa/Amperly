package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.car.app.CarContext;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.Pane;
import androidx.car.app.model.PaneTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;

public class ChargerDetailsCarScreen extends Screen {

    public ChargerDetailsCarScreen(@NonNull CarContext carContext) {
        super(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        Row stationRow = new Row.Builder()
                .setTitle("Highway Hub Charger")
                .addText("Mysore-Mangalore Rd, Km 68")
                .addText("CCS2 DC 30kW | Price: ₹18/kWh")
                .build();

        Row impactRow = new Row.Builder()
                .setTitle("Route Impact")
                .addText("Detour: +4.2 km (+8 mins) | Charge: 18 mins (+22 kWh)")
                .addText("Battery: 19% on arrival -> 62% post-charge")
                .build();

        Pane pane = new Pane.Builder()
                .addRow(stationRow)
                .addRow(impactRow)
                .addAction(new Action.Builder()
                        .setTitle("Reserve Slot")
                        .setOnClickListener(() ->
                                getScreenManager().push(new ReservationStatusCarScreen(getCarContext())))
                        .build())
                .build();

        return new PaneTemplate.Builder(pane)
                .setTitle("Charger Details")
                .setHeaderAction(Action.BACK)
                .build();
    }
}
