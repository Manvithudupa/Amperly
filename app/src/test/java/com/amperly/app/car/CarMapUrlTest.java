package com.amperly.app.car;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/** Geoapify rejects the marker parameters if their case or size format is wrong. */
public class CarMapUrlTest {

    @Test
    public void aMarkerUsesTheAcceptedLowercaseNumericForm() {
        String marker = CarMapUrl.marker(12.9, 74.85, "0F5C4D");

        assertEquals("lonlat:74.850000,12.900000;color:%230f5c4d;size:42", marker);
        assertTrue(marker.endsWith(";size:42"));
        assertFalse(marker.contains("size:medium"));
    }

    @Test
    public void upperCaseColoursAreLowercased() {
        assertEquals(CarMapUrl.marker(12.9, 74.85, "0f5c4d"),
                CarMapUrl.marker(12.9, 74.85, "0F5C4D"));
    }

    @Test
    public void coordinatesAreNotLocalised() {
        assertEquals("74.850000,12.900000",
                CarMapUrl.coordinate(74.85) + "," + CarMapUrl.coordinate(12.9));
    }
}
