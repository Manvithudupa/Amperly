package com.amperly.app;

import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.entity.Vehicle;

import org.junit.After;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

/**
 * The shared plan state.
 *
 * <p>The battery figure is per vehicle: with a garage behind one account, switching from a car
 * at 80% to a van at 20% must not keep planning the car's range. A newly selected vehicle
 * without a stored reading starts unknown rather than inheriting the previous figure.
 */
public class AppStateStoreTest {

    private final AppStateStore store = AppStateStore.get();

    @After
    public void tearDown() {
        store.reset();
    }

    @Test
    public void switchingVehicleDropsThePreviousBatteryReading() {
        store.reset();

        store.applyStoredSoc("car-1", 80);
        assertEquals(80, store.getCurrentSoc());

        // The driver corrects the estimate while in car-1; that correction is authoritative.
        store.applySocCorrection(80, 75);
        assertTrue(store.isSocAuthoritative());
        assertEquals(75, store.getCurrentSoc());

        // A switch must not carry either figure into the other vehicle.
        store.applyStoredSoc("van-2", -1);
        assertFalse(store.isSocAuthoritative());
        assertEquals(-1, store.getCurrentSoc());

        store.applyStoredSoc("van-2", 20);
        assertEquals(20, store.getCurrentSoc());

        // Returning to the first vehicle restores its own stored reading.
        store.applyStoredSoc("car-1", 80);
        assertEquals(80, store.getCurrentSoc());

        // Reloading the same vehicle does not wipe a figure merely because the call repeated.
        store.applySocCorrection(80, 78);
        store.applyStoredSoc("car-1", 80);
        assertEquals(78, store.getCurrentSoc());
    }

    @Test
    public void resetForgetsTheVehicleOfTheAccountThatLeft() {
        store.reset();
        Vehicle vehicle = new Vehicle("veh_1", "user_1", "Tata", "Nexon EV", "Max", 2023, 40.5,
                "CCS_2_DC", 7.2, 30.0, 6.5, 96.0, 0.0, 15, 80, "KA09EV1234", true);

        store.setUserId("user_1");
        store.setVehicle(vehicle);
        store.applyStoredSoc("veh_1", 64);
        assertEquals(64, store.getCurrentSoc());

        store.reset();

        assertNull(store.getVehicle());
        assertEquals("", store.getUserId());
        assertEquals(-1, store.getCurrentSoc());
    }
}
