package com.amperly.app.ui;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.EditText;
import android.widget.ScrollView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.core.widget.NestedScrollView;
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

    // ------------------------------------------------------------------ keyboard

    /**
     * Keeps the keyboard from covering the field being typed in.
     *
     * <p>Every editable field under {@code root} scrolls itself into view when it takes focus, so a
     * field tapped near the bottom of a long form is never left behind the keyboard. Screens call
     * this once with their inflated root instead of wiring each field by hand.
     */
    public static void keepFieldsVisible(@Nullable View root) {
        if (root == null) {
            return;
        }
        if (root instanceof EditText) {
            keepVisibleOnFocus(root);
            return;
        }
        if (!(root instanceof ViewGroup)) {
            return;
        }
        ViewGroup group = (ViewGroup) root;
        for (int i = 0; i < group.getChildCount(); i++) {
            keepFieldsVisible(group.getChildAt(i));
        }
    }

    /** Makes one field scroll into view when it takes focus. */
    public static void keepVisibleOnFocus(@Nullable View field) {
        keepVisibleOnFocus(field, null);
    }

    /**
     * The same, for a field that already has its own focus handling: {@code also} is called first,
     * so a screen keeps the behaviour it had and only gains the scroll.
     */
    public static void keepVisibleOnFocus(@Nullable View field,
                                          @Nullable View.OnFocusChangeListener also) {
        if (field == null) {
            return;
        }
        field.setOnFocusChangeListener((view, hasFocus) -> {
            if (also != null) {
                also.onFocusChange(view, hasFocus);
            }
            if (hasFocus) {
                scrollIntoView(view);
            }
        });
    }

    /**
     * Makes a dialog's window shrink for the keyboard, so the fields inside it are never buried.
     * A dialog is its own window and does not inherit the shell's inset handling.
     */
    public static void resizeForKeyboard(@Nullable android.app.Dialog dialog) {
        if (dialog == null || dialog.getWindow() == null) {
            return;
        }
        dialog.getWindow().setSoftInputMode(
                android.view.WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
    }

    /**
     * Scrolls the nearest scrolling ancestor just far enough that {@code field} — plus a little
     * breathing room and the space its error/helper text needs — sits above the keyboard.
     *
     * <p>Deferred by one frame so the field has been laid out and the keyboard inset has already
     * shrunk the scroll view; scrolling earlier would leave the field where it was.
     */
    public static void scrollIntoView(@Nullable View field) {
        if (field == null) {
            return;
        }
        final View target = field;
        target.post(() -> scrollIntoViewNow(target));
    }

    private static void scrollIntoViewNow(View field) {
        if (!field.isShown() || field.getHeight() == 0) {
            return;
        }
        int extra = dp(field.getContext(), 20);
        ViewGroup scroller = scrollingAncestor(field);
        if (scroller == null) {
            // No scroll container: ask the hierarchy directly, which is all that can be done.
            field.requestRectangleOnScreen(
                    new Rect(0, 0, field.getWidth(), field.getHeight() + extra), true);
            return;
        }

        Rect rect = new Rect(0, 0, field.getWidth(), field.getHeight());
        scroller.offsetDescendantRectToMyCoords(field, rect);

        int top = scroller.getPaddingTop();
        int bottom = scroller.getHeight() - scroller.getPaddingBottom();
        if (rect.bottom + extra > bottom) {
            smoothScrollBy(scroller, rect.bottom + extra - bottom);
        } else if (rect.top - extra < top) {
            smoothScrollBy(scroller, rect.top - extra - top);
        }
    }

    private static void smoothScrollBy(View scroller, int dy) {
        if (dy == 0) {
            return;
        }
        if (scroller instanceof ScrollView) {
            ((ScrollView) scroller).smoothScrollBy(0, dy);
        } else if (scroller instanceof NestedScrollView) {
            ((NestedScrollView) scroller).smoothScrollBy(0, dy);
        } else {
            scroller.scrollBy(0, dy);
        }
    }

    /** The first {@link ScrollView} / {@link NestedScrollView} above a view, if there is one. */
    @Nullable
    private static ViewGroup scrollingAncestor(View view) {
        ViewParent parent = view.getParent();
        while (parent instanceof View) {
            if (parent instanceof ScrollView || parent instanceof NestedScrollView) {
                return (ViewGroup) parent;
            }
            parent = parent.getParent();
        }
        return null;
    }

    private static int dp(@Nullable Context context, int value) {
        if (context == null) {
            return value;
        }
        return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, value,
                context.getResources().getDisplayMetrics()));
    }
}
