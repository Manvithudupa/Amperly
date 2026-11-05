package com.amperly.app.car;

import org.junit.Test;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

/** The car's row limits are a safety rule: a moving driver must not scroll a wall of text. */
public class CarLimitsTest {

    @Test
    public void theHostLimitCapsTheScreensDesiredRows() {
        assertEquals(4, CarLimits.listLimit(8, 4));
    }

    @Test
    public void aSmallerHostLimitWins() {
        assertEquals(3, CarLimits.listLimit(3, 4));
    }

    @Test
    public void anUnknownHostLimitFallsBackToTheDesiredRows() {
        assertEquals(4, CarLimits.listLimit(-1, 4));
        assertEquals(4, CarLimits.listLimit(0, 4));
    }

    @Test
    public void theMainPaneNeverExceedsFourRows() {
        assertTrue(CarLimits.listLimit(20, CarLimits.MAIN_PANE_MAX_ROWS)
                <= CarLimits.MAIN_PANE_MAX_ROWS);
    }

    @Test
    public void mapWithContentIsOnlyUsedOnApiSevenAndAbove() {
        assertFalse(CarLimits.supportsMapWithContent(6));
        assertTrue(CarLimits.supportsMapWithContent(7));
        assertTrue(CarLimits.supportsMapWithContent(8));
    }

    @Test
    public void theBatteryPickerHasTheEightDashboardChoices() {
        assertArrayEquals(new int[]{10, 20, 30, 40, 50, 60, 80, 90},
                CarLimits.batteryOptions());
    }

    @Test
    public void batteryOptionsCannotBeMutatedByCallers() {
        int[] copy = CarLimits.batteryOptions();
        copy[0] = 99;
        assertEquals(10, CarLimits.batteryOptions()[0]);
    }
}
