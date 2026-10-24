package com.amperly.app.core.map;

import androidx.annotation.NonNull;

import com.amperly.app.data.local.entity.ChargerStation;

import java.util.Locale;

/**
 * Maps a user-registered {@link ChargerStation} onto what a map marker should look like.
 *
 * <p>The hosted chargers are the product, so the marker has to answer three questions at a glance:
 * is this one usable by my car, is it available, and does it charge by a verified meter (so paid
 * billing works)? Colour alone is not an answer — the marker's tap card carries the same information
 * in text for colour-blind drivers and for the car display.
 *
 * <p>The hue is kept as a bare number so it stays testable and so the same value can drive both the
 * circle colour and any future legend. No host phone number, email or account id is ever placed in
 * marker text; only the public marketplace facts.
 */
public final class StationMarkerModel {

    /** Hue of the charger the planner recommends or the driver selected. */
    private static final float HUE_ORANGE = 30f;
    /** Hue of a charger the host has paused. */
    private static final float HUE_VIOLET = 270f;
    /** Hue of a charger with no verified meter (discovery only). */
    private static final float HUE_YELLOW = 60f;
    /** Hue of a DC-capable charger. */
    private static final float HUE_GREEN = 120f;
    /** Hue of an AC-only charger. */
    private static final float HUE_AZURE = 210f;

    private StationMarkerModel() {
    }

    /**
     * The marker hue. Recommended/selected chargers and incompatible or unverified ones are pulled
     * apart so the map reads without consulting the legend.
     */
    public static float hue(@NonNull ChargerStation station, boolean highlighted) {
        if (highlighted) {
            return HUE_ORANGE;
        }
        if (station.isPaused()) {
            return HUE_VIOLET;
        }
        if (!station.supportsPaidEnergyBilling()) {
            // No verified meter: discovery only, never a paid energy session.
            return HUE_YELLOW;
        }
        if (station.isDcCapable()) {
            return HUE_GREEN;
        }
        return HUE_AZURE;
    }

    /**
     * The marker colour as an ARGB int for the MapLibre circle layer.
     *
     * <p>Saturation and brightness are fixed so every marker reads equally strongly on the pale
     * basemap; only the hue carries meaning.
     */
    public static int color(@NonNull ChargerStation station, boolean highlighted) {
        return argbFromHue(hue(station, highlighted), 0.85f, 0.95f);
    }

    /**
     * HSV to ARGB.
     *
     * <p>Implemented here rather than through {@code android.graphics.Color} so marker styling can
     * be unit tested on a plain JVM, where the Android framework classes are stubs. The maths is
     * the standard HSV sector conversion and matches {@code Color.HSVToColor}.
     */
    public static int argbFromHue(float hue, float saturation, float value) {
        float h = ((hue % 360f) + 360f) % 360f / 60f;
        float s = Math.max(0f, Math.min(1f, saturation));
        float v = Math.max(0f, Math.min(1f, value));
        int sector = (int) Math.floor(h);
        float f = h - sector;
        float p = v * (1f - s);
        float q = v * (1f - s * f);
        float t = v * (1f - s * (1f - f));
        float r;
        float g;
        float b;
        switch (sector % 6) {
            case 0:
                r = v;
                g = t;
                b = p;
                break;
            case 1:
                r = q;
                g = v;
                b = p;
                break;
            case 2:
                r = p;
                g = v;
                b = t;
                break;
            case 3:
                r = p;
                g = q;
                b = v;
                break;
            case 4:
                r = t;
                g = p;
                b = v;
                break;
            default:
                r = v;
                g = p;
                b = q;
                break;
        }
        return 0xFF000000
                | (Math.round(r * 255f) << 16)
                | (Math.round(g * 255f) << 8)
                | Math.round(b * 255f);
    }

    /** One line of public facts shown under the station name when its marker is tapped. */
    @NonNull
    public static String snippet(@NonNull ChargerStation station) {
        StringBuilder builder = new StringBuilder();
        String connectors = com.amperly.app.core.common.Formatters
                .connectorTypes(station.getConnectorTypes());
        builder.append(connectors.isEmpty() ? "Connector not published" : connectors);
        builder.append(" · ").append(String.format(Locale.US, "%.1f", station.getMaxPowerKw()))
                .append(" kW");
        builder.append(" · ").append(station.getPortCount()).append(" port")
                .append(station.getPortCount() == 1 ? "" : "s");
        builder.append("\n").append(supportsBillingLabel(station));
        return builder.toString();
    }

    /** A plain-language meter label, honest about whether paid billing applies. */
    @NonNull
    public static String supportsBillingLabel(@NonNull ChargerStation station) {
        if (!station.supportsPaidEnergyBilling()) {
            return "No verified meter — discovery only, no automatic billing";
        }
        return "Verified meter — paid energy session available";
    }
}
