package com.amperly.app.core.common;

import androidx.annotation.Nullable;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

public final class Formatters {

    private Formatters() {
    }

    public static String money(double amount) {
        return String.format(Locale.US, "₹%.2f", amount);
    }

    public static String moneyShort(double amount) {
        return String.format(Locale.US, "₹%.0f", amount);
    }

    public static String kwh(double value) {
        return String.format(Locale.US, "%.2f kWh", value);
    }

    public static String percent(int value) {
        return value + "%";
    }

    /**
     * A rounded percentage that never claims zero when something did actually happen.
     *
     * <p>Utilization is a small number for a single-port host — two hours of charging across a
     * month of bookable hours is under 1% — and {@code %.0f} reported that as "0%", which reads
     * as broken rather than as tiny.
     */
    public static String percent(double value) {
        if (value <= 0.0) {
            return "0%";
        }
        if (value < 1.0) {
            return "<1%";
        }
        return String.format(Locale.US, "%.0f%%", value);
    }

    public static String minutes(int totalMinutes) {
        if (totalMinutes < 60) {
            return totalMinutes + " min";
        }
        int hours = totalMinutes / 60;
        int minutes = totalMinutes % 60;
        return minutes == 0 ? hours + " h" : hours + " h " + minutes + " min";
    }

    public static String clock(long timeMs) {
        return new SimpleDateFormat("h:mm a", Locale.getDefault()).format(new Date(timeMs));
    }

    public static String dateTime(long timeMs) {
        return new SimpleDateFormat("d MMM, h:mm a", Locale.getDefault()).format(new Date(timeMs));
    }

    public static String dayAndSlot(long startMs, long endMs) {
        Calendar start = Calendar.getInstance();
        start.setTimeInMillis(startMs);
        Calendar today = Calendar.getInstance();
        String day;
        if (sameDay(start, today)) {
            day = "Today";
        } else {
            Calendar tomorrow = Calendar.getInstance();
            tomorrow.add(Calendar.DAY_OF_YEAR, 1);
            day = sameDay(start, tomorrow) ? "Tomorrow"
                    : new SimpleDateFormat("EEE d MMM", Locale.getDefault()).format(new Date(startMs));
        }
        return day + ", " + clock(startMs) + " – " + clock(endMs);
    }

    private static boolean sameDay(Calendar a, Calendar b) {
        return a.get(Calendar.YEAR) == b.get(Calendar.YEAR)
                && a.get(Calendar.DAY_OF_YEAR) == b.get(Calendar.DAY_OF_YEAR);
    }

    /** Honest freshness label: never claim live hardware data we do not have. */
    public static String agoFromNow(long thenMs) {
        long now = System.currentTimeMillis();
        long diff = Math.max(0, now - thenMs);
        long minutes = TimeUnit.MILLISECONDS.toMinutes(diff);
        if (minutes < 1) {
            return "just now";
        }
        if (minutes < 60) {
            return minutes + (minutes == 1 ? " minute ago" : " minutes ago");
        }
        long hours = TimeUnit.MILLISECONDS.toHours(diff);
        if (hours < 24) {
            return hours + (hours == 1 ? " hour ago" : " hours ago");
        }
        long days = TimeUnit.MILLISECONDS.toDays(diff);
        return days + (days == 1 ? " day ago" : " days ago");
    }

    public static String minutesFromMidnight(int minutesFromMidnight) {
        int hours = (minutesFromMidnight / 60) % 24;
        int minutes = minutesFromMidnight % 60;
        return String.format(Locale.US, "%02d:%02d", hours, minutes);
    }

    // ------------------------------------------------------- stored codes
    // The values in the database are API codes. They are fine to store and to compare, but they
    // are not what a driver reads on a screen: "TYPE_2_AC" is "Type 2 AC". These four turn one
    // into the other in a single place, so a new screen cannot accidentally print the code.

