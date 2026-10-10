package com.amperly.app.car;

import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.car.app.Screen;
import androidx.car.app.Session;

import com.amperly.app.car.screen.RouteOverviewCarScreen;

public class AmperlyCarSession extends Session {

    @NonNull
    @Override
    public Screen onCreateScreen(@NonNull Intent intent) {
        return new RouteOverviewCarScreen(getCarContext());
    }
}
