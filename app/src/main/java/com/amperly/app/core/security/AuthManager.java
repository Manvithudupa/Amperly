package com.amperly.app.core.security;

import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.PilotDataSeeder;
import com.amperly.app.data.local.entity.User;

import java.util.HashMap;
import java.util.Map;

/**
 * Demo identity layer.
 *
 * Amperly's model is one account that can act as a Consumer and as a Host. In the prototype the
 * role switch is explicit and the acting user comes from the seeded pilot data, so reviewers can see
 * every role without a login step.
 */
public class AuthManager {

    private static volatile AuthManager INSTANCE;

    private final Map<String, User> usersByRole = new HashMap<>();
    private String currentRole = AppConstants.ROLE_CONSUMER;

    private AuthManager() {
        usersByRole.put(AppConstants.ROLE_CONSUMER, new User(PilotDataSeeder.USER_STUDENT,
                "Aarav Student", "aarav@abccollege.edu", "+919876543211", AppConstants.ROLE_CONSUMER,
                null, "VERIFIED", false));
        usersByRole.put(AppConstants.ROLE_HOST, new User(PilotDataSeeder.USER_CAMPUS_ADMIN,
                "ABC College Administration", "host@abccollege.edu", "+919876543210",
                AppConstants.ROLE_HOST, "ABC College of Engineering", "VERIFIED", false));
        usersByRole.put(AppConstants.ROLE_ADMIN, new User(PilotDataSeeder.USER_PLATFORM_ADMIN,
                "Amperly Ops", "admin@amperly.app", "+919876543299", AppConstants.ROLE_ADMIN,
                "Amperly", "VERIFIED", false));
    }

    public static synchronized AuthManager getInstance() {
        if (INSTANCE == null) {
            INSTANCE = new AuthManager();
        }
        return INSTANCE;
    }

    public User getCurrentUser() {
        return usersByRole.get(currentRole);
    }

    /**
     * Forgets the acting identity entirely. Called when a Supabase session ends, so the
     * next account on this device starts from its own profile rather than the previous
     * holder's, and so the demo identities are not left reachable.
     */
    public void clearCurrentUser() {
        usersByRole.clear();
        AppStateStore.get().setUserId("");
    }

    public void setCurrentUser(User user) {
        if (user != null && user.getRole() != null) {
            usersByRole.put(user.getRole(), user);
        }
    }

    public boolean isLoggedIn() {
        return getCurrentUser() != null;
    }

    public String getCurrentUserId() {
        User user = getCurrentUser();
        return user == null ? "" : user.getId();
    }

    public String getCurrentRole() {
        return currentRole;
    }

    public void setRole(String role) {
        if (role == null) {
            return;
        }
        currentRole = role;
        AppStateStore.get().setRole(role);
        AppStateStore.get().setUserId(getCurrentUserId());
    }

    public String describeCurrentUser() {
        User user = getCurrentUser();
        if (user == null) {
            return "Not signed in";
        }
        return "Acting as " + user.getName() + " (" + roleLabel(currentRole) + ")"
                + (user.getOrganizationName() == null ? "" : " · " + user.getOrganizationName())
                + " · " + user.getVerificationStatus();
    }

    public static String roleLabel(String role) {
        if (AppConstants.ROLE_HOST.equals(role)) {
            return "Host";
        }
        if (AppConstants.ROLE_ADMIN.equals(role)) {
            return "Administrator";
        }
        return "Consumer";
    }
}
