package com.amperly.app.car.screen;

import androidx.annotation.NonNull;
import androidx.car.app.CarContext;
import androidx.car.app.Screen;
import androidx.car.app.model.Action;
import androidx.car.app.model.ItemList;
import androidx.car.app.model.ListTemplate;
import androidx.car.app.model.Row;
import androidx.car.app.model.Template;

public class ChargerListCarScreen extends Screen {

    public ChargerListCarScreen(@NonNull CarContext carContext) {
        super(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        ItemList.Builder listBuilder = new ItemList.Builder();

        Row station1 = new Row.Builder()
                .setTitle("ABC College Campus Charger")
                .addText("Detour: +1.2 km (+3 mins) | Type 2 AC 7.2kW / CCS2 30kW")
                .addText("Price: ₹18/kWh | Rating: 4.9 ★")
                .setOnClickListener(() -> getScreenManager().push(new ChargerDetailsCarScreen(getCarContext())))
                .build();
        listBuilder.addItem(station1);

        Row station2 = new Row.Builder()
                .setTitle("GreenPark Shared Charger")
                .addText("Detour: +3.8 km (+7 mins) | Type 2 AC 7.2kW")
                .addText("Price: ₹16/kWh | Rating: 4.7 ★")
                .setOnClickListener(() -> getScreenManager().push(new ChargerDetailsCarScreen(getCarContext())))
                .build();
        listBuilder.addItem(station2);

        return new ListTemplate.Builder()
                .setTitle("Route Corridor Chargers")
                .setSingleList(listBuilder.build())
                .setHeaderAction(Action.BACK)
                .build();
    }
}
