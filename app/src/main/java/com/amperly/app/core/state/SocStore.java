package com.amperly.app.core.state;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.Nullable;

/**
 * Remembers the battery percentage the driver last confirmed, per account and per vehicle.
 *
 * <p>{@link AppStateStore} holds the state of charge in memory only, which is right for a
 * figure that changes while driving but wrong for the driver's own reading: it disappeared on
 * every launch, so the discovery screen said "Not set" each time the app started even after
 * the driver had typed their battery in. The reading is kept here instead, keyed by account
 * because two people can sign in on the same device.
 *
 * <p>It is also keyed by vehicle. One account can keep several cars, and a percentage typed
 * for the van says nothing about the car parked beside it — carrying it across a vehicle
 * switch would quietly plan the wrong range.
 *
 * <p>It ages out rather than living forever: a percentage from yesterday morning is not a
 * statement about the battery today, and a stale number would silently skew range estimates.
 */
public final class SocStore {

    private static final String PREFS = "amperly_soc";
    private static final String KEY_SOC = "soc_";
    private static final String KEY_SET_AT = "set_at_";

    /** How long a hand-entered reading is trusted before the UI asks for it again. */
    public static final long MAX_AGE_MS = 12L * 60L * 60L * 1000L;

    private SocStore() {
    }

    /** Stores a reading for this account. Out-of-range values are ignored, never clamped. */
    public static void save(@Nullable Context context, @Nullable String userId, int soc) {
        save(context, userId, null, soc);
    }

    /** Stores a reading for one vehicle of this account. */
    public static void save(@Nullable Context context, @Nullable String userId,
                            @Nullable String vehicleId, int soc) {
        if (context == null || userId == null || userId.isEmpty() || soc < 0 || soc > 100) {
            return;
        }
        String key = key(userId, vehicleId);
        prefs(context).edit()
                .putInt(KEY_SOC + key, soc)
                .putLong(KEY_SET_AT + key, System.currentTimeMillis())
                .apply();
    }

    /** The stored reading, or -1 when there is none or it is too old to trust. */
    public static int load(@Nullable Context context, @Nullable String userId) {
        return load(context, userId, null);
    }

    /** The stored reading for one vehicle, or -1 when there is none or it is too old. */
    public static int load(@Nullable Context context, @Nullable String userId,
                           @Nullable String vehicleId) {
        if (context == null || userId == null || userId.isEmpty()) {
            return -1;
        }
        String key = key(userId, vehicleId);
        SharedPreferences prefs = prefs(context);
        if (!prefs.contains(KEY_SOC + key) && vehicleId != null && !vehicleId.isEmpty()) {
            // A reading written before vehicles were scoped belonged to the only profile the
            // account had, so it is the right reading for the active one after an upgrade.
            key = userId;
        }
        if (!prefs.contains(KEY_SOC + key)) {
            return -1;
        }
        int soc = prefs.getInt(KEY_SOC + key, -1);
        long setAt = prefs.getLong(KEY_SET_AT + key, 0L);
        if (soc < 0 || soc > 100 || setAt <= 0
                || System.currentTimeMillis() - setAt > MAX_AGE_MS) {
            return -1;
        }
        return soc;
    }

    /**
     * The account-only key is kept for readings written before vehicles were scoped, so an
     * upgrade does not throw away the battery figure the driver had already entered.
     */
    private static String key(String userId, @Nullable String vehicleId) {
        return vehicleId == null || vehicleId.isEmpty() ? userId : userId + "::" + vehicleId;
    }

    private static SharedPreferences prefs(Context context) {
        return context.getApplicationContext().getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }
}
