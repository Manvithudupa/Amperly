package com.amperly.app.data.repository;

import android.content.Context;

import androidx.lifecycle.LiveData;

import com.amperly.app.data.local.AmperlyDatabase;
import com.amperly.app.data.local.entity.Vehicle;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class VehicleRepository {
    private static volatile VehicleRepository INSTANCE;
    private final AmperlyDatabase db;
    private final ExecutorService executor = Executors.newFixedThreadPool(4);

    private VehicleRepository(Context context) {
        db = AmperlyDatabase.getInstance(context);
    }

    public static VehicleRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (VehicleRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new VehicleRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public LiveData<Vehicle> getVehicleByUserId(String userId) {
        return db.vehicleDao().getVehicleByUserId(userId);
    }

    public void insertVehicle(Vehicle vehicle) {
        executor.execute(() -> db.vehicleDao().insert(vehicle));
    }
}
