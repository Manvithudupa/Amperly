package com.amperly.app.data.remote;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.Nullable;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.IOException;

import okhttp3.MediaType;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Response;

/**
 * Supabase Auth (GoTrue) session handling.
 *
 * <p>Deliberately synchronous: the whole app already runs its work through
 * {@code AmperlyRepository.background(...)}, so blocking here keeps the calling style
 * consistent instead of stacking callbacks on top of an executor.
 *
 * <p>SESSION STORAGE: tokens live in app-private {@link SharedPreferences}. That is
 * readable on a rooted device. A production build should use
 * {@code EncryptedSharedPreferences} (androidx.security:security-crypto) or the Android
 * Keystore; it is left out here to avoid adding a dependency the rest of the app does
 * not otherwise need.
 */
public final class SupabaseAuth {

    private static final String PREFS = "amperly_supabase_session";
    private static final String KEY_ACCESS = "access_token";
    private static final String KEY_REFRESH = "refresh_token";
    private static final String KEY_EXPIRES_AT = "expires_at_ms";
    private static final String KEY_USER_ID = "auth_user_id";
    private static final String KEY_EMAIL = "email";

    private static final MediaType JSON = MediaType.parse("application/json; charset=utf-8");

    /** Refresh this long before the token actually expires. */
    private static final long REFRESH_MARGIN_MS = 60_000L;

    private SupabaseAuth() {
    }

    /** A rejected request: bad credentials, a missing account, a policy denial. */
    public static class Failure extends Exception {
        public Failure(String message) {
            super(message);
        }
    }

    /** A transport-level problem. Nothing was changed on the server. */
    public static class NetworkFailure extends RuntimeException {
        public NetworkFailure(String message, Throwable cause) {
            super(message, cause);
        }
    }

    /** A signed-in Supabase account. */
    public static class Session {
        public final String accessToken;
        public final String refreshToken;
        public final String authUserId;
        public final String email;
        public final long expiresAtMs;

        Session(String accessToken, String refreshToken, String authUserId, String email,
                long expiresAtMs) {
            this.accessToken = accessToken;
            this.refreshToken = refreshToken;
            this.authUserId = authUserId;
            this.email = email;
            this.expiresAtMs = expiresAtMs;
        }

        public boolean needsRefresh(long nowMs) {
            return expiresAtMs > 0 && nowMs + REFRESH_MARGIN_MS >= expiresAtMs;
        }
    }

    private static final class HttpResult {
        final int code;
        final String body;

        HttpResult(int code, @Nullable String body) {
            this.code = code;
            this.body = body == null ? "" : body;
        }

        boolean isSuccessful() {
            return code >= 200 && code < 300;
        }

        JsonObject json() {
            if (body.isEmpty()) {
                return new JsonObject();
            }
            JsonElement parsed = JsonParser.parseString(body);
            return parsed.isJsonObject() ? parsed.getAsJsonObject() : new JsonObject();
        }
    }

    private interface CallSupplier {
        Response<ResponseBody> get() throws IOException;
    }

    // ------------------------------------------------------------------ state

    public static boolean isConfigured() {
        return SupabaseClient.isReady();
    }

    /** True once a session has been loaded into {@link SupabaseClient}. */
    public static boolean isSignedIn() {
        return SupabaseClient.authHeader() != null;
    }

    @Nullable
    public static String authUserId() {
        return SupabaseClient.appUserId();
    }

    // ------------------------------------------------------------------ sign in

    public static Session signIn(Context context, String email, String password)
            throws Failure {
        requireConfigured();
        JsonObject body = new JsonObject();
        body.addProperty("email", email == null ? "" : email.trim());
        body.addProperty("password", password == null ? "" : password);

        HttpResult result = execute(() ->
                SupabaseClient.goTrue().grant("password", toJsonBody(body)).execute());
        if (!result.isSuccessful()) {
            throw new Failure(describe(result, "Sign-in failed."));
        }
        Session session = parseSession(result, null, null);
        persist(context, session);
        apply(session);
        return session;
    }

    /** Creates an account. Returns null when the project requires email confirmation. */
    @Nullable
    public static Session signUp(Context context, String email, String password)
            throws Failure {
        requireConfigured();
        JsonObject body = new JsonObject();
        body.addProperty("email", email == null ? "" : email.trim());
        body.addProperty("password", password == null ? "" : password);

        HttpResult result = execute(() ->
                SupabaseClient.goTrue().signUp(toJsonBody(body)).execute());
        if (!result.isSuccessful()) {
            throw new Failure(describe(result, "Sign-up failed."));
        }
        if (!result.json().has("access_token")) {
            // Projects with email confirmation enabled return the bare user record.
            return null;
        }
        Session session = parseSession(result, null, null);
        persist(context, session);
        apply(session);
        return session;
    }

    // ------------------------------------------------------------------ session

    /** Loads a stored session and refreshes it when it is close to expiring. */
    @Nullable
    public static Session restoreSession(Context context) {
        if (!SupabaseClient.isReady()) {
            return null;
        }
        SharedPreferences prefs = prefs(context);
        String access = prefs.getString(KEY_ACCESS, null);
        if (access == null || access.isEmpty()) {
            return null;
        }
        String storedUserId = prefs.getString(KEY_USER_ID, null);
        String storedEmail = prefs.getString(KEY_EMAIL, null);
        Session session = new Session(access, prefs.getString(KEY_REFRESH, null),
                storedUserId, storedEmail, prefs.getLong(KEY_EXPIRES_AT, 0L));

        if (session.needsRefresh(System.currentTimeMillis())) {
            try {
                return refresh(context);
            } catch (Failure failure) {
                // The refresh token is no longer usable. Require a fresh sign-in rather
                // than leaving a dead token attached to every request.
                clear(context);
                return null;
            }
        }
        apply(session);
        return session;
    }

