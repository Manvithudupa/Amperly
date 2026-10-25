package com.amperly.app.ui.dialog;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.ui.Ux;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;

import java.util.List;

/**
 * The one vehicle picker, shared by every screen that lets the driver change cars.
 *
 * <p>Discover and the route planner both need the same three things: the garage as it is now, a
 * switch that reaches the server, and an honest failure message when it does not. Keeping that in
 * one place means the two screens cannot drift — and a new screen gets the same behaviour for one
 * call.
 *
 * <p>The switch is written before the listener is told, so a listener that recalculates a plan
 * cannot read the previous vehicle back from the database.
 */
public final class VehicleSwitcherDialog {

    /** What the calling screen wants to do about the outcome. */
    public interface Listener {
        /** The new active profile is stored; update the screen for it. */
        void onVehicleSwitched(@NonNull Vehicle vehicle);

        /** The driver asked for the profile page, or has no vehicle to switch between yet. */
        void onManageVehicles();
    }

    private VehicleSwitcherDialog() {
    }

    /**
     * Shows the garage picker.
     *
     * @param host            the screen that owns the dialog
     * @param activeVehicleId the profile currently in use, so its radio is selected
     * @param listener        told after the switch is stored
     */
    public static void show(@NonNull Fragment host, @Nullable String activeVehicleId,
                            @NonNull Listener listener) {
        if (!host.isAdded()) {
            return;
        }
        AmperlyRepository repo = AmperlyRepository.getInstance(host.requireContext());
        String userId = AuthManager.getInstance().getCurrentUserId();
        repo.background(() -> repo.getVehiclesSync(userId), list -> {
            if (!host.isAdded()) {
                return;
            }
            if (list == null || list.isEmpty()) {
                // Nothing to switch between: the profile page is where a first car is added.
                listener.onManageVehicles();
                return;
            }
            // Only real vehicles are choices: a management action drawn as a third radio would
            // read as a third car, so it lives on its own button instead.
            final String[] labels = new String[list.size()];
            int checked = -1;
            for (int i = 0; i < list.size(); i++) {
                Vehicle candidate = list.get(i);
                labels[i] = candidate.displayName();
                if (candidate.getId().equals(activeVehicleId)) {
                    checked = i;
                }
            }

            new MaterialAlertDialogBuilder(host.requireContext())
                    .setTitle(R.string.vehicle_switch_title)
                    .setSingleChoiceItems(labels, checked, (dialog, which) -> {
                        dialog.dismiss();
                        Vehicle chosen = list.get(which);
                        if (chosen.getId().equals(activeVehicleId)) {
                            // The car already in use is not a change.
                            return;
                        }
                        switchTo(host, repo, chosen, listener);
                    })
                    .setNeutralButton(R.string.vehicle_manage,
                            (dialog, which) -> listener.onManageVehicles())
                    .setNegativeButton(R.string.action_cancel, null)
                    .show();
        });
    }

    private static void switchTo(@NonNull Fragment host, @NonNull AmperlyRepository repo,
                                 @NonNull Vehicle chosen, @NonNull Listener listener) {
        repo.setActiveVehicle(chosen, garage -> {
            if (!host.isAdded()) {
                return;
            }
            if (garage == null) {
                // The write failed and is logged; say so rather than leaving the old car in
                // place as if the tap had worked.
                Ux.error(host, host.getString(R.string.vehicle_switch_failed));
                return;
            }
            listener.onVehicleSwitched(chosen);
        });
    }
}
