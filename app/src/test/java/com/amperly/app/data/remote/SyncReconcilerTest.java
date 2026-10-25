package com.amperly.app.data.remote;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;

public class SyncReconcilerTest {

    @Test
    public void removesOnlyIdsTheServerNoLongerHas() {
        List<String> local = Arrays.asList("st_1", "st_2", "st_3");
        List<String> remote = Arrays.asList("st_1", "st_3");

        List<String> stale = SyncReconciler.staleIds(local, remote);

        assertEquals(Collections.singletonList("st_2"), stale);
    }

    @Test
    public void keepsLocalOrderSoTheDeletePassIsStable() {
        List<String> local = Arrays.asList("c", "a", "b");
        List<String> remote = Collections.singletonList("b");

        List<String> stale = SyncReconciler.staleIds(local, remote);

        assertEquals(Arrays.asList("c", "a"), stale);
    }

    @Test
    public void emptiesTheCacheWhenTheServerReturnsNoRows() {
        List<String> local = Arrays.asList("res_1", "res_2");

        List<String> stale = SyncReconciler.staleIds(local, Collections.emptySet());

        assertEquals(local, stale);
    }

    @Test
    public void removesNothingWhenTheServerHasEveryCachedId() {
        List<String> local = Arrays.asList("a", "b");

        List<String> stale = SyncReconciler.staleIds(local,
                new HashSet<>(Arrays.asList("a", "b", "c")));

        assertTrue(stale.isEmpty());
    }

    @Test
    public void ignoresNullIdsRatherThanDeletingSomethingUnnamed() {
        List<String> local = Arrays.asList("a", null);

        List<String> stale = SyncReconciler.staleIds(local, Collections.singletonList("a"));

        assertTrue(stale.isEmpty());
    }
}
