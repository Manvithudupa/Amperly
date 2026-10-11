package com.amperly.app.core.security;

import com.amperly.app.data.local.entity.User;

public class AuthManager {
    private static volatile AuthManager INSTANCE;
    private User currentUser;

    private AuthManager() {
        // Default authenticated demo user
        this.currentUser = new User("user_student_1", "Aarav Student", "aarav@abccollege.edu", "+919876543211", "CONSUMER");
    }

    public static synchronized AuthManager getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new AuthManager();
        }
        return INSTANCE;
    }

    public User getCurrentUser() {
        return currentUser;
    }

    public void setCurrentUser(User user) {
        this.currentUser = user;
    }

    public boolean isLoggedIn() {
        return currentUser != null;
    }

    public String getCurrentUserId() {
        return currentUser != null ? currentUser.getId() : "";
    }

    public String getCurrentRole() {
        return currentUser != null ? currentUser.getRole() : "GUEST";
    }
}
