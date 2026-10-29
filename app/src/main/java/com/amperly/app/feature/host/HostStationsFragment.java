package com.amperly.app.feature.host;

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
import com.amperly.app.core.security.RoleGuard;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.MeterReading;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.meter.MeterSimulator;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.adapter.StationCardAdapter;
import com.amperly.app.ui.dialog.MeterEvidenceDialog;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * The host's stations, laid out like the vehicle garage: one card per charger, and one button
 * below the list to add another.
 *
 * <p>The list is observed rather than reloaded, so a station saved on the form screen appears
 * here as soon as it reaches Room, without anyone navigating back through a refresh. Registering
 * itself stays on its own screen ({@link RegisterStationFragment}) because the form is long.
 */
public class HostStationsFragment extends Fragment implements StationCardAdapter.Listener {

    private AmperlyRepository repo;
    private StationCardAdapter adapter;
    private RecyclerView list;
    private View emptyState;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_host_stations, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());

        list = view.findViewById(R.id.hostStationsList);
        emptyState = view.findViewById(R.id.hostStationsEmptyState);
        adapter = new StationCardAdapter(this);
        list.setLayoutManager(new LinearLayoutManager(requireContext()));
        list.setAdapter(adapter);

        view.findViewById(R.id.addStationButton).setOnClickListener(v ->
                Navigator.open(this, new RegisterStationFragment(), "register_station"));

        String hostId = AuthManager.getInstance().getCurrentUserId();
        if (hostId == null) {
            renderEmpty();
            return;
        }
        repo.observeStationsForHost(hostId).observe(getViewLifecycleOwner(), stations -> {
            adapter.submit(stations);
            if (stations == null || stations.isEmpty()) {
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

    /** The station actions are host-owned; RLS is the real gate, this fails early with a message. */
    private boolean canManage(ChargerStation station) {
        User user = AuthManager.getInstance().getCurrentUser();
        if (station == null || !RoleGuard.canManageStation(user, station.getHostId())) {
            Ux.error(this, getString(R.string.error_not_allowed));
            return false;
        }
        return true;
    }

    @Override
    public void onTogglePause(ChargerStation station) {
        if (!canManage(station)) {
            return;
        }
        boolean newState = !station.isPaused();
        station.setPaused(newState);
        station.setLastUpdatedMs(System.currentTimeMillis());
        repo.updateStation(station);
        repo.blockStation(station.getId(), newState, newState ? "Paused by the host" : null);
        Ux.success(this, getString(newState
                ? R.string.host_station_paused : R.string.host_station_reopened));
    }

    @Override
    public void onEvidence(ChargerStation station) {
        if (!canManage(station)) {
            return;
        }
        MeterEvidenceDialog.show(this, station.getName(), station.getId(),
                MeterSimulator.currentReading(station.getId()), (start, end, note) -> {
                    if (!MeterSimulator.isValidReading(start, end)) {
                        Ux.error(this, getString(R.string.session_invalid_reading));
                        return;
                    }
                    if (MeterSimulator.isOffline(station.getId())) {
                        Ux.info(this, getString(R.string.session_meter_offline));
                    }
                    MeterSimulator.setReading(station.getId(), end);
                    repo.background(() -> {
                        MeterReading reading = new MeterReading(UUID.randomUUID().toString(),
                                null, station.getId(), start, end, null,
                                station.getVerificationLevel(), System.currentTimeMillis(), true);
                        repo.saveMeterReading(reading);
                        return Boolean.TRUE;
                    }, ok -> {
                        if (isAdded()) {
                            Ux.success(this, getString(R.string.host_meter_evidence_saved,
                                    String.format(Locale.US, "%.2f kWh", end - start)));
                        }
                    });
                });
    }
}
