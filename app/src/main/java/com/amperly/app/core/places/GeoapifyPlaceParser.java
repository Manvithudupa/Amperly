package com.amperly.app.core.places;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Reads Geoapify's GeoJSON place responses.
 *
 * <p>Kept free of Android and of the network so it can be unit tested against a captured payload.
 * Every field is treated as optional: Geoapify omits what it does not know, and a missing
 * {@code address_line2} must show the formatted address rather than a blank row.
 *
 * <p>Coordinate order is the one thing that is easy to get backwards. Geoapify's geocoding response
 * carries {@code properties.lat} / {@code properties.lon} and, in the geometry, GeoJSON order
 * ({@code [lon, lat]}). {@link PlacesAutocomplete.Selection} exposes latitude first, like every
 * other coordinate in the app.
 */
public final class GeoapifyPlaceParser {

    private GeoapifyPlaceParser() {
    }

    /**
     * The place suggestions in a Geoapify autocomplete response, in the order Geoapify ranked them.
     *
     * @param limit the maximum number of suggestions to return (the free plan is asked for 5).
     */
    @NonNull
    public static List<PlacesAutocomplete.Selection> parseSuggestions(@Nullable String json, int limit) {
        if (json == null || json.trim().isEmpty()) {
            return Collections.emptyList();
        }
        JsonArray features = features(json);
        if (features == null) {
            return Collections.emptyList();
        }
        List<PlacesAutocomplete.Selection> selections = new ArrayList<>();
        int max = limit <= 0 ? 5 : limit;
        for (JsonElement element : features) {
            if (!element.isJsonObject()) {
                continue;
            }
            PlacesAutocomplete.Selection selection = toSelection(element.getAsJsonObject());
            if (selection == null) {
                continue;
            }
            selections.add(selection);
            if (selections.size() >= max) {
                break;
            }
        }
        return selections;
    }

    /** The first usable match, or null when the response has none. Used by the forward lookup. */
    @Nullable
    public static PlacesAutocomplete.Selection parseFirstMatch(@Nullable String json) {
        List<PlacesAutocomplete.Selection> matches = parseSuggestions(json, 1);
        return matches.isEmpty() ? null : matches.get(0);
    }

    /** {@code features[0].properties.formatted}, or an empty string when there is none. */
    @NonNull
    public static String parseFirstFormattedAddress(@Nullable String json) {
        if (json == null || json.trim().isEmpty()) {
            return "";
        }
        JsonArray features = features(json);
        if (features == null || features.size() == 0) {
            return "";
        }
        JsonElement first = features.get(0);
        if (!first.isJsonObject()) {
            return "";
        }
        JsonObject properties = object(first.getAsJsonObject(), "properties");
        if (properties == null) {
            return "";
        }
        return string(properties, "formatted");
    }

    @Nullable
    private static PlacesAutocomplete.Selection toSelection(@NonNull JsonObject feature) {
        JsonObject properties = object(feature, "properties");
        if (properties == null) {
            return null;
        }
        Double latitude = number(properties, "lat");
        Double longitude = number(properties, "lon");
        if (latitude == null || longitude == null) {
            // Fall back to the geometry, whose coordinates are GeoJSON order: [lon, lat].
            JsonObject geometry = object(feature, "geometry");
            JsonArray coordinates = geometry == null ? null : array(geometry, "coordinates");
            if (coordinates != null && coordinates.size() >= 2
                    && coordinates.get(0).isJsonPrimitive()
                    && coordinates.get(1).isJsonPrimitive()) {
                longitude = coordinates.get(0).getAsDouble();
                latitude = coordinates.get(1).getAsDouble();
            }
        }
        if (latitude == null || longitude == null) {
            return null;
        }

        String formatted = string(properties, "formatted");
        String line1 = string(properties, "address_line1");
        String line2 = string(properties, "address_line2");
        String label = !line1.isEmpty() ? line1 : !formatted.isEmpty() ? formatted : line2;
        String address = !formatted.isEmpty() ? formatted : !line2.isEmpty() ? line2 : label;
        if (label.isEmpty()) {
            return null;
        }
        return new PlacesAutocomplete.Selection(string(properties, "place_id"), label, address,
                latitude, longitude);
    }

    @Nullable
    private static JsonArray features(@NonNull String json) {
        try {
            JsonElement parsed = JsonParser.parseString(json);
            if (!parsed.isJsonObject()) {
                return null;
            }
            return array(parsed.getAsJsonObject(), "features");
        } catch (RuntimeException e) {
            // A truncated or non-JSON body is a failed search, not a crash on the drawing thread.
            return null;
        }
    }

    @Nullable
    private static JsonObject object(@NonNull JsonObject parent, @NonNull String key) {
        return parent.has(key) && parent.get(key).isJsonObject()
                ? parent.getAsJsonObject(key) : null;
    }

    @Nullable
    private static JsonArray array(@NonNull JsonObject parent, @NonNull String key) {
        return parent.has(key) && parent.get(key).isJsonArray()
                ? parent.getAsJsonArray(key) : null;
    }

    @NonNull
    private static String string(@NonNull JsonObject parent, @NonNull String key) {
        if (!parent.has(key) || parent.get(key).isJsonNull()) {
            return "";
        }
        try {
            JsonElement value = parent.get(key);
            return value.isJsonPrimitive() ? value.getAsString() : "";
        } catch (RuntimeException e) {
            return "";
        }
    }

    @Nullable
    private static Double number(@NonNull JsonObject parent, @NonNull String key) {
        if (!parent.has(key) || parent.get(key).isJsonNull()) {
            return null;
        }
        try {
            JsonElement value = parent.get(key);
            return value.isJsonPrimitive() ? value.getAsDouble() : null;
        } catch (RuntimeException e) {
            return null;
        }
    }
}
