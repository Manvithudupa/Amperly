package com.amperly.app.data.repository;

import android.content.Context;

import androidx.lifecycle.LiveData;

import com.amperly.app.data.local.AmperlyDatabase;
import com.amperly.app.data.local.entity.ChargerStation;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ChargerRepository {
    private static volatile ChargerRepository INSTANCE;
    private final AmperlyDatabase db;
    private final ExecutorService executor = Executors.newFixedThreadPool(4);

    private ChargerRepository(Context context) {
        db = AmperlyDatabase.getInstance(context);
    }

    public static ChargerRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (ChargerRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new ChargerRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public LiveData<List<ChargerStation>> getAllStations() {
        return db.chargerStationDao().getAllStations();
    }

    public List<ChargerStation> getAllStationsSync() {
        return db.chargerStationDao().getAllStationsSync();
    }

    public void insertStation(ChargerStation station) {
        executor.execute(() -> db.chargerStationDao().insert(station));
    }
}
