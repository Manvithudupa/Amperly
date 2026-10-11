package com.amperly.app;

import com.amperly.app.core.security.RoleGuard;
import com.amperly.app.data.local.entity.User;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class RoleGuardTest {

    @Test
    public void testRoleGuardPermissions() {
        User admin = new User("u_admin", "Admin User", "admin@amperly.app", "+1234567890", "ADMIN");
        User host = new User("u_host", "Host User", "host@amperly.app", "+1234567891", "HOST");
        User consumer = new User("u_consumer", "Consumer User", "consumer@amperly.app", "+1234567892", "CONSUMER");

        assertTrue(RoleGuard.canPerformAdminAction(admin));
        assertFalse(RoleGuard.canPerformAdminAction(host));
        assertFalse(RoleGuard.canPerformAdminAction(consumer));

        assertTrue(RoleGuard.canManageStation(host, "u_host"));
        assertFalse(RoleGuard.canManageStation(host, "u_other_host"));
        assertTrue(RoleGuard.canManageStation(admin, "u_other_host"));

        assertTrue(RoleGuard.canReservePort(consumer));
        assertTrue(RoleGuard.canReservePort(host));
    }
}
