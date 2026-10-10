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

public class SoCUpdateCarScreen extends Screen {

    public SoCUpdateCarScreen(@NonNull CarContext carContext) {
        super(carContext);
    }

    @NonNull
    @Override
    public Template onGetTemplate() {
        ItemList.Builder listBuilder = new ItemList.Builder();

        int[] socOptions = {15, 20, 25, 30, 35, 40, 50, 60};
        for (int option : socOptions) {
            Row row = new Row.Builder()
                    .setTitle("Actual Battery: " + option + "%")
                    .addText("Tap to recalculate remaining route & update chargers")
                    .setOnClickListener(() -> {
                        CarToast.makeText(getCarContext(), "Authoritative SoC " + option + "% applied! Rerouting...", CarToast.LENGTH_SHORT).show();
                        getScreenManager().pop();
                    })
                    .build();
            listBuilder.addItem(row);
        }

        return new ListTemplate.Builder()
                .setTitle("Select Actual Dashboard Battery %")
                .setSingleList(listBuilder.build())
                .setHeaderAction(Action.BACK)
                .build();
    }
}
