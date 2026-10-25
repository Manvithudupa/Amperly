package com.amperly.app.core.common;

import android.content.Context;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import com.amperly.app.R;
import com.amperly.app.data.remote.SupabaseRest;

import java.util.Locale;

/**
 * Turns a technical failure into one plain-language sentence.
 *
 * <p>Nothing a user sees may be an exception message, an HTTP status, a table name or SQL. This is
 * the one place that decides what a failure means; the raw detail is only ever logged. The decision
 * itself ({@link #classify(int, String)}) is pure, so it is unit-testable without Android.
 */
public final class UserMessages {

    private static final String TAG = "UserMessages";

    /** What a failure means to a person. */
    public enum Kind {
        OFFLINE,
        AUTH_INVALID_CREDENTIALS,
        AUTH_EMAIL_UNCONFIRMED,
        AUTH_ALREADY_REGISTERED,
        PERMISSION,
        NOT_FOUND,
        CONFLICT,
        VALIDATION,
        RATE_LIMIT,
        SERVER,
        MAP_UNAVAILABLE,
        PLACE_NO_RESULTS,
        UNKNOWN
    }

    private UserMessages() {
    }

    /** Maps an exception, using its type and message plus any extra technical text. */
    public static String from(Context context, @Nullable Throwable error, @StringRes int fallbackRes) {
        if (context == null) {
            return "";
        }
        if (error == null) {
            return context.getString(fallbackRes);
        }
        // The technical detail belongs in the log, never on the screen or the car display.
        Log.w(TAG, "Technical failure mapped for the user", error);
        return messageFor(context, classify(error, null), fallbackRes);
    }

    /** Maps a technical string (a stored write error, an API status, a gateway message). */
    public static String fromText(Context context, @Nullable String technicalText,
                                  @StringRes int fallbackRes) {
        if (context == null) {
            return "";
        }
        if (technicalText == null || technicalText.trim().isEmpty()) {
            return context.getString(fallbackRes);
        }
        Kind kind = classify(-1, technicalText);
        if (kind == Kind.UNKNOWN) {
            return context.getString(fallbackRes);
        }
        // Keep the detail in the log; return only the friendly sentence.
        Log.w(TAG, "Technical message mapped for the user: " + technicalText);
        return messageFor(context, kind, fallbackRes);
    }

    /** Classifies an exception and whatever extra context the caller has. */
    public static Kind classify(@Nullable Throwable error, @Nullable String technicalText) {
        int code = -1;
        StringBuilder text = new StringBuilder();
        if (technicalText != null) {
            text.append(technicalText);
        }
        if (error != null) {
            if (error instanceof SupabaseRest.RestException) {
                code = ((SupabaseRest.RestException) error).getCode();
            }
            String message = error.getMessage();
            if (message != null && !message.trim().isEmpty()) {
                if (text.length() > 0) {
                    text.append(' ');
                }
                text.append(message);
            }
        }
        return classify(code, text.toString());
    }

