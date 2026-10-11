package com.amperly.app.data.local.entity;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.Index;
import androidx.room.PrimaryKey;

/**
 * One pending change that still has to reach Supabase.
 *
 * <p>Room is written first and this row is queued in the same breath, so the UI is never
 * waiting on the network and a write cannot be lost if the app dies before it is pushed.
 * The outbox is drained in order by {@code SyncEngine}.
 *
 * <p>This is deliberately a single queue table rather than a "needs sync" flag on all 23
 * entities: it keeps the entity classes free of transport concerns and means a new synced
 * table needs no schema change here.
 */
@Entity(tableName = "sync_outbox", indices = {@Index(value = {"createdAtMs"})})
public class SyncOutboxEntry {

    public static final String OP_UPSERT = "UPSERT";
    public static final String OP_DELETE = "DELETE";
    /**
     * A call to a Postgres function rather than a row write. The function name is held
     * in {@link #getTableName()} and the arguments in {@link #getPayloadJson()}.
     */
    public static final String OP_RPC = "RPC";

    @PrimaryKey
    @NonNull
    private String id;

    private String tableName;
    private String rowId;
    private String operation;
    /** The entity serialised with Gson; null for a delete. */
    private String payloadJson;
    private long createdAtMs;
    private int attempts;
    private String lastError;

    public SyncOutboxEntry(@NonNull String id, String tableName, String rowId, String operation,
                           String payloadJson, long createdAtMs, int attempts, String lastError) {
        this.id = id;
        this.tableName = tableName;
        this.rowId = rowId;
        this.operation = operation;
        this.payloadJson = payloadJson;
        this.createdAtMs = createdAtMs;
        this.attempts = attempts;
        this.lastError = lastError;
    }

    @NonNull
    public String getId() { return id; }
    public void setId(@NonNull String id) { this.id = id; }

    public String getTableName() { return tableName; }
    public void setTableName(String tableName) { this.tableName = tableName; }

    public String getRowId() { return rowId; }
    public void setRowId(String rowId) { this.rowId = rowId; }

    public String getOperation() { return operation; }
    public void setOperation(String operation) { this.operation = operation; }

    public String getPayloadJson() { return payloadJson; }
    public void setPayloadJson(String payloadJson) { this.payloadJson = payloadJson; }

    public long getCreatedAtMs() { return createdAtMs; }
    public void setCreatedAtMs(long createdAtMs) { this.createdAtMs = createdAtMs; }

    public int getAttempts() { return attempts; }
    public void setAttempts(int attempts) { this.attempts = attempts; }

    public String getLastError() { return lastError; }
    public void setLastError(String lastError) { this.lastError = lastError; }

    public boolean isDelete() {
        return OP_DELETE.equals(operation);
    }

    public boolean isRpc() {
        return OP_RPC.equals(operation);
    }
}
