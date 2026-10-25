package com.amperly.app.feature.consumer;

import android.Manifest;
import android.content.Context;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.common.GeoUtils;
import com.amperly.app.core.location.LocationProvider;
import com.amperly.app.core.map.MapPanel;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.core.state.SocStore;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.availability.AvailabilityEngine;
import com.amperly.app.engine.routing.RoutePlannerEngine;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.adapter.StationAdapter;
import com.amperly.app.ui.dialog.VehicleSwitcherDialog;
import com.google.android.material.chip.ChipGroup;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

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

    /** The user's current position, or null until a fix arrives. */
    @Nullable
    private Double userLat;
    @Nullable
    private Double userLng;

    /** The attached map panel, so a late location fix can re-centre without reloading. */
    @Nullable
    private MapPanel mapPanel;

    /** The charger the driver picked, highlighted on the map and in the list. */
    @Nullable
    private String selectedStationId;

    private final ActivityResultLauncher<String[]> locationPermissionLauncher =
            registerForActivityResult(new ActivityResultContracts.RequestMultiplePermissions(), result -> {
                boolean granted = Boolean.TRUE.equals(
                        result.get(Manifest.permission.ACCESS_FINE_LOCATION))
                        || Boolean.TRUE.equals(
                        result.get(Manifest.permission.ACCESS_COARSE_LOCATION));
                if (granted) {
                    resolveUserLocation();
                } else if (isAdded()) {
                    Ux.error(this, getString(R.string.map_no_location_permission));
                }
            });

    /** "Pilot area: ... · vehicle: ...": the context the list is being filtered against. */
    private String contextLine = "";

    /** The tappable line that shows the active vehicle and opens the quick switch. */
    @Nullable
    private View vehicleSwitcherRow;

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

        View updateVehicleBtn = view.findViewById(R.id.updateVehicleButton);
        if (updateVehicleBtn != null) {
            updateVehicleBtn.setOnClickListener(v -> Navigator.open(this, new VehicleProfileFragment(), "vehicle"));
        }

        // A second car should be one tap away, not a trip to the profile page first.
        vehicleSwitcherRow = view.findViewById(R.id.vehicleSwitcherRow);
        if (vehicleSwitcherRow != null) {
            vehicleSwitcherRow.setOnClickListener(v -> showVehicleSwitcher());
        }

        // The battery card is the driver's own reading: there is nowhere else to state it, and
        // the app will not invent a number for them.
        View batteryCard = view.findViewById(R.id.heroBatteryCard);
        if (batteryCard != null) {
            batteryCard.setOnClickListener(v -> promptForBattery());
        }

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

        ensureUserLocation();
        loadStations();
    }

    @Override
    public void onResume() {
        super.onResume();
        loadStations();
    }

    private void loadStations() {
        String userId = AuthManager.getInstance().getCurrentUserId();
        Context appContext = requireContext().getApplicationContext();
        repo.background(() -> {
            vehicle = repo.getVehicleSync(userId);
            // The reading is scoped to the active vehicle, so switching cars cannot carry the
            // previous battery figure into the range estimate.
            int storedSoc = vehicle == null ? -1
                    : SocStore.load(appContext, userId, vehicle.getId());
            List<StationAdapter.StationRow> rows = new ArrayList<>();
            // With no profile there is nothing to plan for, so the line is a sentence of its own
            // rather than "Planning for No vehicle saved yet."
            String summary = vehicle == null
                    ? getString(R.string.discovery_vehicle_none)
                    : getString(R.string.discovery_vehicle_line,
                    getString(R.string.discovery_vehicle_value, vehicle.getMake(),
                            vehicle.getModel(),
                            com.amperly.app.core.common.Formatters.connectorType(
                                    vehicle.getConnectorType())));
            DiscoveredData data = new DiscoveredData(rows, summary, storedSoc);
            // Distances are measured from the driver's real position, never a fixed pilot point.
            Double fromLat = userLat;
            Double fromLng = userLng;
            // One grouped availability read for the whole result list instead of one read per
            // station; the screen resumes often and the old path was 4 queries per charger.
            List<ChargerStation> stations = repo.getApprovedStationsSync();
            Map<String, AvailabilityEngine.AvailabilitySummary> availability =
                    repo.availabilitySummaries(stations);
            for (ChargerStation station : stations) {
                rows.add(new StationAdapter.StationRow(station, availability.get(station.getId()),
                        distanceFrom(fromLat, fromLng, station)));
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
            updateSwitcherContentDescription();

            if (getView() != null) {
                TextView heroBattery = getView().findViewById(R.id.heroBatteryText);
                com.google.android.material.progressindicator.LinearProgressIndicator heroProgress =
                        getView().findViewById(R.id.heroBatteryProgress);
                TextView statNearby = getView().findViewById(R.id.statNearbyCountText);
                TextView statPrice = getView().findViewById(R.id.statBestPriceText);
                TextView statRange = getView().findViewById(R.id.statRangeText);

                // The battery figure is the driver's own reading when they have given one,
                // otherwise the planner's labelled estimate. It is never a hard-coded number,
                // and battery HEALTH is not a state of charge — the two are different fields.
                AppStateStore.get().applyStoredSoc(vehicle == null ? null : vehicle.getId(),
                        data.storedSoc);
                int batteryPct = AppStateStore.get().getCurrentSoc();
                if (heroBattery != null) {
                    heroBattery.setText(batteryPct >= 0
                            ? getString(R.string.discovery_battery_value, batteryPct)
                            : getString(R.string.discovery_battery_unknown));
                }
                TextView heroCaption = getView().findViewById(R.id.heroBatteryCaption);
                if (heroCaption != null) {
                    heroCaption.setText(batteryPct >= 0
                            ? R.string.discovery_battery_caption_known
                            : R.string.discovery_battery_caption);
                }
                if (heroProgress != null) {
                    heroProgress.setProgress(Math.max(0, batteryPct));
                }
                if (statNearby != null) statNearby.setText(String.valueOf(allStations.size()));

                double bestPrice = -1;
                for (ChargerStation s : allStations) {
                    if (s.getPricePerKwh() > 0 && (bestPrice < 0 || s.getPricePerKwh() < bestPrice)) {
                        bestPrice = s.getPricePerKwh();
                    }
                }
                if (statPrice != null) {
                    statPrice.setText(bestPrice > 0
                            ? com.amperly.app.core.common.Formatters.money(bestPrice)
                            : getString(R.string.discovery_no_price));
                }
                if (statRange != null) {
                    // Range above the reserve the vehicle profile asks us to keep, from the
                    // vehicle's own usable capacity and efficiency — labelled as an estimate.
                    if (vehicle != null && batteryPct >= 0) {
                        int usableSoc = Math.max(0, batteryPct - Math.max(0,
                                vehicle.getMinArrivalSocPercent()));
                        int estRange = (int) Math.round(usableSoc / 100.0
                                * vehicle.getBatteryCapacityKwh()
                                * vehicle.effectiveEfficiencyKmPerKwh());
                        statRange.setText(getString(R.string.discovery_range_value, estRange));
                    } else {
                        statRange.setText(getString(R.string.discovery_range_unknown));
                    }
                }
            }

            // Reuse the adapter: replacing it on every reload threw away the scroll position,
            // so coming back from a charger detail (or saving the battery) jumped the list to
            // the top.
            if (adapter == null) {
                adapter = new StationAdapter(this, vehicle);
                recyclerView.setAdapter(adapter);
            } else {
                adapter.setVehicle(vehicle);
            }
            adapter.setSelectedStationId(selectedStationId);
            applyFilter();
            MapPanel.attach(this, mapContainer, panel -> {
                mapPanel = panel;
                plotMap();
                // Tapping a station marker selects that charger instead of leaving the screen.
                panel.setMarkerTapListener(station -> {
                    if (station != null) {
                        onSelectStation(station);
                    }
                });
            });
        });
    }

    /**
     * Offers the saved vehicles of this account and switches the one in use.
     *
     * <p>The garage is read fresh instead of from the last station load, so a profile added on
     * the profile page a moment ago is already offered here. With no profile yet there is
     * nothing to switch between, and the profile page is the useful destination.
     */
    private void showVehicleSwitcher() {
        VehicleSwitcherDialog.show(this, vehicle == null ? null : vehicle.getId(),
                new VehicleSwitcherDialog.Listener() {
                    @Override
                    public void onVehicleSwitched(@NonNull Vehicle switched) {
                        applyVehicleSwitch(switched);
                    }

                    @Override
                    public void onManageVehicles() {
                        Navigator.open(ChargerDiscoveryFragment.this,
                                new VehicleProfileFragment(), "vehicle");
                    }
                });
    }

    /** Redraws this screen for the profile the shared picker has already stored. */
    private void applyVehicleSwitch(Vehicle chosen) {
        if (!isAdded()) {
            return;
        }
        vehicle = chosen;
        AppStateStore.get().setVehicle(chosen);
        String label = getString(R.string.discovery_vehicle_value, chosen.getMake(),
                chosen.getModel(),
                com.amperly.app.core.common.Formatters.connectorType(
                        chosen.getConnectorType()));
        contextLine = getString(R.string.discovery_vehicle_line, label);
        if (contextText != null) {
            contextText.setText(contextLine);
        }
        updateSwitcherContentDescription();
        Ux.toast(this, getString(R.string.vehicle_switched, chosen.displayName()));
        loadStations();
    }

    /** TalkBack reads the row as an action, with the current vehicle as the detail. */
    private void updateSwitcherContentDescription() {
        if (vehicleSwitcherRow != null && contextLine != null) {
            vehicleSwitcherRow.setContentDescription(
                    getString(R.string.vehicle_switch_description, contextLine));
        }
    }

    /** Distance to the charger, or null while no real position is known. */
    @Nullable
    private static Double distanceFrom(@Nullable Double fromLat, @Nullable Double fromLng,
                                       @NonNull ChargerStation station) {
        if (fromLat == null || fromLng == null) {
            return null;
        }
        return GeoUtils.distanceKm(fromLat, fromLng, station.getLatitude(), station.getLongitude());
    }

    /** Draws the list's chargers on the map, with the chosen one highlighted. */
    private void plotMap() {
        if (mapPanel != null) {
            mapPanel.plotStations(allStations, selectedStationId, userLat, userLng);
        }
    }

    /** Asks for the dashboard reading and keeps it for this account. */
    private void promptForBattery() {
        if (!isAdded()) {
            return;
        }
        View content = LayoutInflater.from(requireContext())
                .inflate(R.layout.dialog_input_number, null, false);
        final TextInputLayout field = content.findViewById(R.id.numberField);
        final TextInputEditText input = content.findViewById(R.id.numberInput);
        int current = AppStateStore.get().getCurrentSoc();
        if (current >= 0) {
            input.setText(String.valueOf(current));
            input.setSelection(input.getText().length());
        }
        input.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                field.setError(null);
            }
        });

        final androidx.appcompat.app.AlertDialog dialog = new MaterialAlertDialogBuilder(requireContext())
                .setTitle(R.string.discovery_set_battery_title)
                .setMessage(R.string.discovery_set_battery_message)
                .setView(content)
                .setNegativeButton(R.string.action_close, null)
                .setPositiveButton(R.string.action_save, null)
                .create();

        // The positive button is wired by hand so an out-of-range value keeps the dialog open
        // and points at the field, instead of dismissing and reporting the problem elsewhere.
        dialog.setOnShowListener(ignored -> dialog
                .getButton(androidx.appcompat.app.AlertDialog.BUTTON_POSITIVE)
                .setOnClickListener(v -> {
                    int soc = parseInt(input.getText() == null ? "" : input.getText().toString());
                    if (soc < 0 || soc > 100) {
                        field.setError(getString(R.string.discovery_set_battery_invalid));
                        return;
                    }
                    field.setError(null);
                    dialog.dismiss();
                    saveBattery(soc);
                }));
        dialog.show();
        input.requestFocus();
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    private void saveBattery(int soc) {
        AppStateStore.get().applySocCorrection(AppStateStore.get().getCurrentSoc(), soc);
        SocStore.save(requireContext(), AuthManager.getInstance().getCurrentUserId(),
                vehicle == null ? null : vehicle.getId(), soc);
        Ux.success(this, getString(R.string.discovery_set_battery_saved, soc));
        // Reloading redraws the hero, the range estimate and the compatibility labels with
        // the new reading rather than leaving the old figure on screen.
        loadStations();
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
        adapter.setSelectedStationId(selectedStationId);
        adapter.submit(filtered);
        resultCountText.setText(getResources().getQuantityString(R.plurals.discovery_shown,
                filtered.size(), filtered.size(), filterLabel()));

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

    /** Asks for permission if needed, then resolves the user's position and re-centres the map. */
    private void ensureUserLocation() {
        if (LocationProvider.hasLocationPermission(requireContext())) {
            resolveUserLocation();
            return;
        }
        if (LocationProvider.hasAskedForPermission(requireContext())) {
            // Already declined once: keep the map useful without prompting on every visit.
            return;
        }
        LocationProvider.markPermissionAsked(requireContext());
        locationPermissionLauncher.launch(new String[]{
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION});
    }

    private void resolveUserLocation() {
        LocationProvider.requestCurrentLocation(requireContext(),
                new LocationProvider.LocationCallback() {
                    @Override
                    public void onLocationRetrieved(double latitude, double longitude) {
                        // The screen can be replaced while the fix is in flight (a tab switch, a
                        // post-sync rebuild), and then there is no context to render into.
                        if (!isAdded()) {
                            return;
                        }
                        userLat = latitude;
                        userLng = longitude;
                        // The list was built before the fix arrived, so it has no distances yet.
                        // Rebuild them in place rather than showing stations without a distance.
                        applyDistances();
                        plotMap();
                    }

                    @Override
                    public void onLocationUnavailable() {
                        if (isAdded()) {
                            // No silent substitution of a fixed coordinate: the list simply
                            // shows stations without a distance until a fix arrives.
                            Ux.error(ChargerDiscoveryFragment.this,
                                    getString(R.string.map_location_unavailable));
                        }
                    }
                });
    }

    /** Recomputes every row's distance once a real position is known. */
    private void applyDistances() {
        if (!isAdded() || userLat == null || userLng == null || allRows.isEmpty()) {
            return;
        }
        List<StationAdapter.StationRow> updated = new ArrayList<>();
        for (StationAdapter.StationRow row : allRows) {
            updated.add(new StationAdapter.StationRow(row.getStation(), row.getAvailability(),
                    distanceFrom(userLat, userLng, row.getStation())));
        }
        allRows.clear();
        allRows.addAll(updated);
        if (adapter != null) {
            applyFilter();
        }
    }

    @Override
    public void onSelectStation(ChargerStation station) {
        selectedStationId = station.getId();
        if (adapter != null) {
            adapter.setSelectedStationId(selectedStationId);
        }
        plotMap();
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
        if (userLat != null && userLng != null) {
            openNavigation(userLat, userLng, station);
            return;
        }
        if (!LocationProvider.hasLocationPermission(requireContext())) {
            Ux.error(this, getString(R.string.map_no_location_permission));
            return;
        }
        // The first fix may not have arrived when the list was built. Asking for the route
        // without an origin used to dead-end in a toast; wait for the fix instead.
        Ux.toast(this, getString(R.string.nav_locating));
        LocationProvider.requestCurrentLocation(requireContext(),
                new LocationProvider.LocationCallback() {
                    @Override
                    public void onLocationRetrieved(double latitude, double longitude) {
                        if (!isAdded()) {
                            return;
                        }
                        userLat = latitude;
                        userLng = longitude;
                        applyDistances();
                        plotMap();
                        openNavigation(latitude, longitude, station);
                    }

                    @Override
                    public void onLocationUnavailable() {
                        if (isAdded()) {
                            Ux.error(ChargerDiscoveryFragment.this,
                                    getString(R.string.route_needs_origin));
                        }
                    }
                });
    }

    /** In-app navigation, not a handoff to an external maps app. */
    private void openNavigation(double fromLat, double fromLng, ChargerStation station) {
        InAppNavigationFragment fragment = new InAppNavigationFragment();
        Bundle args = new Bundle();
        args.putDouble(InAppNavigationFragment.ARG_ORIGIN_LAT, fromLat);
        args.putDouble(InAppNavigationFragment.ARG_ORIGIN_LNG, fromLng);
        args.putDouble(InAppNavigationFragment.ARG_DEST_LAT, station.getLatitude());
        args.putDouble(InAppNavigationFragment.ARG_DEST_LNG, station.getLongitude());
        args.putString(InAppNavigationFragment.ARG_LABEL, station.getName());
        fragment.setArguments(args);
        Navigator.open(this, fragment, "in_app_nav");
    }

    private static class DiscoveredData {
        private final List<StationAdapter.StationRow> rows;
        private final String summary;
        /** The active vehicle's remembered battery reading, or -1 when there is none. */
        private final int storedSoc;

        DiscoveredData(List<StationAdapter.StationRow> rows, String summary, int storedSoc) {
            this.rows = rows;
            this.summary = summary;
            this.storedSoc = storedSoc;
        }
    }
}
