package com.amperly.app.data.remote;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.Nullable;

import com.amperly.app.data.local.AmperlyDatabase;
import com.amperly.app.data.local.entity.SyncOutboxEntry;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.util.List;
import java.util.UUID;

/**
 * Postgres is the source of truth; Room is the read cache and the offline write queue.
 *
 * <p>Every local write lands in Room and leaves a row in {@code sync_outbox}. A sync is
 * then:
 *
 * <ol>
 *   <li><b>Push</b> — drain the outbox oldest-first, so a device that was offline for a
 *       while reconciles in the order the user made the changes.</li>
 *   <li><b>Pull</b> — page through each table's rows where
 *       {@code serverUpdatedAt > cursor}, and upsert them into Room. The cursor is kept
 *       per table, so a pull only ever transfers what changed.</li>
 * </ol>
 *
 * <p>Push runs before pull on purpose: if a row were pulled first, a local edit that has
 * not been sent yet would be silently overwritten by the older server copy.
 *
 * <p>Known limitation: deletions are only synced from the device that made them. There is
 * no tombstone table, so a row deleted on another device will reappear on this one until
 * something writes it again. The domain avoids hard deletes (statuses are used instead),
 * which is what makes that acceptable here.
 */
public final class SyncEngine {

    private static final String CURSOR_PREFS = "amperly_sync_cursors";
    private static final String KEY_LAST_SYNC_MS = "__lastSyncMs";
    private static final String KEY_LAST_ERROR = "__lastError";

    private static final int PUSH_BATCH = 100;
    private static final int MAX_PULL_PAGES = 20;
    private static final Gson GSON = new Gson();

    private SyncEngine() {
    }

    /** The outcome of one sync pass, for the UI to report honestly. */
    public static final class Result {
        public final boolean ran;
        public final int pushed;
        public final int failed;
        public final int pulled;
        @Nullable
        public final String message;

        Result(boolean ran, int pushed, int failed, int pulled, @Nullable String message) {
            this.ran = ran;
            this.pushed = pushed;
            this.failed = failed;
            this.pulled = pulled;
            this.message = message;
        }

        static Result skipped(String message) {
            return new Result(false, 0, 0, 0, message);
        }

        public String summary() {
            if (!ran) {
                return message == null ? "Sync did not run." : message;
            }
            if (failed > 0) {
                return pushed + " pushed, " + pulled + " pulled, " + failed
                        + " could not be sent and will be retried.";
            }
            return pushed + " pushed, " + pulled + " pulled.";
        }
    }

    public static boolean isEnabled() {
        return SupabaseRest.isReady();
    }

    // ------------------------------------------------------------------ enqueue

    /**
     * Queues a call to a Postgres function.
     *
     * <p>Used for the settlement transitions (payment capture, session completion,
     * cancellation, dispute resolution) where the change must be produced by the
     * server's own logic rather than by copying a locally edited row onto a table.
     *
     * <p>The function name is stored in the table-name column and {@code dedupeKey} in
     * the row-id column, so two calls for the same subject collapse into the latest one
     * exactly as two edits of the same row do.
     */
    public static void enqueueRpc(AmperlyDatabase db, String functionName, String dedupeKey,
                                  Object args) {
        if (!isEnabled()) {
            return;
        }
        String entryId = UUID.randomUUID().toString();
        SyncOutboxEntry entry = new SyncOutboxEntry(entryId, functionName, dedupeKey,
                SyncOutboxEntry.OP_RPC, GSON.toJson(args), System.currentTimeMillis(), 0, null);
        db.syncOutboxDao().insert(entry);
        db.syncOutboxDao().dropOtherEntriesFor(functionName, dedupeKey, entryId);
    }

