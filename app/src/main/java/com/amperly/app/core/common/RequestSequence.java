package com.amperly.app.core.common;

/**
 * A monotonic request token, so a slow answer can tell whether it is still the newest one.
 *
 * <p>Autocomplete fires a request per paused keystroke. Without a token, the answer for "Kor" can
 * land after the answer for "Koramangala" and replace the newer suggestion list, so the driver sees
 * — and can pick — a place that does not match what is in the field.
 *
 * <p>Deliberately tiny and free of Android so the staleness rule can be unit tested.
 */
public final class RequestSequence {

    private int latest;

    /** Claims the next token; the caller keeps it and compares it when the answer arrives. */
    public synchronized int next() {
        latest += 1;
        return latest;
    }

    /** True when {@code token} is still the most recently claimed one. */
    public synchronized boolean isCurrent(int token) {
        return token == latest;
    }
}
