package com.amperly.app.core.nav;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.car.app.CarContext;

import java.util.Locale;

/**
 * Handoff points shared by the Android Auto screens and the platform.
 *
 * <p>The handset uses Flutter, so the old fragment navigation that used to live here is gone;
 * Android Auto keeps the car-specific intents below.
 */
public final class Navigator {

    private Navigator() {
    }

    /**
     * Hand navigation to the car host. A car app runs inside the host's process and cannot start
     * a phone activity directly: doing so puts Maps on the car display and throws a
     * SecurityException. ACTION_NAVIGATE is the supported car handoff.
     */
    public static void navigateToCar(@NonNull CarContext context, double latitude,
                                     double longitude) {
        String data = String.format(Locale.US, "geo:%.6f,%.6f", latitude, longitude);
        context.startCarApp(new Intent(CarContext.ACTION_NAVIGATE, Uri.parse(data)));
    }

    /** Hand turn-by-turn navigation to the phone's maps application (works with no API key). */
    public static void navigateTo(Context context, double latitude, double longitude, String label) {
        if (context == null) {
            return;
        }
        String query = label != null && !label.isEmpty()
                ? label
                : String.format(Locale.US, "%.5f,%.5f", latitude, longitude);
        // geo: opens a pin, while google.navigation: actually starts turn-by-turn. Prefer the
        // latter for a button called Start navigation, then fall back for other map apps.
        Intent navigation = new Intent(Intent.ACTION_VIEW,
                Uri.parse("google.navigation:q=" + latitude + "," + longitude));
        navigation.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        if (navigation.resolveActivity(context.getPackageManager()) != null) {
            context.startActivity(navigation);
            return;
        }

        Uri geo = Uri.parse("geo:" + latitude + "," + longitude + "?q="
                + Uri.encode(latitude + "," + longitude + "(" + query + ")"));
        Intent intent = new Intent(Intent.ACTION_VIEW, geo);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        if (intent.resolveActivity(context.getPackageManager()) != null) {
            context.startActivity(intent);
            return;
        }
        Intent fallback = new Intent(Intent.ACTION_VIEW,
                Uri.parse("https://www.google.com/maps/search/?api=1&query=" + latitude + "," + longitude));
        fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(fallback);
    }

    /** Masked calling: dial through the platform-provided masked number, never the real one. */
    public static void dial(Context context, String number) {
        if (context == null || number == null || number.trim().isEmpty()) {
            return;
        }
        Intent intent = new Intent(Intent.ACTION_DIAL, Uri.parse("tel:" + number.trim()));
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }
}
