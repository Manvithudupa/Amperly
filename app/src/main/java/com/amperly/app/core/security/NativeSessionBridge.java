package com.amperly.app.core.security;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.core.state.TripSessionStore;
import com.amperly.app.data.remote.SupabaseAuth;
import com.amperly.app.data.repository.AmperlyRepository;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Shares the Supabase session between Flutter and the Java car layer.
 *
 * <p>Both surfaces live in one process but can start independently: Android Auto can open
 * {@code AmperlyCarAppService} without the phone activity, and the phone can be used without a
 * car. They must therefore agree on one persisted bearer token. Flutter's {@code LocalStorage}
 * is routed over this channel into {@link SupabaseAuth}'s Keystore-backed store; the car reads
 * the same store with no second copy.
 *
 * <p>The channel carries tokens, never log arguments or the session JSON.
 */
public final class NativeSessionBridge {

    private static final String TAG = "NativeSessionBridge";

    private static final String CHANNEL = "com.amperly.app/session";

    /** Keeps the last activity's application context; no Activity is retained. */
    @Nullable
    private static Context appContext;

    /** The live channel, used for Java-to-Flutter refresh notifications. */
    @Nullable
    private static MethodChannel channel;

    private static final Handler MAIN = new Handler(Looper.getMainLooper());

    private NativeSessionBridge() {
    }

    /** Registers the bridge for the Flutter engine owned by {@code FlutterPhoneActivity}. */
    public static void attach(@NonNull Context context, @NonNull FlutterEngine engine) {
        appContext = context.getApplicationContext();
        MethodChannel active = new MethodChannel(
                engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        active.setMethodCallHandler(NativeSessionBridge::handle);
        channel = active;
        SupabaseAuth.setRefreshListener(NativeSessionBridge::notifySessionRefreshed);
    }

    /** Removes the handler when the Flutter engine is torn down. */
    public static void detach(@NonNull FlutterEngine engine) {
        MethodChannel old = channel;
        if (old != null) {
            old.setMethodCallHandler(null);
        }
        channel = null;
        appContext = null;
        SupabaseAuth.setRefreshListener(null);
    }

    /**
     * Delivers a Java-side refresh to Flutter without blocking the auth worker.
     *
     * <p>The Dart handler refreshes through its own Supabase client and writes the resulting
     * session back over the bridge. That keeps both in-memory clients on one rotating token.
     */
    private static void notifySessionRefreshed(@Nullable String sessionJson) {
        if (sessionJson == null) {
            return;
        }
        MethodChannel active = channel;
        if (active == null) {
            return;
        }
        MAIN.post(() -> {
            MethodChannel current = channel;
            if (current != null) {
                current.invokeMethod("sessionChanged", sessionJson);
            }
        });
    }

    private static void handle(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Context context = appContext;
        if (context == null) {
            result.error("session_unavailable", "The native session store is not attached.", null);
            return;
        }

        switch (call.method) {
            case "isAvailable":
                result.success(true);
                break;

            case "hasSession":
                result.success(SupabaseAuth.hasStoredSession(context));
                break;

            case "readSession":
                result.success(SupabaseAuth.persistedSessionJson(context));
                break;

            case "writeSession": {
                Object argument = call.argument("session");
                if (!(argument instanceof String)) {
                    result.error("session_invalid", "The session payload was missing.", null);
                    return;
                }
                String previousAuthId = SupabaseAuth.authUserId();
                try {
                    SupabaseAuth.adoptSessionFromHost(context, (String) argument);
                    String currentAuthId = SupabaseAuth.authUserId();
                    if (previousAuthId != null && !previousAuthId.equals(currentAuthId)) {
                        // A different account signed in on the phone. The previous
                        // account's cached rows must not remain visible in the car.
                        clearCachedAccount(context);
                    }
                    result.success(true);
                } catch (Exception error) {
                    Log.w(TAG, "Flutter session was refused: "
                            + error.getClass().getSimpleName());
                    result.error("session_rejected",
                            "The session could not be stored.", null);
                }
                break;
            }

            case "clearSession":
                SupabaseAuth.clearFromHost(context);
                result.success(true);
                break;

            case "clearAppSession":
                SupabaseAuth.clearFromHost(context);
                clearCachedAccount(context);
                result.success(true);
                break;

            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * Drops the Java-side account and cache after the phone signs out.
     *
     * <p>The token removal is already done by {@code clearSession}; this is the part that stops
     * the car from showing the previous person's profile or cached reservations. Database work is
     * off the main thread, and a cache failure is logged rather than turning a completed sign-out
     * back into a signed-in screen.
     */
    private static void clearCachedAccount(@NonNull Context context) {
        AuthManager.getInstance().clearCurrentUser();
        AppStateStore.get().reset();
        TripSessionStore.end(context);
        try {
            AmperlyRepository repository = AmperlyRepository.getInstance(context);
            repository.background(() -> {
                repository.clearLocalData();
                return Boolean.TRUE;
            }, ignored -> { });
        } catch (RuntimeException error) {
            Log.w(TAG, "Could not clear the local cache after sign-out: "
                    + error.getClass().getSimpleName());
        }
        context.getSharedPreferences("amperly_session", Context.MODE_PRIVATE)
                .edit()
                .remove("last_user_id")
                .apply();
    }
}
