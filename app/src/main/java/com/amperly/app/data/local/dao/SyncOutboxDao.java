package com.amperly.app.data.local.dao;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

import com.amperly.app.data.local.entity.SyncOutboxEntry;

import java.util.List;

@Dao
public interface SyncOutboxDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insert(SyncOutboxEntry entry);

    /** Oldest first, so dependent rows are pushed in the order they were written. */
    @Query("SELECT * FROM sync_outbox ORDER BY createdAtMs ASC LIMIT :limit")
    List<SyncOutboxEntry> getPending(int limit);

    @Query("SELECT COUNT(*) FROM sync_outbox")
    int countPending();

    @Query("SELECT COUNT(*) FROM sync_outbox WHERE lastError IS NOT NULL")
    int countFailed();

    @Query("DELETE FROM sync_outbox WHERE id = :id")
    void deleteById(String id);

    /**
     * Records a failure without dropping the entry, so the change is retried on the next
     * sync instead of being silently lost.
     */
    @Query("UPDATE sync_outbox SET attempts = attempts + 1, lastError = :error WHERE id = :id")
    void recordFailure(String id, String error);

    @Query("DELETE FROM sync_outbox")
    void clear();

    /**
     * Collapses a backlog for one row down to its latest state. A row edited five times
     * offline should push once, not five times.
     */
    @Query("DELETE FROM sync_outbox WHERE tableName = :tableName AND rowId = :rowId AND id != :keepId")
    void dropOtherEntriesFor(String tableName, String rowId, String keepId);

    @Query("SELECT * FROM sync_outbox WHERE lastError IS NOT NULL ORDER BY createdAtMs ASC")
    List<SyncOutboxEntry> getFailedEntries();
}
