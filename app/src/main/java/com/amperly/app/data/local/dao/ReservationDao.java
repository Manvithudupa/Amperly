package com.amperly.app.data.local.dao;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import androidx.room.Update;

import com.amperly.app.data.local.entity.Reservation;

import java.util.List;

@Dao
public interface ReservationDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insert(Reservation reservation);

    @Update
    void update(Reservation reservation);

    @Query("SELECT * FROM reservations WHERE consumerId = :consumerId ORDER BY createdAtMs DESC")
    LiveData<List<Reservation>> getReservationsForConsumer(String consumerId);

    @Query("SELECT * FROM reservations WHERE stationId = :stationId ORDER BY createdAtMs DESC")
    LiveData<List<Reservation>> getReservationsForStation(String stationId);

    @Query("SELECT * FROM reservations WHERE id = :id LIMIT 1")
    Reservation getReservationByIdSync(String id);

    @Query("SELECT * FROM reservations WHERE bookingCode = :bookingCode LIMIT 1")
    Reservation getReservationByBookingCodeSync(String bookingCode);
}
