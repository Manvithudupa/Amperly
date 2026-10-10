package com.amperly.app.data.local;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;

import com.amperly.app.data.local.dao.ChargerStationDao;
import com.amperly.app.data.local.dao.ChargingSessionDao;
import com.amperly.app.data.local.dao.DisputeDao;
import com.amperly.app.data.local.dao.ReservationDao;
import com.amperly.app.data.local.dao.UserDao;
import com.amperly.app.data.local.dao.VehicleDao;
import com.amperly.app.data.local.entity.BatteryUpdate;
import com.amperly.app.data.local.entity.ChargerPort;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.Dispute;
import com.amperly.app.data.local.entity.Invoice;
import com.amperly.app.data.local.entity.MeterReading;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.SafetyEvent;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.local.entity.Vehicle;

@Database(entities = {
        User.class, Vehicle.class, ChargerStation.class, ChargerPort.class,
        Reservation.class, ChargingSession.class, MeterReading.class,
        Invoice.class, Dispute.class, SafetyEvent.class, BatteryUpdate.class
}, version = 1, exportSchema = false)
public abstract class AmperlyDatabase extends RoomDatabase {

    private static volatile AmperlyDatabase INSTANCE;

    public abstract UserDao userDao();
    public abstract VehicleDao vehicleDao();
    public abstract ChargerStationDao chargerStationDao();
    public abstract ReservationDao reservationDao();
    public abstract ChargingSessionDao chargingSessionDao();
    public abstract DisputeDao disputeDao();

    public static AmperlyDatabase getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (AmperlyDatabase.class) {
                if (INSTANCE == null) {
                    INSTANCE = Room.databaseBuilder(context.getApplicationContext(),
                                    AmperlyDatabase.class, "amperly_db")
                            .fallbackToDestructiveMigration()
                            .build();
                }
            }
        }
        return INSTANCE;
    }
}
