package com.amperly.app.data.repository;

import android.content.Context;

import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.engine.routing.RoutePlannerEngine;

import java.util.List;

public class RouteRepository {
    private static volatile RouteRepository INSTANCE;

    private RouteRepository(Context context) {}

    public static RouteRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (RouteRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new RouteRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public RoutePlannerEngine.RoutePlanResult planTrip(
            String origin, String destination, double distanceKm, int soc,
            Vehicle vehicle, List<ChargerStation> stations) {
        return RoutePlannerEngine.planRoute(origin, destination, distanceKm, soc, vehicle, stations);
    }
}