    /**
     * Queues an entity for push. Called from the repository immediately after the Room
     * write, so the local change is durable even if the network never comes back.
     */
    public static void enqueue(AmperlyDatabase db, String tableName, Object entity,
                               String operation) {
        if (!isEnabled()) {
            return;
        }
        SyncTables.Table table = SyncTables.byName(tableName);
        if (table == null) {
            return;
        }
        String payload = SyncOutboxEntry.OP_DELETE.equals(operation)
                ? null : GSON.toJson(entity, table.type);
        String rowId = extractId(payload);
        if (rowId == null) {
            // Without a primary key the server cannot address the row; refuse to queue
            // rather than send something that cannot be applied.
            return;
        }
        String entryId = UUID.randomUUID().toString();
        SyncOutboxEntry entry = new SyncOutboxEntry(entryId, tableName, rowId, operation,
                payload, System.currentTimeMillis(), 0, null);
        db.syncOutboxDao().insert(entry);
        // Collapse earlier pending changes for the same row down to this one.
        db.syncOutboxDao().dropOtherEntriesFor(tableName, rowId, entryId);
    }

    @Nullable
    private static String extractId(@Nullable String payloadJson) {
        if (payloadJson == null) {
            return null;
        }
        try {
            JsonElement parsed = JsonParser.parseString(payloadJson);
            if (!parsed.isJsonObject()) {
                return null;
            }
            JsonObject json = parsed.getAsJsonObject();
            JsonElement id = json.get("id");
            return id == null || id.isJsonNull() || !id.isJsonPrimitive()
                    ? null : id.getAsString();
        } catch (RuntimeException ignored) {
            return null;
        }
    }

    // ------------------------------------------------------------------ sync

    public static Result syncNow(Context context, AmperlyDatabase db) {
        if (!SupabaseRest.isReady()) {
            return Result.skipped("Supabase is not configured — running on the device only.");
        }
        if (!SupabaseAuth.isSignedIn()) {
            return Result.skipped("Not signed in to Supabase, so nothing was synced.");
        }

        int pushed = 0;
        int failed = 0;
        int pulled = 0;

        try {
            int[] pushOutcome = push(db);
            pushed = pushOutcome[0];
            failed = pushOutcome[1];

            pulled = pull(context, db);
        } catch (SupabaseRest.RestException restException) {
            recordError(context, restException.getMessage());
            return new Result(true, pushed, failed, pulled,
                    "Sync stopped: " + restException.getMessage());
        } catch (RuntimeException unexpected) {
            recordError(context, unexpected.getMessage());
            return new Result(true, pushed, failed, pulled,
                    "Sync stopped unexpectedly: " + unexpected.getMessage());
        }

        recordSuccess(context);
        return new Result(true, pushed, failed, pulled, null);
    }

    /** Drains the outbox. Returns {pushed, failed}. */
    private static int[] push(AmperlyDatabase db) {
        int pushed = 0;
        int failed = 0;
        List<SyncOutboxEntry> pending = db.syncOutboxDao().getPending(PUSH_BATCH);

        for (SyncOutboxEntry entry : pending) {
            try {
                if (entry.isRpc()) {
                    // A function call, not a row write. It is checked before the table
                    // lookup below, because a function name is not a table name and would
                    // otherwise be dropped as an unknown table.
                    JsonElement payload = entry.getPayloadJson() == null
                            ? null : JsonParser.parseString(entry.getPayloadJson());
                    SupabaseRest.rpc(entry.getTableName(), payload);
                    db.syncOutboxDao().deleteById(entry.getId());
                    pushed++;
                    continue;
                }

                SyncTables.Table table = SyncTables.byName(entry.getTableName());
                if (table == null) {
                    // A table this build does not know about — most likely left over from an
                    // older install. Drop it rather than retrying forever.
                    db.syncOutboxDao().deleteById(entry.getId());
                    continue;
                }
                if (entry.isDelete()) {
                    SupabaseRest.deleteById(table.name, entry.getRowId());
                } else {
                    Object entity = GSON.fromJson(entry.getPayloadJson(), table.type);
                    if (entity != null) {
                        SupabaseRest.upsert(table.name, entity, table.type);
                    }
                }
                db.syncOutboxDao().deleteById(entry.getId());
                pushed++;
            } catch (SupabaseRest.RestException restException) {
                db.syncOutboxDao().recordFailure(entry.getId(), restException.getMessage());
                failed++;
                if (restException.getCode() == 0) {
                    // Transport is down. Stop draining so the remaining entries keep
                    // their original order instead of failing one by one.
                    break;
                }
            }
        }
        return new int[]{pushed, failed};
    }

