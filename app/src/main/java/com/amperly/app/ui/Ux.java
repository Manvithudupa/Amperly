package com.amperly.app.ui;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.google.android.material.snackbar.Snackbar;

/**
 * Shared, themed feedback.
 *
 * <p>A stock {@link Toast} cannot be themed, so every message the app already showed through
 * {@code toast(...)} is drawn as a {@link Snackbar} on the screen's own surface instead. The
 * public signatures are unchanged, so all existing call sites improved at once; a Toast is still
 * the fallback for the rare case where there is no attached view to anchor a Snackbar to.
 *
 * <p>{@link #error} and {@link #success} carry the intent of the message, so a failure looks like a
 * failure and a confirmation looks like a confirmation, in light and dark mode alike.
 */
public final class Ux {

    /** How a message should read: neutral, a confirmation, or a failure. */
    private enum Tone {
        INFO,
        SUCCESS,
        ERROR
    }

    private Ux() {
    }

    public static void toast(@Nullable Fragment fragment, String message) {
        info(fragment, message);
    }

    public static void toast(@Nullable Context context, String message) {
        info(context, message);
    }

    public static void snack(@Nullable View anchor, String message) {
        show(anchor, message, Tone.INFO);
    }

    public static void info(@Nullable Fragment fragment, String message) {
        show(fragment == null ? null : fragment.getView(), message, Tone.INFO);
    }

    public static void info(@Nullable Context context, String message) {
        show(contentView(context), message, Tone.INFO);
    }

    public static void success(@Nullable Fragment fragment, String message) {
        show(fragment == null ? null : fragment.getView(), message, Tone.SUCCESS);
    }

    public static void success(@Nullable View view, String message) {
        show(view, message, Tone.SUCCESS);
    }

    public static void success(@Nullable Context context, String message) {
        show(contentView(context), message, Tone.SUCCESS);
    }

    public static void error(@Nullable Fragment fragment, String message) {
        show(fragment == null ? null : fragment.getView(), message, Tone.ERROR);
    }

    public static void error(@Nullable Context context, String message) {
        show(contentView(context), message, Tone.ERROR);
    }

    public static void error(@Nullable View view, String message) {
        show(view, message, Tone.ERROR);
    }

    /**
     * Shows one message. A Snackbar is used whenever the view is on screen, so the message is
     * themed and anchored above the bottom navigation bar rather than floating over it.
     */
    private static void show(@Nullable View view, @Nullable String message, Tone tone) {
        if (message == null) {
            return;
        }
        Context context = view == null ? null : view.getContext();
        if (view != null && context != null && view.isAttachedToWindow()) {
            Snackbar bar = Snackbar.make(view, message, Snackbar.LENGTH_LONG);
            View anchor = bottomNavigationAnchor(view);
            if (anchor != null) {
                bar.setAnchorView(anchor);
            }
            applyTone(bar, context, tone);
            bar.show();
            return;
        }
        if (context == null) {
            return;
        }
        Toast.makeText(context, message, Toast.LENGTH_LONG).show();
    }

    private static void applyTone(Snackbar bar, Context context, Tone tone) {
        if (tone == Tone.ERROR) {
            bar.setBackgroundTint(ContextCompat.getColor(context, R.color.amp_error_tint));
            bar.setTextColor(ContextCompat.getColor(context, R.color.amp_on_error_container));
        } else if (tone == Tone.SUCCESS) {
            bar.setBackgroundTint(ContextCompat.getColor(context, R.color.amp_primary_tint));
            bar.setTextColor(ContextCompat.getColor(context, R.color.amp_on_primary_tint));
        }
    }

    /**
     * The shell's bottom navigation bar, when it is showing. Snackbars anchor above it instead of
     * covering the tabs.
     */
    @Nullable
    private static View bottomNavigationAnchor(@Nullable View view) {
        if (view == null) {
            return null;
        }
        View root = view.getRootView();
        if (root == null) {
            return null;
        }
        View nav = root.findViewById(R.id.bottomNavigationView);
        return nav != null && nav.getVisibility() == View.VISIBLE ? nav : null;
    }

    /** The activity's content view, for the context-only overloads. */
    @Nullable
    private static View contentView(@Nullable Context context) {
        if (context instanceof Activity) {
            return ((Activity) context).findViewById(android.R.id.content);
        }
        return null;
    }

    public static String formatMoney(double amount) {
        return com.amperly.app.core.common.Formatters.money(amount);
    }
}
