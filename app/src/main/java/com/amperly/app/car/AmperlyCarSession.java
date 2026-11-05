package com.amperly.app.car;

import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.car.app.Screen;
import androidx.car.app.Session;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;

import com.amperly.app.car.screen.RouteOverviewCarScreen;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.entity.AndroidAutoSession;
import com.amperly.app.data.repository.AmperlyRepository;

import java.util.UUID;

/**
 * One projected session. Connecting and disconnecting are recorded so the platform can prove the car
 * experience stayed glanceable and that detailed forms were completed on the phone.
 */
public class AmperlyCarSession extends Session {

    private boolean destroyed;
    private String autoSessionId;

    @NonNull
    @Override
    public Screen onCreateScreen(@NonNull Intent intent) {
        AppStateStore.get().setCarConnected(true);
        AmperlyRepository repo = AmperlyRepository.getInstance(getCarContext());

        // A car session can start with no phone activity behind it. Restore the account before
        // writing the audit row: an empty user id is rejected by the row-level policy, and it is
        // also why the screen used to open with no trip.
        CarSessionAuth.ensureSignedIn(getCarContext(), signedIn -> {
            if (!signedIn || destroyed) {
                return;
            }
            autoSessionId = UUID.randomUUID().toString();
            final String sessionId = autoSessionId;
            final String userId = AuthManager.getInstance().getCurrentUserId();
            repo.background(() -> {
                AndroidAutoSession record = new AndroidAutoSession(sessionId, userId, null,
                        AppStateStore.get().getActivePlan() == null ? null
                                : AppStateStore.get().getActivePlan().getId(),
                        "ROUTE_OVERVIEW", AppStateStore.get().getCurrentSoc() < 0 ? 0
                        : AppStateStore.get().getCurrentSoc(), System.currentTimeMillis(), 0, 0);
                repo.saveAutoSession(record);
                return null;
            }, value -> {
            });
        });

        // Session is a LifecycleOwner in car-app 1.4.0 and offers no onDestroy() callback, so the
        // disconnect record is written from the ON_DESTROY lifecycle event instead.
        getLifecycle().addObserver(new DefaultLifecycleObserver() {
            @Override
            public void onDestroy(@NonNull LifecycleOwner owner) {
                destroyed = true;
                AppStateStore.get().setCarConnected(false);
                final String sessionId = autoSessionId;
                autoSessionId = null;
                if (sessionId == null) {
                    // The session ended before an account was available, so no row was ever
                    // written and there is nothing to close.
                    return;
                }
                AmperlyRepository repo = AmperlyRepository.getInstance(getCarContext());
                repo.background(() -> {
                    AndroidAutoSession record = new AndroidAutoSession(sessionId,
                            AuthManager.getInstance().getCurrentUserId(), null, null, "DISCONNECTED",
                            AppStateStore.get().getCurrentSoc(), System.currentTimeMillis(), 0,
                            System.currentTimeMillis());
                    repo.saveAutoSession(record);
                    return null;
                }, value -> {
                });
            }
        });

        return new RouteOverviewCarScreen(getCarContext());
    }
}
