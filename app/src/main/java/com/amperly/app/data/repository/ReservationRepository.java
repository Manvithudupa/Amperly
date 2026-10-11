package com.amperly.app.data.repository;

import android.content.Context;

import androidx.lifecycle.LiveData;

import com.amperly.app.data.local.AmperlyDatabase;
import com.amperly.app.data.local.entity.Reservation;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class ReservationRepository {
    private static volatile ReservationRepository INSTANCE;
    private final AmperlyDatabase db;
    private final ExecutorService executor = Executors.newFixedThreadPool(4);

    private ReservationRepository(Context context) {
        db = AmperlyDatabase.getInstance(context);
    }

    public static ReservationRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (ReservationRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new ReservationRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public LiveData<List<Reservation>> getReservationsForConsumer(String consumerId) {
        return db.reservationDao().getReservationsForConsumer(consumerId);
    }

    public void insertReservation(Reservation reservation) {
        executor.execute(() -> db.reservationDao().insert(reservation));
    }

    public Reservation getReservationByBookingCodeSync(String bookingCode) {
        return db.reservationDao().getReservationByBookingCodeSync(bookingCode);
    }
}
