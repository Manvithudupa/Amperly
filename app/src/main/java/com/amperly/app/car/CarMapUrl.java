package com.amperly.app.car;

import androidx.annotation.NonNull;

import java.util.Locale;

/**
 * The query fragments for the Geoapify static map.
 *
 * <p>Geoapify validates marker values strictly. Its accepted colour form is lower-case hex and
 * its accepted size is numeric: {@code size:medium} and upper-case hex both produce HTTP 400 and
 * a black map. Keeping the format here makes that rule testable without a device.
 */
public final class CarMapUrl {

    private CarMapUrl() {
    }

    /** One marker value, without the leading {@code &marker=} or {@code |}. */
    @NonNull
    public static String marker(double latitude, double longitude, @NonNull String color) {
        return "lonlat:" + coordinate(longitude) + "," + coordinate(latitude)
                + ";color:%23" + color.toLowerCase(Locale.US) + ";size:42";
    }

    /** Six decimal places is about 0.1 m, and is locale-independent. */
    @NonNull
    public static String coordinate(double value) {
        return String.format(Locale.US, "%.6f", value);
    }
}
