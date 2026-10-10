package com.amperly.app.data.repository;

import android.content.Context;

import androidx.lifecycle.LiveData;

import com.amperly.app.data.local.AmperlyDatabase;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.Dispute;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.local.entity.Vehicle;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class AmperlyRepository {
    private static volatile AmperlyRepository INSTANCE;
    private final AmperlyDatabase db;
    private final ExecutorService executor = Executors.newFixedThreadPool(4);

    private AmperlyRepository(Context context) {
        db = AmperlyDatabase.getInstance(context);
    }

    public static AmperlyRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (AmperlyRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new AmperlyRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public LiveData<User> getUser(String id) {
        return db.userDao().getUserById(id);
    }

    public void insertUser(User user) {
        executor.execute(() -> db.userDao().insert(user));
    }

    public LiveData<Vehicle> getVehicleByUserId(String userId) {
        return db.vehicleDao().getVehicleByUserId(userId);
    }

    public void insertVehicle(Vehicle vehicle) {
        executor.execute(() -> db.vehicleDao().insert(vehicle));
    }

    public LiveData<List<ChargerStation>> getAllStations() {
        return db.chargerStationDao().getAllStations();
    }

    public List<ChargerStation> getAllStationsSync() {
        return db.chargerStationDao().getAllStationsSync();
    }

    public LiveData<ChargerStation> getStationById(String id) {
        return db.chargerStationDao().getStationById(id);
    }

    public void insertStation(ChargerStation station) {
        executor.execute(() -> db.chargerStationDao().insert(station));
    }

    public LiveData<List<Reservation>> getReservationsForConsumer(String consumerId) {
        return db.reservationDao().getReservationsForConsumer(consumerId);
    }

    public void insertReservation(Reservation reservation) {
        executor.execute(() -> db.reservationDao().insert(reservation));
    }

    public LiveData<List<ChargingSession>> getSessionsForConsumer(String consumerId) {
        return db.chargingSessionDao().getSessionsForConsumer(consumerId);
    }

    public void insertChargingSession(ChargingSession session) {
        executor.execute(() -> db.chargingSessionDao().insert(session));
    }

    public LiveData<List<Dispute>> getAllDisputes() {
        return db.disputeDao().getAllDisputes();
    }

    public void insertDispute(Dispute dispute) {
        executor.execute(() -> db.disputeDao().insert(dispute));
    }
}