    public static Session refresh(Context context) throws Failure {
        requireConfigured();
        SharedPreferences prefs = prefs(context);
        String refreshToken = prefs.getString(KEY_REFRESH, null);
        if (refreshToken == null || refreshToken.isEmpty()) {
            throw new Failure("No stored session to refresh. Please sign in again.");
        }
        JsonObject body = new JsonObject();
        body.addProperty("refresh_token", refreshToken);

        HttpResult result = execute(() ->
                SupabaseClient.goTrue().grant("refresh_token", toJsonBody(body)).execute());
        if (!result.isSuccessful()) {
            throw new Failure(describe(result, "Your session expired. Please sign in again."));
        }
        Session session = parseSession(result, prefs.getString(KEY_USER_ID, null),
                prefs.getString(KEY_EMAIL, null));
        persist(context, session);
        apply(session);
        return session;
    }

    public static void signOut(Context context) {
        try {
            String header = SupabaseClient.authHeader();
            if (SupabaseClient.isReady() && header != null) {
                SupabaseClient.goTrue().logout(header).execute();
            }
        } catch (IOException | RuntimeException ignored) {
            // Signing out locally is what matters; a failed server call must not leave
            // the user stuck in a signed-in state.
        }
        clear(context);
    }

    // ------------------------------------------------------------------ internal

    private static void apply(Session session) {
        SupabaseClient.setAccessToken(session.accessToken);
        SupabaseClient.setAppUserId(session.authUserId);
    }

    private static void persist(Context context, Session session) {
        prefs(context).edit()
                .putString(KEY_ACCESS, session.accessToken)
                .putString(KEY_REFRESH, session.refreshToken)
                .putString(KEY_USER_ID, session.authUserId)
                .putString(KEY_EMAIL, session.email)
                .putLong(KEY_EXPIRES_AT, session.expiresAtMs)
                .apply();
    }

    private static void clear(Context context) {
        prefs(context).edit().clear().apply();
        SupabaseClient.setAccessToken(null);
        SupabaseClient.setAppUserId(null);
    }

    private static SharedPreferences prefs(Context context) {
        return context.getApplicationContext()
                .getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    private static void requireConfigured() throws Failure {
        if (!SupabaseConfig.isConfigured()) {
            throw new Failure("Supabase is not configured. Add SUPABASE_URL and "
                    + "SUPABASE_PUBLISHABLE_KEY to local.properties and rebuild.");
        }
        if (SupabaseConfig.looksLikeSecretKey()) {
            throw new Failure("The configured Supabase key is a secret key. Replace it with the "
                    + "publishable key — a secret key must never ship inside an app.");
        }
    }

    private static Session parseSession(HttpResult result, @Nullable String fallbackUserId,
                                        @Nullable String fallbackEmail) throws Failure {
        JsonObject json = result.json();
        String access = optString(json, "access_token");
        if (access == null) {
            throw new Failure("The authentication response did not contain an access token.");
        }
        String refresh = optString(json, "refresh_token");
        long expiresInSeconds = 3600L;
        JsonElement expiresIn = json.get("expires_in");
        if (expiresIn != null && expiresIn.isJsonPrimitive()) {
            expiresInSeconds = expiresIn.getAsLong();
        }

        String userId = fallbackUserId;
        String email = fallbackEmail;
        JsonElement userElement = json.get("user");
        if (userElement != null && userElement.isJsonObject()) {
            JsonObject user = userElement.getAsJsonObject();
            String parsedId = optString(user, "id");
            String parsedEmail = optString(user, "email");
            if (parsedId != null) {
                userId = parsedId;
            }
            if (parsedEmail != null) {
                email = parsedEmail;
            }
        }
        long expiresAt = System.currentTimeMillis() + (expiresInSeconds * 1000L);
        return new Session(access, refresh, userId, email, expiresAt);
    }

    private static String describe(HttpResult result, String fallback) {
        String message = null;
        if (!result.body.isEmpty()) {
            try {
                JsonObject json = result.json();
                message = firstNonEmpty(optString(json, "error_description"),
                        optString(json, "msg"), optString(json, "message"),
                        optString(json, "error"));
            } catch (RuntimeException ignored) {
                message = null;
            }
        }
        return message != null ? message : fallback + " (HTTP " + result.code + ")";
    }

    @Nullable
    private static String optString(JsonObject json, String key) {
        JsonElement element = json.get(key);
        return element == null || element.isJsonNull() || !element.isJsonPrimitive()
                ? null : element.getAsString();
    }

    @Nullable
    private static String firstNonEmpty(String... values) {
        for (String value : values) {
            if (value != null && !value.trim().isEmpty()) {
                return value;
            }
        }
        return null;
    }

    private static RequestBody toJsonBody(JsonObject json) {
        return RequestBody.create(json.toString(), JSON);
    }

    /**
     * Runs a call and reads the body exactly once. Reading a {@link ResponseBody} twice
     * throws, and error bodies are the only place GoTrue puts its message, so the body
     * has to survive into {@link #describe}.
     */
    private static HttpResult execute(CallSupplier supplier) {
        try {
            Response<ResponseBody> response = supplier.get();
            ResponseBody body = response.body();
            String raw = body == null ? "" : body.string();
            return new HttpResult(response.code(), raw);
        } catch (IOException ioException) {
            throw new NetworkFailure("Could not reach Supabase. Check your connection and "
                    + "try again — nothing was changed.", ioException);
        }
    }
}