    /**
     * The pure decision.
     *
     * @param httpCode 0 for a transport failure, a real HTTP status when there is one, or -1 when
     *                 there is no status to go on.
     */
    public static Kind classify(int httpCode, @Nullable String technicalText) {
        String text = technicalText == null ? "" : technicalText.toLowerCase(Locale.US);

        if (containsAny(text, "invalid login credentials", "invalid_credentials", "invalid grant",
                "wrong password", "incorrect password", "invalid password", "user not found",
                "email not found")) {
            return Kind.AUTH_INVALID_CREDENTIALS;
        }
        if (containsAny(text, "email not confirmed", "email_not_confirmed")) {
            return Kind.AUTH_EMAIL_UNCONFIRMED;
        }
        if (containsAny(text, "user_already_exists", "already registered")) {
            return Kind.AUTH_ALREADY_REGISTERED;
        }
        // Geoapify (map, address search, routing). Every one of its clients prefixes the technical
        // failure with the service name, so these rules cannot swallow an unrelated message that
        // happens to mention a key. Nothing here reaches the screen: only the resolved string does.
        if (text.contains("geoapify")) {
            if (containsAny(text, "api key", "401", "403", "denied")) {
                return Kind.MAP_UNAVAILABLE;
            }
            if (containsAny(text, "429", "rate limit", "credits")) {
                return Kind.RATE_LIMIT;
            }
            if (containsAny(text, "no route", "no matching place", "no address", "no results")) {
                return Kind.PLACE_NO_RESULTS;
            }
            if (containsAny(text, "http 5", "unavailable")) {
                return Kind.SERVER;
            }
            if (containsAny(text, "http 400", "bad request", "invalid")) {
                return Kind.VALIDATION;
            }
        }
        if (httpCode == 0
                || containsAny(text, "could not reach", "unable to resolve host", "unknownhost",
                "timed out", "timeout", "failed to connect", "no address associated with hostname",
                "network is unreachable", "connection reset", "connection refused", "offline")) {
            return Kind.OFFLINE;
        }
        if (httpCode == 401 || httpCode == 403
                || containsAny(text, "permission denied", "row level security", "row-level security",
                "jwt expired", "not authorized", "unauthorized", "http 401", "http 403")) {
            return Kind.PERMISSION;
        }
        if (httpCode == 429
                || containsAny(text, "too many requests", "rate limit", "rate_limit", "credits")) {
            return Kind.RATE_LIMIT;
        }
        if (httpCode >= 500) {
            return Kind.SERVER;
        }
        if (containsAny(text, "request_denied", "over_query_limit", "over_daily_limit",
                "key restriction", "api key not valid", "api_key_invalid", "keyinvalid",
                "google denied the request", "quota")) {
            return Kind.MAP_UNAVAILABLE;
        }
        if (containsAny(text, "zero_results", "not_found", "no route between",
                "no address found")) {
            return Kind.PLACE_NO_RESULTS;
        }
        if (httpCode == 404 || text.contains("not found")) {
            return Kind.NOT_FOUND;
        }
        if (httpCode == 409
                || containsAny(text, "23505", "duplicate", "already exists", "conflict")) {
            return Kind.CONFLICT;
        }
        if (httpCode == 400 || httpCode == 422
                || containsAny(text, "pgrst", "schema cache", "column", "violates", "invalid input",
                "bad request", "syntax error")) {
            return Kind.VALIDATION;
        }
        return Kind.UNKNOWN;
    }

    /** The one string resource each kind resolves to. */
    public static String messageFor(Context context, Kind kind, @StringRes int fallbackRes) {
        switch (kind) {
            case OFFLINE:
                return context.getString(R.string.error_offline);
            case AUTH_INVALID_CREDENTIALS:
                return context.getString(R.string.error_auth_invalid_credentials);
            case AUTH_EMAIL_UNCONFIRMED:
                return context.getString(R.string.error_auth_email_unconfirmed);
            case AUTH_ALREADY_REGISTERED:
                return context.getString(R.string.error_auth_already_registered);
            case PERMISSION:
                return context.getString(R.string.error_permission);
            case NOT_FOUND:
                return context.getString(R.string.error_not_found);
            case CONFLICT:
                return context.getString(R.string.error_conflict);
            case VALIDATION:
                return context.getString(R.string.error_validation);
            case RATE_LIMIT:
                return context.getString(R.string.error_rate_limited);
            case SERVER:
                return context.getString(R.string.error_server);
            case MAP_UNAVAILABLE:
                return context.getString(R.string.error_map_unavailable);
            case PLACE_NO_RESULTS:
                return context.getString(R.string.error_place_not_found);
            case UNKNOWN:
            default:
                return context.getString(fallbackRes);
        }
    }

    private static boolean containsAny(String text, String... needles) {
        for (String needle : needles) {
            if (text.contains(needle)) {
                return true;
            }
        }
        return false;
    }
}
