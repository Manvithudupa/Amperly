package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.adapter.VehicleCardAdapter;

/**
 * The vehicle garage.
 *
 * <p>An account can keep more than one EV — a second car, a van — and each has its own battery,
 * connector and preferences. Every saved profile is a row in {@code vehicles}; exactly one of
 * them carries {@code isActive}, and that is the profile every range, compatibility and
 * reservation rule is evaluated against.
 *
 * <p>The page is a list of cards: tapping one opens it in {@link VehicleFormFragment}, and the
 * button below the list opens a blank form. Editing and adding happen on their own screen so a
 * long form never pushes the garage out of sight.
 */
public class VehicleProfileFragment extends Fragment implements VehicleCardAdapter.Listener {

    private AmperlyRepository repo;

    private VehicleCardAdapter adapter;
    private RecyclerView list;
    private View emptyState;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_vehicle_profile, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());

        list = view.findViewById(R.id.vehicleList);
        emptyState = view.findViewById(R.id.vehicleEmptyState);
        adapter = new VehicleCardAdapter(this);
        list.setLayoutManager(new LinearLayoutManager(requireContext()));
        list.setAdapter(adapter);

        view.findViewById(R.id.addVehicleButton).setOnClickListener(v -> openForm(null));

        String userId = AuthManager.getInstance().getCurrentUserId();
        if (userId == null) {
            renderEmpty();
            return;
        }
        // The list is observed rather than re-read on every return: a save or a delete made on
        // the form screen reaches Room, and the card appears or disappears without a reload.
        repo.observeVehicles(userId).observe(getViewLifecycleOwner(), vehicles -> {
            adapter.submit(vehicles);
            if (vehicles == null || vehicles.isEmpty()) {
                renderEmpty();
            } else {
                emptyState.setVisibility(View.GONE);
                list.setVisibility(View.VISIBLE);
            }
        });
    }

    private void renderEmpty() {
        adapter.submit(null);
        emptyState.setVisibility(View.VISIBLE);
        list.setVisibility(View.GONE);
    }

    /** Opens the editor, or a blank form when there is no profile to edit yet. */
    private void openForm(@Nullable String vehicleId) {
        Navigator.open(this, VehicleFormFragment.newInstance(vehicleId), "vehicle_form");
    }

    @Override
    public void onEdit(Vehicle vehicle) {
        openForm(vehicle.getId());
    }

    @Override
    public void onUse(Vehicle vehicle) {
        repo.setActiveVehicle(vehicle, remaining -> {
            if (!isAdded() || remaining == null) {
                if (isAdded()) {
                    Ux.error(this, getString(R.string.vehicle_switch_failed));
                }
                return;
            }
            AppStateStore.get().setVehicle(vehicle);
            Ux.toast(this, getString(R.string.vehicle_switched, vehicle.displayName()));
        });
    }
}