    /** Pages every table forward from its stored cursor. */
    private static int pull(Context context, AmperlyDatabase db) {
        SharedPreferences cursors = cursors(context);
        int pulled = 0;

        for (SyncTables.Table table : SyncTables.ALL) {
            String cursor = cursors.getString(table.name, null);
            for (int page = 0; page < MAX_PULL_PAGES; page++) {
                SupabaseRest.SyncPage<?> result =
                        SupabaseRest.selectChanged(table.name, table.type, cursor, SupabaseRest.PAGE_SIZE);
                if (result.rows.isEmpty() && result.cursor == null) {
                    break;
                }
                final List<?> rows = result.rows;
                if (!rows.isEmpty()) {
                    db.runInTransaction(() -> {
                        for (Object row : rows) {
                            SyncTables.write(db, table, row);
                        }
                    });
                    pulled += rows.size();
                }
                if (result.cursor != null) {
                    cursor = result.cursor;
                    cursors.edit().putString(table.name, cursor).apply();
                }
                if (!result.isFullPage(SupabaseRest.PAGE_SIZE)) {
                    break;
                }
            }
        }
        return pulled;
    }

    // ------------------------------------------------------------------ state

    public static int pendingCount(AmperlyDatabase db) {
        return db.syncOutboxDao().countPending();
    }

    /** Human-readable state for the UI: what is queued, when it last worked, what broke. */
    public static String statusSummary(Context context, AmperlyDatabase db) {
        if (!isEnabled()) {
            return "Device only — no Supabase project configured.";
        }
        if (!SupabaseAuth.isSignedIn()) {
            return "Supabase is configured but nobody is signed in.";
        }
        int pending = pendingCount(db);
        int failedEntries = db.syncOutboxDao().countFailed();
        long lastSync = cursors(context).getLong(KEY_LAST_SYNC_MS, 0L);
        String lastError = cursors(context).getString(KEY_LAST_ERROR, null);

        StringBuilder summary = new StringBuilder();
        summary.append(pending == 0 ? "All changes synced" : pending + " change(s) queued");
        if (failedEntries > 0) {
            summary.append(" · ").append(failedEntries).append(" failing");
        }
        if (lastSync > 0) {
            summary.append(" · last sync ")
                    .append(com.amperly.app.core.common.Formatters.agoFromNow(lastSync));
        }
        if (lastError != null && !lastError.isEmpty()) {
            summary.append(" · ").append(lastError);
        }
        return summary.toString();
    }

    /** Clears cursors and the outbox — used when signing out so one user's queue is not pushed as the next. */
    public static void reset(Context context, AmperlyDatabase db) {
        cursors(context).edit().clear().apply();
        db.syncOutboxDao().clear();
    }

    private static void recordSuccess(Context context) {
        cursors(context).edit()
                .putLong(KEY_LAST_SYNC_MS, System.currentTimeMillis())
                .remove(KEY_LAST_ERROR)
                .apply();
    }

    private static void recordError(Context context, @Nullable String message) {
        cursors(context).edit()
                .putString(KEY_LAST_ERROR, message)
                .apply();
    }

    private static SharedPreferences cursors(Context context) {
        return context.getApplicationContext()
                .getSharedPreferences(CURSOR_PREFS, Context.MODE_PRIVATE);
    }
}
