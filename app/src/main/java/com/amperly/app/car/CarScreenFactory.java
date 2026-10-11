package com.amperly.app.car;

import androidx.car.app.CarContext;
import androidx.car.app.Screen;

import com.amperly.app.car.screen.ChargerDetailsCarScreen;
import com.amperly.app.car.screen.ChargerListCarScreen;
import com.amperly.app.car.screen.ReservationStatusCarScreen;
import com.amperly.app.car.screen.RouteOverviewCarScreen;
import com.amperly.app.car.screen.SoCUpdateCarScreen;

public class CarScreenFactory {

    public enum ScreenType {
        ROUTE_OVERVIEW,
        CHARGER_LIST,
        CHARGER_DETAILS,
        SOC_UPDATE,
        RESERVATION_STATUS
    }

    public static Screen createScreen(ScreenType type, CarContext carContext) {
        switch (type) {
            case CHARGER_LIST:
                return new ChargerListCarScreen(carContext);
            case CHARGER_DETAILS:
                return new ChargerDetailsCarScreen(carContext);
            case SOC_UPDATE:
                return new SoCUpdateCarScreen(carContext);
            case RESERVATION_STATUS:
                return new ReservationStatusCarScreen(carContext);
            case ROUTE_OVERVIEW:
            default:
                return new RouteOverviewCarScreen(carContext);
        }
    }
}
