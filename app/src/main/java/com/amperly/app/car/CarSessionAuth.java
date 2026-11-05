package com.amperly.app.car;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.remote.SupabaseAuth;
import com.amperly.app.data.repository.AmperlyRepository;

import java.util.ArrayList;
import java.util.List;

/**
 * Restores the account for the car process.
 *
 * <p>The car app can be started without the phone activity ever running, so
 * {@link AuthManager} is empty even though a Supabase session is stored on the device. Without
 * this, the car screen read a blank user id: it showed no trip, and the audit row it saved was
 * rejected by RLS.
 *
 * <p>The restore is shared. The session and the first screen both need the account, so callers
 * that arrive while a restore is running wait for the same result instead of signing in twice
 * and rotating the refresh token underneath each other.
 */
public final class CarSessionAuth {

    private static final String TAG = "CarSessionAuth";

    private static final Object LOCK = new Object();
    private static final List<Callback> WAITING = new ArrayList<>();
    private static boolean restoring;

    /** Result is delivered on the main thread. */
    public interface Callback {
        void onResult(boolean signedIn);
    }

    private CarSessionAuth() {
    }

    /**
     * Makes sure a real account is available, restoring the stored session when necessary.
     *
     * <p>When the account is restricted, the stored token is cleared and the result is false:
     * the car must not bypass a ban that the phone enforces at sign-in.
     */
    public static void ensureSignedIn(@NonNull Context context, @NonNull Callback callback) {
        if (AuthManager.getInstance().isLoggedIn() && SupabaseAuth.isSignedIn()) {
            callback.onResult(true);
            return;
        }

        synchronized (LOCK) {
            if (restoring) {
                WAITING.add(callback);
                return;
            }
            restoring = true;
            // Include the starter in the fan-out. The session starts the restore before the
            // screen asks for the account, so leaving this callback out silently drops the
            // session's audit write even though the screen loads normally.
            WAITING.add(callback);
        }

        Context app = context.getApplicationContext();
        AmperlyRepository repo = AmperlyRepository.getInstance(app);
        repo.background(() -> {
            SupabaseAuth.Session session = SupabaseAuth.restoreSession(app);
            if (session == null || session.authUserId == null
                    || session.authUserId.trim().isEmpty()) {
                return null;
            }
            User user = repo.resolveOrCreateAppUser(session.authUserId, session.email, null);
            if (user == null) {
                return null;
            }
            String restricted = repo.accountRestrictionMessage(user);
            if (restricted != null) {
                Log.w(TAG, "Car session refused: " + restricted);
                SupabaseAuth.signOut(app);
                return null;
            }
            return user;
        }, user -> {
            if (user != null) {
                AuthManager.getInstance().setCurrentUser(user);
            }
            finish(user != null);
        });
    }

    private static void finish(boolean signedIn) {
        List<Callback> waiting;
        synchronized (LOCK) {
            restoring = false;
            waiting = new ArrayList<>(WAITING);
            WAITING.clear();
        }
        for (Callback callback : waiting) {
            callback.onResult(signedIn);
        }
    }
}
