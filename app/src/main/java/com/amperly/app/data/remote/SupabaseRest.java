package com.amperly.app.data.remote;

import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import okhttp3.MediaType;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Response;

/**
 * The high-level Supabase data client.
 *
 * <p>Maps PostgREST JSON straight onto the Room entity classes. This works because the
 * Postgres column names in {@code supabase/schema.sql} are quoted camelCase and identical
 * to the Java field names — which are themselves the Room column names, since no entity
 * uses {@code @ColumnInfo}. So there is no DTO layer anywhere in this project.
 */
public final class SupabaseRest {

    private static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");

    /** PostgREST caps result sets server-side; pull in pages of this size. */
    public static final int PAGE_SIZE = 500;

    private static final Gson GSON = new Gson();

    private SupabaseRest() {
    }

    /** Anything the server rejected or that failed in transit. */
    public static class RestException extends RuntimeException {
        private final int code;

        RestException(int code, String message, @Nullable Throwable cause) {
            super(message, cause);
            this.code = code;
        }

        public int getCode() {
            return code;
        }

        /**
         * Whether retrying later could plausibly succeed. A 4xx means the server
         * understood the request and refused it (usually a policy denial), so retrying
         * the identical request forever would just spin.
         */
        public boolean isRetryable() {
            return code == 0 || code == 408 || code == 429 || code >= 500;
        }
    }

    public static boolean isReady() {
        return SupabaseClient.isReady();
    }

    // ------------------------------------------------------------------ read

    /**
     * One page of rows changed strictly after the cursor, oldest first, plus the cursor to
     * use next time.
     *
     * <p>The cursor is the raw {@code serverUpdatedAt} string the server sent, passed
     * straight back on the next call. It is never parsed into epoch millis: Postgres
     * serialises {@code timestamptz} with microseconds and a {@code +00:00} offset, and
     * round-tripping that through a Java date format introduces rounding and clock-skew
     * bugs for no benefit.
     */
    public static class SyncPage<T> {
        public final List<T> rows;
        @Nullable
        public final String cursor;

        SyncPage(List<T> rows, @Nullable String cursor) {
            this.rows = rows;
            this.cursor = cursor;
        }

        public boolean isFullPage(int limit) {
            return rows.size() >= limit;
        }
    }

    public static <T> SyncPage<T> selectChanged(String table, Type type, @Nullable String cursor,
                                                int limit) {
        Map<String, String> query = new HashMap<>();
        query.put("select", "*");
        query.put("order", "serverUpdatedAt.asc");
        query.put("limit", String.valueOf(limit));
        if (cursor != null && !cursor.isEmpty()) {
            query.put("serverUpdatedAt", "gt." + cursor);
        }

        Response<ResponseBody> response = call(() ->
                SupabaseClient.postgrest()
                        .select(table, query, SupabaseClient.authHeader())
                        .execute());
        String body = read(response);
        requireSuccess(response, body, "Reading " + table);

        List<T> rows = new ArrayList<>();
        String nextCursor = cursor;
        if (body != null && !body.isEmpty()) {
            JsonElement parsed = JsonParser.parseString(body);
            if (parsed.isJsonArray()) {
                for (JsonElement element : parsed.getAsJsonArray()) {
                    T item = GSON.fromJson(element, type);
                    if (item != null) {
                        rows.add(item);
                    }
                    if (element.isJsonObject()) {
                        JsonElement stamp = element.getAsJsonObject().get("serverUpdatedAt");
                        if (stamp != null && stamp.isJsonPrimitive()) {
                            nextCursor = stamp.getAsString();
                        }
                    }
                }
            }
        }
        return new SyncPage<>(rows, nextCursor);
    }

    public static <T> List<T> select(String table, Type type, Map<String, String> query) {
        Response<ResponseBody> response = call(() ->
                SupabaseClient.postgrest()
                        .select(table, query, SupabaseClient.authHeader())
                        .execute());
        String body = read(response);
        requireSuccess(response, body, "Reading " + table);
        return parseList(body, type);
    }

    /** Confirms the project is reachable and the publishable key is accepted. */
    public static boolean ping() {
        Response<ResponseBody> response = call(() ->
                SupabaseClient.postgrest()
                        .ping("users", "id", 1, SupabaseClient.authHeader())
                        .execute());
        String body = read(response);
        requireSuccess(response, body, "Connecting to Supabase");
        return true;
    }

