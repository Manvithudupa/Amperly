package com.amperly.app.core.nav;

import android.os.Bundle;

import androidx.annotation.NonNull;

/**
 * The shell's handling of the Trips tab.
 *
 * <p>Turn-by-turn navigation is not an overlay on top of the tabs: it is what the Trips tab shows
 * while a trip is running. That is what lets the trip survive switching to another tab, because a
 * tab that is merely hidden keeps its view and its progress timer. A screen that starts navigation
 * therefore hands the route to the shell instead of opening a fragment of its own.
 */
public interface TripNavigationHost {

    /** Shows the navigation screen in the Trips tab, with the route the given arguments describe. */
    void showTripNavigation(@NonNull Bundle args);

    /** Puts the Trips tab back on the planner, after the trip was stopped or completed. */
    void showTripPlanner();
}
