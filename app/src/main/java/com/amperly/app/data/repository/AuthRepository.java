package com.amperly.app.data.repository;

import android.content.Context;

import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.User;

public class AuthRepository {
    private static volatile AuthRepository INSTANCE;

    private AuthRepository(Context context) {}

    public static AuthRepository getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (AuthRepository.class) {
                if (INSTANCE == null) {
                    INSTANCE = new AuthRepository(context.getApplicationContext());
                }
            }
        }
        return INSTANCE;
    }

    public User getCurrentUser() {
        return AuthManager.getInstance().getCurrentUser();
    }

    public boolean isLoggedIn() {
        return AuthManager.getInstance().isLoggedIn();
    }
}