    // ------------------------------------------------------------------ write

    /**
     * Inserts a row, or updates the existing one with the same primary key. Returns the
     * row as the server stored it, so the caller can pick up the server-maintained
     * {@code serverUpdatedAt}.
     */
    @Nullable
    public static <T> T upsert(String table, Object entity, Type type) {
        String payload = GSON.toJson(entity);
        Response<ResponseBody> response = call(() ->
                SupabaseClient.postgrest()
                        .upsert(table, RequestBody.create(payload, JSON),
                                SupabaseClient.authHeader())
                        .execute());
        String body = read(response);
        requireSuccess(response, body, "Saving to " + table);
        List<T> rows = parseList(body, type);
        return rows.isEmpty() ? null : rows.get(0);
    }

    /**
     * Calls a Postgres function exposed at {@code /rest/v1/rpc/<function>} and returns
     * whatever JSON it produced.
     *
     * <p>This is how the settlement transitions reach the server. The app still computes
     * the figures locally so the UI works offline, but the database no longer accepts a
     * client writing a captured amount or a meter total straight onto the table — the
     * function recomputes them from the readings and the station's tariff.
     */
    @Nullable
    public static JsonElement rpc(String function, @Nullable Object args) {
        String payload = args == null ? "{}" : GSON.toJson(args);
        Response<ResponseBody> response = call(() ->
                SupabaseClient.postgrest()
                        .rpc(function, RequestBody.create(payload, JSON), SupabaseClient.authHeader())
                        .execute());
        String body = read(response);
        requireSuccess(response, body, "Calling " + function);
        if (body == null || body.isEmpty()) {
            return null;
        }
        return JsonParser.parseString(body);
    }

    public static void deleteById(String table, String id) {
        Map<String, String> filter = new HashMap<>();
        filter.put("id", "eq." + id);
        Response<ResponseBody> response = call(() ->
                SupabaseClient.postgrest()
                        .delete(table, filter, SupabaseClient.authHeader())
                        .execute());
        String body = read(response);
        requireSuccess(response, body, "Deleting from " + table);
    }

    // ------------------------------------------------------------------ internal

    private interface CallSupplier {
        Response<ResponseBody> get() throws IOException;
    }

    private static Response<ResponseBody> call(CallSupplier supplier) {
        try {
            return supplier.get();
        } catch (IOException ioException) {
            // code 0 marks a transport failure, which is always retryable.
            throw new RestException(0, "Could not reach Supabase: " + ioException.getMessage(),
                    ioException);
        }
    }

    private static void requireSuccess(Response<ResponseBody> response, String body,
                                       String action) {
        if (response.isSuccessful()) {
            return;
        }
        throw new RestException(response.code(), action + " failed (HTTP " + response.code()
                + "): " + extractMessage(body, response.code()), null);
    }

    private static String extractMessage(String body, int code) {
        if (body != null && !body.isEmpty()) {
            try {
                JsonElement parsed = JsonParser.parseString(body);
                if (parsed.isJsonObject()) {
                    JsonElement message = parsed.getAsJsonObject().get("message");
                    if (message != null && message.isJsonPrimitive()) {
                        return message.getAsString();
                    }
                }
            } catch (RuntimeException ignored) {
                // Fall through to the raw body below.
            }
            if (body.length() <= 300) {
                return body;
            }
        }
        if (code == 401 || code == 403) {
            return "Permission denied by server security policy.";
        }
        return "no details";
    }

    private static String read(Response<ResponseBody> response) {
        ResponseBody body = response.body();
        if (body == null) {
            return "";
        }
        try {
            return body.string();
        } catch (IOException ioException) {
            return "";
        }
    }

    private static <T> List<T> parseList(String body, Type type) {
        List<T> result = new ArrayList<>();
        if (body == null || body.isEmpty()) {
            return result;
        }
        JsonElement parsed = JsonParser.parseString(body);
        if (!parsed.isJsonArray()) {
            return result;
        }
        for (JsonElement element : parsed.getAsJsonArray()) {
            T item = GSON.fromJson(element, type);
            if (item != null) {
                result.add(item);
            }
        }
        return result;
    }

}
