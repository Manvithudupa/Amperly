package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.common.GeoUtils;
import com.amperly.app.core.map.MapHelper;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.availability.AvailabilityEngine;
import com.amperly.app.engine.routing.RoutePlannerEngine;
import com.amperly.app.ui.adapter.StationAdapter;
import com.google.android.material.chip.ChipGroup;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Discovery is honest about what it knows: availability comes from host schedules and reservations,
 * every card shows when it was last updated, and stations without a verified meter are marked
 * discovery only.
 */
public class ChargerDiscoveryFragment extends Fragment implements StationAdapter.Listener {

    private AmperlyRepository repo;
    private StationAdapter adapter;
    private RecyclerView recyclerView;
    private TextView resultCountText;
    private TextView contextText;
    private TextView emptyStateText;
    private View emptyStateContainer;
    private View emptyStateActionButton;
    private ChipGroup filterChipGroup;
    private FrameLayout mapContainer;

    /** "Pilot area: ... · vehicle: ...": the context the list is being filtered against. */
    private String contextLine = "";

    private final List<StationAdapter.StationRow> allRows = new ArrayList<>();
    private final List<ChargerStation> allStations = new ArrayList<>();
    private Vehicle vehicle;
    private String activeFilter = "ALL";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_charger_discovery, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());

        resultCountText = view.findViewById(R.id.resultCountText);
        contextText = view.findViewById(R.id.discoveryContextText);
        emptyStateText = view.findViewById(R.id.emptyStateText);
        emptyStateContainer = view.findViewById(R.id.emptyStateContainer);
        emptyStateActionButton = view.findViewById(R.id.emptyStateActionButton);
        mapContainer = view.findViewById(R.id.mapContainer);
        recyclerView = view.findViewById(R.id.stationsRecyclerView);
        recyclerView.setLayoutManager(new LinearLayoutManager(requireContext()));
        recyclerView.setNestedScrollingEnabled(false);
        adapter = new StationAdapter(this, null);
        recyclerView.setAdapter(adapter);

        if (emptyStateActionButton != null) {
            emptyStateActionButton.setOnClickListener(v -> showAll());
        }

        ChipGroup filters = view.findViewById(R.id.filterChipGroup);
        filterChipGroup = filters;
        filters.setOnCheckedStateChangeListener((group, checkedIds) -> {
            if (checkedIds.isEmpty()) {
                activeFilter = "ALL";
            } else {
                int id = checkedIds.get(0);
                if (id == R.id.filterCompatibleChip) {
                    activeFilter = "COMPATIBLE";
                } else if (id == R.id.filterCampusChip) {
                    activeFilter = "CAMPUS";
                } else if (id == R.id.filterApartmentChip) {
                    activeFilter = "APARTMENT";
                } else if (id == R.id.filterDcChip) {
                    activeFilter = "DC";
                } else if (id == R.id.filterVerifiedMeterChip) {
                    activeFilter = "METER";
                } else {
                    activeFilter = "ALL";
                }
            }
            applyFilter();
        });

        loadStations();
    }

    @Override
    public void onResume() {
        super.onResume();
        loadStations();
    }

    private void loadStations() {
        String userId = AuthManager.getInstance().getCurrentUserId();
        repo.background(() -> {
            vehicle = repo.getVehicleSync(userId);
            List<StationAdapter.StationRow> rows = new ArrayList<>();
            StringBuilder summary = new StringBuilder();
            summary.append("Pilot area: ").append(AppConstants.PILOT_NAME)
                    .append(" · vehicle: ")
                    .append(vehicle == null ? "not set" : vehicle.getMake() + " " + vehicle.getModel()
                            + " (" + vehicle.getConnectorType() + ")");
            DiscoveredData data = new DiscoveredData(rows, summary.toString());
            for (ChargerStation station : repo.getApprovedStationsSync()) {
                AvailabilityEngine.AvailabilitySummary availability =
                        repo.getAvailabilitySummary(station.getId());
                double distance = GeoUtils.distanceKm(AppConstants.PILOT_CENTER_LAT,
                        AppConstants.PILOT_CENTER_LNG, station.getLatitude(), station.getLongitude());
                String extra = String.format(Locale.US, "%.1f km from your usual area · %s",
                        distance, station.getOperatingHours());
                rows.add(new StationAdapter.StationRow(station, availability, extra));
            }
            return data;
        }, data -> {
            if (data == null || !isAdded()) {
                return;
            }
            allRows.clear();
            allRows.addAll(data.rows);
            allStations.clear();
            for (StationAdapter.StationRow row : allRows) {
                allStations.add(row.getStation());
            }
            contextLine = data.summary;
            if (contextText != null) {
                contextText.setText(contextLine);
            }
            adapter = new StationAdapter(this, vehicle);
            recyclerView.setAdapter(adapter);
            applyFilter();
            MapHelper.attach(this, mapContainer, map -> MapHelper.plotStations(map, allStations, null));
        });
    }

    private void applyFilter() {
        List<StationAdapter.StationRow> filtered = new ArrayList<>();
        for (StationAdapter.StationRow row : allRows) {
            ChargerStation station = row.getStation();
            switch (activeFilter) {
                case "COMPATIBLE":
                    if (!RoutePlannerEngine.isConnectorCompatible(station, vehicle)) continue;
                    break;
                case "CAMPUS":
                    if (!AppConstants.LOCATION_TYPE_CAMPUS.equals(station.getLocationType())) continue;
                    break;
                case "APARTMENT":
                    if (!AppConstants.LOCATION_TYPE_APARTMENT.equals(station.getLocationType())) continue;
                    break;
                case "DC":
                    if (!station.isDcCapable()) continue;
                    break;
                case "METER":
                    if (!station.supportsPaidEnergyBilling()) continue;
                    break;
                default:
                    break;
            }
            filtered.add(row);
        }
        adapter.submit(filtered);
        resultCountText.setText(getString(R.string.discovery_shown, filtered.size(),
                filterLabel()));

        boolean empty = filtered.isEmpty();
        if (emptyStateContainer != null) {
            emptyStateContainer.setVisibility(empty ? View.VISIBLE : View.GONE);
        }
        if (empty) {
            // Two very different situations behind the same empty list: nothing is published at
            // all, or the filter the user just chose excludes everything.
            boolean filteredOut = !allRows.isEmpty();
            if (emptyStateText != null) {
                emptyStateText.setText(getString(filteredOut
                        ? R.string.discovery_empty : R.string.discovery_empty_none));
            }
            if (emptyStateActionButton != null) {
                emptyStateActionButton.setVisibility(filteredOut ? View.VISIBLE : View.GONE);
            }
        }
    }

    private String filterLabel() {
        switch (activeFilter) {
            case "COMPATIBLE":
                return getString(R.string.filter_compatible);
            case "CAMPUS":
                return getString(R.string.filter_campus);
            case "APARTMENT":
                return getString(R.string.filter_apartment);
            case "DC":
                return getString(R.string.filter_dc_fast);
            case "METER":
                return getString(R.string.filter_verified_only);
            default:
                return getString(R.string.filter_all);
        }
    }

    /** Clears the filter chips so the user can see everything again. */
    private void showAll() {
        activeFilter = "ALL";
        if (filterChipGroup != null && filterChipGroup.getCheckedChipId() != R.id.filterAllChip) {
            filterChipGroup.check(R.id.filterAllChip);
            return;
        }
        applyFilter();
    }

    @Override
    public void onOpenStation(ChargerStation station) {
        ChargerDetailsFragment fragment = new ChargerDetailsFragment();
        Bundle args = new Bundle();
        args.putString(ChargerDetailsFragment.ARG_STATION_ID, station.getId());
        fragment.setArguments(args);
        Navigator.open(this, fragment, "station_details");
    }

    @Override
    public void onNavigateToStation(ChargerStation station) {
        Navigator.navigateTo(requireContext(), station.getLatitude(), station.getLongitude(), station.getName());
    }

    private static class DiscoveredData {
        private final List<StationAdapter.StationRow> rows;
        private final String summary;

        DiscoveredData(List<StationAdapter.StationRow> rows, String summary) {
            this.rows = rows;
            this.summary = summary;
        }
    }
}
