package com.amperly.app.data.repository;

import android.content.Context;

import androidx.lifecycle.LiveData;

import com.amperly.app.data.local.AmperlyDatabase;
import com.amperly.app.data.local.entity.ChargingSession;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class SessionRepository {
    private static volatile SessionRepository INSTANCE;
    private final AmperlyDatabase db;
    private final ExecutorService executor = Executors.newFixedThreadPool(4);

    private SessionRepository(Context context) {
        db = AmperlyDatabase.getInstance(context);
    }

    public static SessionRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (SessionRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new SessionRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public LiveData<List<ChargingSession>> getSessionsForConsumer(String consumerId) {
        return db.chargingSessionDao().getSessionsForConsumer(consumerId);
    }

    public void insertSession(ChargingSession session) {
        executor.execute(() -> db.chargingSessionDao().insert(session));
    }
}
