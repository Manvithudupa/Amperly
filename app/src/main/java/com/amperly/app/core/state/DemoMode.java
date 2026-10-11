package com.amperly.app.core.state;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Whether this device is deliberately running on the seeded demo data instead of a
 * signed-in account.
 *
 * <p>This matters because a configured project leaves the sync engine "enabled" — it is
 * ready to talk to Supabase — even while nobody is signed in. A demo session therefore
 * still writes rows into the local outbox. Those writes can never be pushed (pushing
 * requires a signed-in session, and Row Level Security would refuse them anyway), but
 * they would be pushed the moment somebody signed in on the same device, mixing demo
 * data into the real project.
 *
 * <p>So the flag is remembered across restarts, and signing in while it is set discards
 * the local data first. Two competing datasets never meet.
 */
public final class DemoMode {

    private static final String PREFS = "amperly_app_mode";
    private static final String KEY_OFFLINE_DEMO = "offline_demo";

    private DemoMode() {
    }

    public static boolean isOfflineDemo(Context context) {
        return prefs(context).getBoolean(KEY_OFFLINE_DEMO, false);
    }

    public static void setOfflineDemo(Context context, boolean offlineDemo) {
        prefs(context).edit().putBoolean(KEY_OFFLINE_DEMO, offlineDemo).apply();
    }

    private static SharedPreferences prefs(Context context) {
        return context.getApplicationContext()
                .getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }
}
