package com.amperly.app.core.state;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.amperly.app.core.security.AuthManager;

/**
 * The trip that is currently being driven, kept outside the screen that started it.
 *
 * <p>In-app navigation used to live only inside {@code InAppNavigationFragment}: the route, the
 * progress and the intention to navigate all died with the fragment, so switching to another tab
 * silently cancelled the trip and left the Trips tab on an empty planner. The Trips tab is a tab,
 * not the trip, so the trip is remembered here instead.
 *
 * <p>The store is the app-level holder {@link AppStateStore} is, with one difference: this state
 * has to survive the process too. A driver who leaves the app mid-trip expects the trip back, so
 * every change is written to {@link SharedPreferences} and re-read by
 * {@code InAppNavigationFragment.forActiveTrip}.
 *
 * <p>It is keyed by account. A trip belongs to the person driving it, so a different account
 * signing in on the same device never inherits it.
 */
public final class TripSessionStore {

    private static final String PREFS = "amperly_trip";

    private static final String KEY_ACTIVE = "active";
    private static final String KEY_USER = "user_id";
    private static final String KEY_PLAN = "plan_id";
    private static final String KEY_ORIGIN_LAT = "origin_lat";
    private static final String KEY_ORIGIN_LNG = "origin_lng";
    private static final String KEY_DEST_LAT = "dest_lat";
    private static final String KEY_DEST_LNG = "dest_lng";
    private static final String KEY_LABEL = "label";
    private static final String KEY_PROGRESS = "progress_percent";
    private static final String KEY_STEP = "step_index";
    private static final String KEY_LAST_LAT = "last_lat";
    private static final String KEY_LAST_LNG = "last_lng";
    private static final String KEY_HAS_POSITION = "has_position";
    private static final String KEY_STARTED_AT = "started_at";
    private static final String KEY_UPDATED_AT = "updated_at";

    private TripSessionStore() {
    }

    /**
     * A trip in progress: the route it follows, how far along it the driver is, and where the
     * last position fix put them. Immutable; a new snapshot is written on every update.
     */
    public static final class TripSession {
        private final String userId;
        private final String planId;
        private final double originLat;
        private final double originLng;
        private final double destLat;
        private final double destLng;
        private final String label;
        private final int progressPercent;
        private final int stepIndex;
        private final double lastLat;
        private final double lastLng;
        private final boolean hasPosition;
        private final long startedAtMs;
        private final long updatedAtMs;

        private TripSession(String userId, String planId, double originLat, double originLng,
                            double destLat, double destLng, String label, int progressPercent,
                            int stepIndex, double lastLat, double lastLng, boolean hasPosition,
                            long startedAtMs, long updatedAtMs) {
            this.userId = userId;
            this.planId = planId;
            this.originLat = originLat;
            this.originLng = originLng;
            this.destLat = destLat;
            this.destLng = destLng;
            this.label = label;
            this.progressPercent = progressPercent;
            this.stepIndex = stepIndex;
            this.lastLat = lastLat;
            this.lastLng = lastLng;
            this.hasPosition = hasPosition;
            this.startedAtMs = startedAtMs;
            this.updatedAtMs = updatedAtMs;
        }

        @NonNull
        public String getUserId() {
            return userId;
        }

        /** The saved plan this trip belongs to, or an empty string for a one-off drive. */
        @NonNull
        public String getPlanId() {
            return planId;
        }

        public double getOriginLat() {
            return originLat;
        }

        public double getOriginLng() {
            return originLng;
        }

        public double getDestLat() {
            return destLat;
        }

        public double getDestLng() {
            return destLng;
        }

        /** Where the driver is heading, as it was named when the trip started. */
        @NonNull
        public String getLabel() {
            return label;
        }

        /** How much of the route has been driven, 0–100. */
        public int getProgressPercent() {
            return progressPercent;
        }

        /** The maneuver the driver was heading to, so the next-step card resumes in place. */
        public int getStepIndex() {
            return stepIndex;
        }

        public double getLastLat() {
            return lastLat;
        }

        public double getLastLng() {
            return lastLng;
        }

        /** True once a position fix has been recorded, so the restored screen knows where it is. */
        public boolean hasPosition() {
            return hasPosition;
        }

        public long getStartedAtMs() {
            return startedAtMs;
        }

        public long getUpdatedAtMs() {
            return updatedAtMs;
        }
    }

