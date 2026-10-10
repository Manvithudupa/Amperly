package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.car.app.CarContext;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.ActionStrip;
import androidx.car.app.model.ItemList;
import androidx.car.app.model.ListTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;

public class RouteOverviewCarScreen extends Screen {

    public RouteOverviewCarScreen(@NonNull CarContext carContext) {
        super(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        ItemList.Builder listBuilder = new ItemList.Builder();

        Row tripRow = new Row.Builder()
                .setTitle("Mysore -> Mangalore (140 km)")
                .addText("Current SoC Estimate: 35% | Safe Range: 195 km")
                .build();
        listBuilder.addItem(tripRow);

        Row chargerRow = new Row.Builder()
                .setTitle("Recommended Stop: Highway Hub Charger")
                .addText("Detour: +4.2 km (+8 mins) | Charge Time: 18 mins")
                .setOnClickListener(() ->
                        getScreenManager().push(new ChargerDetailsCarScreen(getCarContext())))
                .build();
        listBuilder.addItem(chargerRow);

        Row updateSocRow = new Row.Builder()
                .setTitle("Update Actual Battery SoC %")
                .addText("Tap to enter dashboard battery percentage for instant rerouting")
                .setOnClickListener(() ->
                        getScreenManager().push(new SoCUpdateCarScreen(getCarContext())))
                .build();
        listBuilder.addItem(updateSocRow);

        ActionStrip actionStrip = new ActionStrip.Builder()
                .addAction(new Action.Builder()
                        .setTitle("SOS Safety")
                        .setOnClickListener(() ->
                                getScreenManager().push(new ReservationStatusCarScreen(getCarContext())))
                        .build())
                .build();

        return new ListTemplate.Builder()
                .setTitle("Amperly Route & Chargers")
                .setSingleList(listBuilder.build())
                .setActionStrip(actionStrip)
                .build();
    }
}
