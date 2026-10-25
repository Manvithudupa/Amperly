package com.amperly.app.data.local.dao;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import androidx.room.Update;

import com.amperly.app.data.local.entity.Vehicle;

import java.util.List;

@Dao
public interface VehicleDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insert(Vehicle vehicle);

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertAll(List<Vehicle> vehicles);

    @Update
    void update(Vehicle vehicle);

    /**
     * The profile everything is planned against.
     *
     * <p>Ordered by the active flag rather than taking an arbitrary {@code LIMIT 1}: an account
     * with several vehicles must always resolve to the selected one. The second sort key only
     * keeps the answer stable if a sync ever leaves two rows flagged active.
     */
    @Query("SELECT * FROM vehicles WHERE userId = :userId ORDER BY isActive DESC, id ASC LIMIT 1")
    Vehicle getVehicleByUserIdSync(String userId);

    @Query("SELECT * FROM vehicles WHERE userId = :userId ORDER BY isActive DESC, id ASC LIMIT 1")
    LiveData<Vehicle> getVehicleByUserId(String userId);

    @Query("SELECT * FROM vehicles WHERE id = :vehicleId LIMIT 1")
    Vehicle getByIdSync(String vehicleId);

    @Query("SELECT * FROM vehicles WHERE userId = :userId ORDER BY isActive DESC, make COLLATE NOCASE ASC, id ASC")
    List<Vehicle> getVehiclesForUserSync(String userId);

    @Query("SELECT * FROM vehicles WHERE userId = :userId ORDER BY isActive DESC, make COLLATE NOCASE ASC, id ASC")
    LiveData<List<Vehicle>> observeVehiclesForUser(String userId);

    /** Clears the flag on every other profile of the account, so one switch is one active row. */
    @Query("UPDATE vehicles SET isActive = 0 WHERE userId = :userId AND id != :keepId")
    void deactivateOthers(String userId, String keepId);

    /** The ids that have to be patched on the server when another profile is selected. */
    @Query("SELECT id FROM vehicles WHERE userId = :userId AND isActive = 1 AND id != :keepId")
    List<String> activeIdsExcept(String userId, String keepId);

    @Query("UPDATE vehicles SET isActive = 1 WHERE id = :vehicleId")
    void markActive(String vehicleId);

    @Query("DELETE FROM vehicles WHERE id = :vehicleId")
    void deleteById(String vehicleId);

    @Query("SELECT COUNT(*) FROM vehicles WHERE userId = :userId")
    int countForUser(String userId);

    @Query("SELECT * FROM vehicles")
    List<Vehicle> getAllVehiclesSync();
}