    /**
     * Remembers a trip that is now running.
     *
     * <p>Called when navigation starts and again on every restore. A trip for the same plan keeps
     * its progress: reopening the screen must not rewind the driver to the start of the route.
     */
    public static void start(@Nullable Context context, @Nullable String userId, @Nullable String planId,
                             double originLat, double originLng, double destLat, double destLng,
                             @Nullable String label) {
        if (context == null) {
            return;
        }
        String plan = planId == null ? "" : planId;
        String user = userId == null ? "" : userId;
        TripSession existing = load(context);
        long now = System.currentTimeMillis();
        // A different plan is a different trip; the same plan is the same trip being resumed.
        boolean resuming = existing != null && plan.equals(existing.getPlanId())
                && user.equals(existing.getUserId());

        SharedPreferences.Editor editor = prefs(context).edit()
                .putBoolean(KEY_ACTIVE, true)
                .putString(KEY_USER, user)
                .putString(KEY_PLAN, plan)
                .putString(KEY_LABEL, label == null ? "" : label)
                .putString(KEY_ORIGIN_LAT, Double.toString(originLat))
                .putString(KEY_ORIGIN_LNG, Double.toString(originLng))
                .putString(KEY_DEST_LAT, Double.toString(destLat))
                .putString(KEY_DEST_LNG, Double.toString(destLng))
                .putLong(KEY_STARTED_AT, resuming ? existing.getStartedAtMs() : now)
                .putLong(KEY_UPDATED_AT, now);
        if (!resuming) {
            editor.putInt(KEY_PROGRESS, 0)
                    .putInt(KEY_STEP, 0)
                    .putBoolean(KEY_HAS_POSITION, false)
                    .remove(KEY_LAST_LAT)
                    .remove(KEY_LAST_LNG);
        }
        editor.apply();
    }

    /** Records the latest position fix, which is what the restored screen starts from. */
    public static void updatePosition(@Nullable Context context, double latitude, double longitude) {
        if (context == null) {
            return;
        }
        prefs(context).edit()
                .putBoolean(KEY_HAS_POSITION, true)
                .putString(KEY_LAST_LAT, Double.toString(latitude))
                .putString(KEY_LAST_LNG, Double.toString(longitude))
                .putLong(KEY_UPDATED_AT, System.currentTimeMillis())
                .apply();
    }

    /** Records how far along the route the driver is, so a return resumes instead of restarting. */
    public static void updateProgress(@Nullable Context context, int progressPercent, int stepIndex) {
        if (context == null) {
            return;
        }
        prefs(context).edit()
                .putInt(KEY_PROGRESS, Math.max(0, Math.min(100, progressPercent)))
                .putInt(KEY_STEP, Math.max(0, stepIndex))
                .putLong(KEY_UPDATED_AT, System.currentTimeMillis())
                .apply();
    }

    /** The active trip, or null when there is none. */
    @Nullable
    public static TripSession load(@Nullable Context context) {
        if (context == null) {
            return null;
        }
        SharedPreferences prefs = prefs(context);
        if (!prefs.getBoolean(KEY_ACTIVE, false)) {
            return null;
        }
        try {
            return new TripSession(
                    value(prefs, KEY_USER),
                    value(prefs, KEY_PLAN),
                    Double.parseDouble(value(prefs, KEY_ORIGIN_LAT)),
                    Double.parseDouble(value(prefs, KEY_ORIGIN_LNG)),
                    Double.parseDouble(value(prefs, KEY_DEST_LAT)),
                    Double.parseDouble(value(prefs, KEY_DEST_LNG)),
                    value(prefs, KEY_LABEL),
                    prefs.getInt(KEY_PROGRESS, 0),
                    prefs.getInt(KEY_STEP, 0),
                    parseDouble(value(prefs, KEY_LAST_LAT)),
                    parseDouble(value(prefs, KEY_LAST_LNG)),
                    prefs.getBoolean(KEY_HAS_POSITION, false),
                    prefs.getLong(KEY_STARTED_AT, 0L),
                    prefs.getLong(KEY_UPDATED_AT, 0L));
        } catch (NumberFormatException e) {
            // A half-written record cannot describe a route; treat it as no trip at all.
            end(context);
            return null;
        }
    }

    /** True when the signed-in account arrived mid-trip and the Trips tab should open on it. */
    public static boolean hasActive(@Nullable Context context) {
        TripSession session = load(context);
        return session != null
                && session.getUserId().equals(AuthManager.getInstance().getCurrentUserId());
    }

    /** The trip is over: the driver stopped it or arrived. */
    public static void end(@Nullable Context context) {
        if (context == null) {
            return;
        }
        prefs(context).edit().clear().apply();
    }

    private static SharedPreferences prefs(Context context) {
        return context.getApplicationContext().getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    private static String value(SharedPreferences prefs, String key) {
        String value = prefs.getString(key, "");
        return value == null ? "" : value;
    }

    private static double parseDouble(String value) {
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            return 0d;
        }
    }
}
