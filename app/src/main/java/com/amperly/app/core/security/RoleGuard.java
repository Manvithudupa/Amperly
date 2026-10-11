package com.amperly.app.core.security;

import com.amperly.app.core.common.AppConstants;
import com.amperly.app.data.local.entity.User;

public class RoleGuard {

    public static boolean canPerformAdminAction(User user) {
        return user != null && AppConstants.ROLE_ADMIN.equalsIgnoreCase(user.getRole());
    }

    public static boolean canManageStation(User user, String stationHostId) {
        if (user == null) return false;
        if (AppConstants.ROLE_ADMIN.equalsIgnoreCase(user.getRole())) return true;
        return AppConstants.ROLE_HOST.equalsIgnoreCase(user.getRole()) && user.getId().equals(stationHostId);
    }

    public static boolean canReservePort(User user) {
        return user != null; // Any authenticated user (Consumer or Host) can reserve slots
    }
}
