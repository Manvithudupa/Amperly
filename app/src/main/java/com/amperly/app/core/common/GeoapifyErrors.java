package com.amperly.app.core.common;

import androidx.annotation.NonNull;

/**
 * Describes a failed Geoapify HTTP call in technical terms.
 *
 * <p>The text exists for the log and for {@link UserMessages}, which turns it into the one sentence
 * a driver sees. It is deliberately never shown as-is: it names HTTP codes, which mean nothing on
 * the road, and it names the key, which must not surface in a screenshot or a bug report.
 *
 * <p>Pure and public so the mapping can be unit tested without a network.
 */
public final class GeoapifyErrors {

    private GeoapifyErrors() {
    }

    /** Technical description of a failed Geoapify response. */
    @NonNull
    public static String httpFailure(int code) {
        if (code == 401 || code == 403) {
            return "Geoapify rejected the API key (HTTP " + code + ").";
        }
        if (code == 429) {
            return "Geoapify rate limit or daily credits exhausted (HTTP 429).";
        }
        if (code == 400) {
            return "Geoapify rejected the request as invalid (HTTP 400, bad request).";
        }
        if (code >= 500) {
            return "Geoapify is unavailable (HTTP " + code + ").";
        }
        return "Geoapify returned HTTP " + code + ".";
    }
}