    /** One connector code, as people say it. */
    public static String connectorType(@Nullable String stored) {
        if (stored == null || stored.trim().isEmpty()) {
            return "";
        }
        String code = stored.trim().toUpperCase(Locale.US);
        if (code.equals("TYPE_2_AC") || code.equals("TYPE2_AC")) {
            return "Type 2 AC";
        }
        if (code.equals("TYPE_2") || code.equals("TYPE2")) {
            return "Type 2";
        }
        if (code.startsWith("CCS")) {
            return "CCS2";
        }
        if (code.equals("CHADEMO")) {
            return "CHAdeMO";
        }
        if (code.equals("GB_T") || code.equals("GBT")) {
            return "GB/T";
        }
        return humanize(stored);
    }

    /** A comma-separated connector list, each code expanded and joined back together. */
    public static String connectorTypes(@Nullable String storedCsv) {
        if (storedCsv == null || storedCsv.trim().isEmpty()) {
            return "";
        }
        StringBuilder out = new StringBuilder();
        for (String part : storedCsv.split(",")) {
            String label = connectorType(part);
            if (label.isEmpty()) {
                continue;
            }
            if (out.length() > 0) {
                out.append(", ");
            }
            out.append(label);
        }
        return out.toString();
    }

    /** A station's review state, in the words a host or admin would use. */
    public static String approvalStatus(@Nullable String stored) {
        if (stored == null || stored.trim().isEmpty()) {
            return "";
        }
        String code = stored.trim().toUpperCase(Locale.US);
        if (code.equals("PENDING")) {
            return "Pending review";
        }
        if (code.equals("APPROVED")) {
            return "Approved";
        }
        if (code.equals("REJECTED")) {
            return "Rejected";
        }
        return humanize(stored);
    }

    /** How a meter was verified, without leaking "LEVEL_1" onto the screen. */
    public static String verificationLevel(@Nullable String stored) {
        if (stored == null || stored.trim().isEmpty()) {
            return "No verified meter";
        }
        String code = stored.trim().toUpperCase(Locale.US);
        if (code.startsWith("LEVEL_1")) {
            return "Level 1 meter";
        }
        if (code.startsWith("LEVEL_2")) {
            return "Level 2 meter";
        }
        if (code.startsWith("LEVEL_3") || code.equals("NONE")) {
            return "No verified meter";
        }
        return humanize(stored);
    }

    /** A port's state, as a person reads it. */
    public static String portStatus(@Nullable String stored) {
        if (stored == null || stored.trim().isEmpty()) {
            return "";
        }
        String code = stored.trim().toUpperCase(Locale.US);
        if (code.equals("AVAILABLE") || code.equals("FREE")) {
            return "Available";
        }
        if (code.equals("IN_USE") || code.equals("OCCUPIED") || code.equals("CHARGING")) {
            return "In use";
        }
        if (code.equals("BLOCKED")) {
            return "Blocked";
        }
        if (code.equals("OFFLINE")) {
            return "Offline";
        }
        return humanize(stored);
    }

    /** A reservation or session state, in sentence case. */
    public static String bookingStatus(@Nullable String stored) {
        if (stored == null || stored.trim().isEmpty()) {
            return "";
        }
        String code = stored.trim().toUpperCase(Locale.US);
        if (code.equals("CHECKED_IN")) {
            return "Checked in";
        }
        if (code.equals("RESERVED")) {
            return "Reserved";
        }
        if (code.equals("CHARGING")) {
            return "Charging";
        }
        if (code.equals("COMPLETED")) {
            return "Completed";
        }
        if (code.equals("CANCELLED")) {
            return "Cancelled";
        }
        if (code.equals("EXPIRED")) {
            return "Expired";
        }
        if (code.equals("DISPUTED")) {
            return "Disputed";
        }
        if (code.equals("REFUNDED")) {
            return "Refunded";
        }
        return humanize(stored);
    }

    /** "SOME_CODE" becomes "Some code", the fallback for a value with no written label yet. */
    private static String humanize(String stored) {
        String words = stored.trim().replace('_', ' ').toLowerCase(Locale.US);
        if (words.isEmpty()) {
            return "";
        }
        return Character.toUpperCase(words.charAt(0)) + words.substring(1);
    }
}
