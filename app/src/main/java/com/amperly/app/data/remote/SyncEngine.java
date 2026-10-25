package com.amperly.app.data.remote;

import android.content.Context;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.sqlite.db.SupportSQLiteDatabase;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.AmperlyDatabase;
import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * The app's connection to Supabase.
 *
 * <p>Postgres is the source of truth. A save writes straight to the server through
 * {@link #save}, {@link #patch}, {@link #delete} or {@link #call}; there is no offline queue,
 * so a write either reaches the database or is reported. Room keeps the copy that was read
 * back.
 *
 * <p>{@link #syncNow} is the read direction. It pages each table forward from its per-table
 * cursor and upserts the changed rows into Room, so another device's changes — and the rows
 * the settlement functions write on the server — appear in the app. A row deleted on the
 * server has no {@code serverUpdatedAt} left to page to, so after each table is pulled its
 * live id list is read as well and any cached row missing from it is deleted.
 */
public final class SyncEngine {

    private static final String TAG = "SyncEngine";
    private static final String CURSOR_PREFS = "amperly_sync_cursors";
    private static final String KEY_LAST_SYNC_MS = "__lastSyncMs";
    private static final String KEY_LAST_ERROR = "__lastError";

    private static final int MAX_PULL_PAGES = 20;
    /** 23 tables of 500 ids are far more than any account holds; this only stops a runaway. */
    private static final int MAX_ID_PAGES = 40;
    private static final Gson GSON = new Gson();

    private SyncEngine() {
    }

    /** The outcome of one pull, for the UI to report honestly. */
    public static final class Result {
        public final boolean ran;
        public final int pulled;
        /** Cached rows removed because the server no longer has them. */
        public final int removed;
        @Nullable
        public final String message;

        Result(boolean ran, int pulled, int removed, @Nullable String message) {
            this.ran = ran;
            this.pulled = pulled;
            this.removed = removed;
            this.message = message;
        }

        static Result skipped(String message) {
            return new Result(false, 0, 0, message);
        }

        public String summary() {
            if (!ran) {
                return message == null ? "Sync did not run." : message;
            }
            return pulled + " pulled"
                    + (removed > 0 ? ", " + removed + " removed" : "") + ".";
        }
    }

    public static boolean isEnabled() {
        return SupabaseRest.isReady();
    }

    // ------------------------------------------------------------------- write
    // These run on the repository's write thread, in the same task as the Room write, so a
    // save is sent as soon as it is made. Failures propagate to the caller, which records
    // them for the account screen rather than queueing the change for later.

    /** Inserts or replaces one row. */
    public static void save(String tableName, Object entity) {
        if (!isEnabled() || entity == null) {
            return;
        }
        SyncTables.Table table = SyncTables.byName(tableName);
        if (table == null) {
            return;
        }
        SupabaseRest.upsertJson(table.name, GSON.toJson(entity, table.type));
    }

    /**
     * Updates columns of an existing row, addressed by its primary key.
     *
     * <p>A PATCH, not an upsert: an upsert is an INSERT ... ON CONFLICT and is also checked
     * against the table's INSERT policy, which a partial change cannot satisfy.
     */
    public static void patch(String tableName, String rowId, Object payload) {
        if (!isEnabled() || payload == null || rowId == null || rowId.isEmpty()) {
            return;
        }
        SyncTables.Table table = SyncTables.byName(tableName);
        if (table == null) {
            return;
        }
        SupabaseRest.updateById(table.name, rowId, GSON.toJson(payload));
    }

    public static void delete(String tableName, String rowId) {
        if (!isEnabled() || rowId == null || rowId.isEmpty()) {
            return;
        }
        SyncTables.Table table = SyncTables.byName(tableName);
        if (table == null) {
            return;
        }
        SupabaseRest.deleteById(table.name, rowId);
    }

    /** Runs a Postgres function, for the settlement transitions. */
    public static void call(String functionName, @Nullable Object args) {
        if (!isEnabled() || functionName == null || functionName.isEmpty()) {
            return;
        }
        SupabaseRest.rpc(functionName, args);
    }

    // -------------------------------------------------------------------- pull

    public static Result syncNow(Context context, AmperlyDatabase db) {
        if (!SupabaseRest.isReady()) {
            return Result.skipped(context.getString(R.string.sync_not_configured));
        }
        if (!SupabaseAuth.isSignedIn()) {
            return Result.skipped(context.getString(R.string.sync_not_signed_in));
        }

        int pulled;
        int removed;
        try {
            Counts counts = pull(context, db);
            pulled = counts.pulled;
            removed = counts.removed;
        } catch (SupabaseRest.RestException restException) {
            // The status, the URL and the server body stay in the log; the app stores one line.
            Log.w(TAG, "Sync stopped", restException);
            recordError(context, context.getString(R.string.sync_failed));
            return new Result(true, 0, 0, context.getString(R.string.sync_failed));
        } catch (RuntimeException unexpected) {
            Log.w(TAG, "Sync stopped unexpectedly", unexpected);
            recordError(context, context.getString(R.string.sync_failed));
            return new Result(true, 0, 0, context.getString(R.string.sync_failed));
        }

        recordSuccess(context);
        return new Result(true, pulled, removed, null);
    }

    /** What one pull moved, for the log line the sign-in flow writes. */
    private static final class Counts {
        int pulled;
        int removed;
    }

    /** Pages every table forward from its stored cursor, then reconciles deletions. */
    private static Counts pull(Context context, AmperlyDatabase db) {
        SharedPreferences cursors = cursors(context);
        Counts counts = new Counts();

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
                    counts.pulled += rows.size();
                }
                if (result.cursor != null) {
                    cursor = result.cursor;
                    cursors.edit().putString(table.name, cursor).apply();
                }
                if (!result.isFullPage(SupabaseRest.PAGE_SIZE)) {
                    break;
                }
            }
            counts.removed += removeDeletedRows(table, db);
        }
        return counts;
    }

    /**
     * Deletes cached rows that the server no longer has.
     *
     * <p>The cursor cannot see a deletion, so the check is the table's live id list. It is
     * read after the page pull, so a row that changed and stayed is already updated and only
     * genuinely missing ids are removed. Room's own change triggers fire for these writes,
     * so open screens drop the row without a reload.
     */
    private static int removeDeletedRows(SyncTables.Table table, AmperlyDatabase db) {
        // Nothing cached means nothing can have been deleted, so the whole id sweep is skipped.
        // A new account has six empty tables out of seven, and each skipped table is a request
        // the pull no longer has to make.
        List<String> local = localIds(db, table.name);
        if (local.isEmpty()) {
            return 0;
        }

        Set<String> remote = new HashSet<>();
        boolean complete = false;
        for (int page = 0; page < MAX_ID_PAGES; page++) {
            List<String> ids = SupabaseRest.selectIds(table.name, SupabaseRest.PAGE_SIZE,
                    page * SupabaseRest.PAGE_SIZE);
            remote.addAll(ids);
            if (ids.size() < SupabaseRest.PAGE_SIZE) {
                complete = true;
                break;
            }
        }
        if (!complete) {
            // An id list that stopped at the page guard is not the whole table, and deleting
            // the rest would look exactly like a server-side purge. Skip instead.
            Log.w(TAG, "Skipped deletion check for " + table.name + ": id list did not finish");
            return 0;
        }

        List<String> stale = SyncReconciler.staleIds(local, remote);
        if (stale.isEmpty()) {
            return 0;
        }
        db.runInTransaction(() -> {
            SupportSQLiteDatabase writable = db.getOpenHelper().getWritableDatabase();
            for (String id : stale) {
                // The table name is a registry constant, never user input; the id is bound.
                writable.execSQL("DELETE FROM \"" + table.name + "\" WHERE id = ?",
                        new Object[]{id});
            }
        });
        Log.i(TAG, "Removed " + stale.size() + " deleted row(s) from " + table.name);
        return stale.size();
    }

    /** Every cached primary key in one table. */
    private static List<String> localIds(AmperlyDatabase db, String tableName) {
        List<String> ids = new ArrayList<>();
        Cursor cursor = db.getOpenHelper().getReadableDatabase()
                .query("SELECT id FROM \"" + tableName + "\"");
        try {
            while (cursor.moveToNext()) {
                ids.add(cursor.getString(0));
            }
        } finally {
            cursor.close();
        }
        return ids;
    }

    // ------------------------------------------------------------------- state

    /** Human-readable state for the UI: when the last pull worked, and what broke. */
    public static String statusSummary(Context context, AmperlyDatabase db) {
        if (!isEnabled()) {
            return context.getString(R.string.sync_no_backend);
        }
        if (!SupabaseAuth.isSignedIn()) {
            return context.getString(R.string.sync_not_signed_in_summary);
        }
        long lastSync = cursors(context).getLong(KEY_LAST_SYNC_MS, 0L);
        String lastError = cursors(context).getString(KEY_LAST_ERROR, null);

        String when = lastSync > 0
                ? context.getString(R.string.sync_last_synced, Formatters.agoFromNow(lastSync))
                : context.getString(R.string.sync_never);
        return lastError != null && !lastError.isEmpty()
                ? context.getString(R.string.sync_summary_with_error, when, lastError)
                : when;
    }

    /**
     * Records a failed write so the account screen can say so instead of leaving the user
     * believing a save reached the database when it did not. The local copy stays in Room.
     */
    public static void recordWriteError(Context context, @Nullable String message) {
        // The technical message is logged; what the account screen shows is one friendly line.
        Log.w(TAG, message == null || message.trim().isEmpty()
                ? "A save did not reach the server." : message);
        recordError(context, context.getString(R.string.sync_write_failed));
    }

    /** Clears the pull cursors — used on sign-out so the next account reads from scratch. */
    public static void reset(Context context) {
        cursors(context).edit().clear().apply();
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
