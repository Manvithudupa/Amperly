package com.amperly.app;

import com.amperly.app.core.places.GeoapifyPlaceParser;
import com.amperly.app.core.places.PlacesAutocomplete;

import org.junit.Test;

import java.util.List;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

/**
 * The Geoapify place parsers.
 *
 * <p>Geoapify answers in GeoJSON, where a place's coordinate pair is longitude-first, while the app
 * carries latitude first everywhere. The parsers also have to survive the fields Geoapify omits:
 * a missing {@code address_line2} must not produce a blank suggestion row.
 */
public class GeoapifyPlaceParserTest {

    private static final String AUTOCOMPLETE = "{"
            + "\"type\":\"FeatureCollection\","
            + "\"features\":["
            + "{\"type\":\"Feature\",\"properties\":{"
            + "\"formatted\":\"Forum Mall, Hosur Road, Bengaluru, Karnataka 560029, India\","
            + "\"address_line1\":\"Forum Mall\","
            + "\"address_line2\":\"Hosur Road, Bengaluru, Karnataka 560029, India\","
            + "\"place_id\":\"5123a2b7f2c94b1e9b0d3f4a5c6d7e8f\","
            + "\"lat\":12.9345,\"lon\":77.6101},"
            + "\"geometry\":{\"type\":\"Point\",\"coordinates\":[77.6101,12.9345]}},"
            + "{\"type\":\"Feature\",\"properties\":{"
            + "\"formatted\":\"Koramangala, Bengaluru, Karnataka, India\","
            + "\"place_id\":\"9f8e7d6c5b4a39281706f5e4d3c2b1a0\"},"
            + "\"geometry\":{\"type\":\"Point\",\"coordinates\":[77.6245,12.9352]}},"
            + "{\"type\":\"Feature\",\"properties\":{\"place_id\":\"no-coordinates\"}}"
            + "]}";

    @Test
    public void readsPlaceIdLabelAddressAndCoordinates() {
        List<PlacesAutocomplete.Selection> suggestions =
                GeoapifyPlaceParser.parseSuggestions(AUTOCOMPLETE, 5);
        assertEquals(2, suggestions.size());

        PlacesAutocomplete.Selection first = suggestions.get(0);
        assertEquals("5123a2b7f2c94b1e9b0d3f4a5c6d7e8f", first.getPlaceId());
        assertEquals("Forum Mall", first.getLabel());
        assertEquals("Forum Mall, Hosur Road, Bengaluru, Karnataka 560029, India",
                first.getAddress());
        assertEquals(12.9345, first.getLatitude(), 1e-6);
        assertEquals(77.6101, first.getLongitude(), 1e-6);
    }

    @Test
    public void fallsBackToTheGeometryWhenPropertiesCarryNoCoordinates() {
        List<PlacesAutocomplete.Selection> suggestions =
                GeoapifyPlaceParser.parseSuggestions(AUTOCOMPLETE, 5);
        PlacesAutocomplete.Selection second = suggestions.get(1);
        assertEquals("9f8e7d6c5b4a39281706f5e4d3c2b1a0", second.getPlaceId());
        // The label falls back to the formatted address when there is no address_line1.
        assertEquals("Koramangala, Bengaluru, Karnataka, India", second.getLabel());
        // Geometry coordinates are [lon, lat]; the selection is latitude first.
        assertEquals(12.9352, second.getLatitude(), 1e-6);
        assertEquals(77.6245, second.getLongitude(), 1e-6);
    }

    @Test
    public void aFeatureWithoutCoordinatesIsSkipped() {
        List<PlacesAutocomplete.Selection> suggestions =
                GeoapifyPlaceParser.parseSuggestions(AUTOCOMPLETE, 5);
        for (PlacesAutocomplete.Selection selection : suggestions) {
            assertTrue(selection.getPlaceId().length() > 0);
            assertTrue("a skipped feature must not appear as a zero coordinate",
                    selection.getLatitude() != 0 || selection.getLongitude() != 0);
        }
        assertEquals(2, suggestions.size());
    }

    @Test
    public void theLimitIsRespected() {
        assertEquals(1, GeoapifyPlaceParser.parseSuggestions(AUTOCOMPLETE, 1).size());
        assertEquals(2, GeoapifyPlaceParser.parseSuggestions(AUTOCOMPLETE, 9).size());
    }

    @Test
    public void malformedJsonIsAnEmptyResultRatherThanACrash() {
        assertTrue(GeoapifyPlaceParser.parseSuggestions("{not json", 5).isEmpty());
        assertTrue(GeoapifyPlaceParser.parseSuggestions(null, 5).isEmpty());
        assertTrue(GeoapifyPlaceParser.parseSuggestions("[]", 5).isEmpty());
        assertNull(GeoapifyPlaceParser.parseFirstMatch("{\"features\":[]}"));
    }

    @Test
    public void reverseGeocodingReadsTheFirstFormattedAddress() {
        String reverse = "{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\","
                + "\"properties\":{\"formatted\":\"12, MG Road, Bengaluru, Karnataka 560001, India\","
                + "\"lat\":12.9748,\"lon\":77.6072}}]}";
        assertEquals("12, MG Road, Bengaluru, Karnataka 560001, India",
                GeoapifyPlaceParser.parseFirstFormattedAddress(reverse));
        assertEquals("", GeoapifyPlaceParser.parseFirstFormattedAddress("{\"features\":[]}"));
        assertEquals("", GeoapifyPlaceParser.parseFirstFormattedAddress(""));
    }
}
