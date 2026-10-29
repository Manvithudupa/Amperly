package com.amperly.app.core.nav;

import androidx.annotation.Nullable;

/**
 * The shell's answer to "which tab is on show?".
 *
 * <p>A page opened with {@link Navigator#open} lands on top of the tab it was opened from, so it
 * joins that tab's history rather than a history of its own. Naming the transaction after the tab
 * is what lets the shell file a tab's pages away while another tab is showing and put them back
 * afterwards, instead of discarding them the moment a tab is selected.
 */
public interface TabBackStackHost {

    /**
     * The name of the back stack the tab on show files its pages under, or null when no tab is on
     * show (the sign-in page, for instance), in which case a page keeps its own name.
     */
    @Nullable
    String currentTabBackStackName();
}
