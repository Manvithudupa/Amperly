package com.amperly.app.data.remote;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Works out which cached rows a server has deleted.
 *
 * <p>The pull cursor follows {@code serverUpdatedAt}, which cannot describe a deleted row:
 * there is nothing left to stamp. So a row deleted on the server (a charger removed, a
 * reservation purged) would otherwise stay in Room for ever and keep appearing on screen.
 * The only signal is absence from the server's id list, which is what this compares.
 *
 * <p>Kept as a plain function — no Room, no HTTP — so the comparison is testable on its own.
 */
public final class SyncReconciler {

    private SyncReconciler() {
    }

    /**
     * The local ids that no longer exist on the server.
     *
     * <p>Order is preserved from {@code localIds} so a deletion pass is deterministic. Ids
     * present on the server but missing locally are not this method's concern: those arrive
     * through the normal upsert pull.
     */
    @NonNull
    @SuppressWarnings("unchecked")
    public static List<String> staleIds(@NonNull Collection<String> localIds,
                                        @NonNull Collection<String> remoteIds) {
        Set<String> remote = remoteIds instanceof Set
                ? new HashSet<>((Set<String>) remoteIds) : new HashSet<>(remoteIds);
        List<String> stale = new ArrayList<>();
        for (String id : localIds) {
            if (id != null && !remote.contains(id)) {
                stale.add(id);
            }
        }
        return stale;
    }
}
