package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.google.android.material.chip.ChipGroup;
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.core.common.PilotPlaces;
import com.amperly.app.core.map.MapHelper;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.RoutePlan;
import com.amperly.app.data.local.entity.RouteStop;
import com.amperly.app.data.local.entity.TripEstimate;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.routing.RoutePlannerEngine;
import com.amperly.app.engine.soc.SoCEstimatorEngine;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.adapter.RouteStopAdapter;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * Route and charging plan.
 *
 * The screen evaluates the whole journey, shows the detour/charge-time/battery trade-off for every
 * candidate, records the assumptions, and treats a dashboard battery figure as authoritative the
 * moment the consumer enters it — removing unreachable chargers and offering honest alternatives when
 * nothing can be reached safely.
 */
public class RoutePlannerFragment extends Fragment implements RouteStopAdapter.Listener {

    private AmperlyRepository repo;
    private EditText originEdit;
    private EditText destinationEdit;
    private EditText distanceEdit;
    private EditText currentSocEdit;
    private EditText actualSocEdit;
    private TextView summaryText;
    private TextView confidenceText;
    private TextView planStatusText;
    private TextView socSourceText;
    private LinearLayout assumptionsContainer;
    private LinearLayout recalcContainer;
    private View noSafeChargerCard;
    private FrameLayout mapContainer;
    private RouteStopAdapter plannedAdapter;
    private RouteStopAdapter backupsAdapter;
    private RouteStopAdapter candidatesAdapter;

    private double corridorKm = AppConstants.DEFAULT_CORRIDOR_KM;
    private String preference = RoutePlannerEngine.PREF_FASTEST;
    private RoutePlannerEngine.RoutePlanResult lastResult;
    private RoutePlan lastPlan;
    private List<ChargerStation> lastCandidates = new ArrayList<>();

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_route_planner, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());

        originEdit = view.findViewById(R.id.originEdit);
        destinationEdit = view.findViewById(R.id.destinationEdit);
        distanceEdit = view.findViewById(R.id.distanceEdit);
        currentSocEdit = view.findViewById(R.id.currentSocEdit);
        actualSocEdit = view.findViewById(R.id.actualSocEdit);
        summaryText = view.findViewById(R.id.routeSummaryText);
        confidenceText = view.findViewById(R.id.confidenceText);
        planStatusText = view.findViewById(R.id.planStatusText);
        socSourceText = view.findViewById(R.id.socSourceText);
        assumptionsContainer = view.findViewById(R.id.assumptionsContainer);
        recalcContainer = view.findViewById(R.id.recalcContainer);
        noSafeChargerCard = view.findViewById(R.id.noSafeChargerContainer);
        mapContainer = view.findViewById(R.id.routeMapContainer);

        plannedAdapter = new RouteStopAdapter(this);
        backupsAdapter = new RouteStopAdapter(this);
        candidatesAdapter = new RouteStopAdapter(this);
        setupList(view.findViewById(R.id.plannedStopsRecyclerView), plannedAdapter);
        setupList(view.findViewById(R.id.backupsRecyclerView), backupsAdapter);
        setupList(view.findViewById(R.id.candidatesRecyclerView), candidatesAdapter);

        ((ChipGroup) view.findViewById(R.id.corridorChipGroup))
                .setOnCheckedStateChangeListener((group, ids) -> {
            if (ids.isEmpty()) {
                return;
            }
            int id = ids.get(0);
            if (id == R.id.corridor5Chip) {
                corridorKm = 5;
            } else if (id == R.id.corridor20Chip) {
                corridorKm = 20;
            } else {
                corridorKm = AppConstants.DEFAULT_CORRIDOR_KM;
            }
        });

        ((ChipGroup) view.findViewById(R.id.preferenceChipGroup))
                .setOnCheckedStateChangeListener((group, ids) -> {
            if (ids.isEmpty()) {
                return;
            }
            int id = ids.get(0);
            if (id == R.id.prefCheapestChip) {
                preference = RoutePlannerEngine.PREF_CHEAPEST;
            } else if (id == R.id.prefReliableChip) {
                preference = RoutePlannerEngine.PREF_RELIABLE;
            } else if (id == R.id.prefShortestDetourChip) {
                preference = RoutePlannerEngine.PREF_SHORTEST_DETOUR;
            } else {
                preference = RoutePlannerEngine.PREF_FASTEST;
            }
        });

        Button planButton = view.findViewById(R.id.planRouteButton);
        planButton.setOnClickListener(v -> planRoute());

        Button updateSoc = view.findViewById(R.id.updateSocButton);
        updateSoc.setOnClickListener(v -> applySocCorrection(0));

        view.findViewById(R.id.widerRadiusButton).setOnClickListener(v -> {
            corridorKm = 20;
            planStatusText.setVisibility(View.VISIBLE);
            planStatusText.setText("Widening the search radius to 20 km and re-evaluating the corridor…");
            planRoute();
        });

        view.findViewById(R.id.slowerChargerButton).setOnClickListener(v -> {
            planStatusText.setVisibility(View.VISIBLE);
            planStatusText.setText("Allowing a slower compatible charger with a 10% arrival reserve instead of "
                    + "your usual reserve. Amperly will not go below this floor.");
            applySocCorrection(10);
        });

        view.findViewById(R.id.emergencyButton).setOnClickListener(v -> showEmergencyGuidance());

        planRoute();
    }

    private void setupList(RecyclerView recyclerView, RouteStopAdapter adapter) {
        recyclerView.setLayoutManager(new LinearLayoutManager(requireContext()));
        recyclerView.setNestedScrollingEnabled(false);
        recyclerView.setAdapter(adapter);
    }

    private void planRoute() {
        final String origin = originEdit.getText().toString().trim();
        final String destination = destinationEdit.getText().toString().trim();
        final double distance;
        try {
            distance = Double.parseDouble(distanceEdit.getText().toString().trim());
        } catch (NumberFormatException e) {
            Ux.toast(this, "Enter the route distance in kilometres.");
            return;
        }
        String socText = currentSocEdit.getText().toString().trim();
        final Integer enteredSoc = TextUtils.isEmpty(socText) ? null : safeInt(socText);
        final String userId = AuthManager.getInstance().getCurrentUserId();

        repo.background(() -> {
            Vehicle vehicle = repo.getVehicleSync(userId);
            List<ChargerStation> stations = repo.getApprovedStationsSync();

            double[] originCoords = PilotPlaces.resolveOrPilot(origin);
            double[] destinationCoords = PilotPlaces.resolveOrPilot(destination);
            boolean knownPlaces = PilotPlaces.isKnown(origin) && PilotPlaces.isKnown(destination);

            int startSoc;
            boolean fromProfile = false;
            if (enteredSoc != null) {
                startSoc = Math.max(0, Math.min(100, enteredSoc));
            } else {
                SoCEstimatorEngine.SocEstimate estimate =
                        SoCEstimatorEngine.estimateStartingSoc(vehicle, 45.0);
                startSoc = estimate.getSoc();
                fromProfile = true;
            }

            RoutePlannerEngine.RoutePlanResult result = RoutePlannerEngine.planRoute(origin, destination,
                    originCoords[0], originCoords[1], destinationCoords[0], destinationCoords[1],
                    distance, corridorKm, startSoc, AppStateStore.get().isSocAuthoritative(), fromProfile,
                    preference, vehicle, stations);

            RoutePlan plan = new RoutePlan(UUID.randomUUID().toString(), userId,
                    vehicle == null ? null : vehicle.getId(), origin, destination,
                    originCoords[0], originCoords[1], destinationCoords[0], destinationCoords[1],
                    corridorKm, preference, result.getTotalDistanceKm(), result.getDriveMinutes(),
                    result.getDetourMinutes(), result.getChargingMinutes(), result.getTotalJourneyMinutes(),
                    startSoc, result.getArrivalTargetSoc(), AppStateStore.get().isSocAuthoritative(),
                    join(result.getAssumptions()), result.getConfidence(), "ACTIVE",
                    System.currentTimeMillis(), System.currentTimeMillis());
            repo.saveRoutePlan(plan);
            repo.replaceRouteStops(plan.getId(), toStops(plan.getId(), result));

            AppStateStore store = AppStateStore.get();
            store.setVehicle(vehicle);
            store.setEstimatedSoc(startSoc);
            store.setActivePlan(plan);
            store.setLastPlanResult(result);
            store.setUserId(userId);

            return new PlanBundle(result, plan, stations, knownPlaces, fromProfile);
        }, bundle -> {
            if (bundle == null || !isAdded()) {
                return;
            }
            renderPlan(bundle);
        });
    }

    private void renderPlan(PlanBundle bundle) {
        RoutePlannerEngine.RoutePlanResult result = bundle.result;
        lastResult = result;
        lastPlan = bundle.plan;
        lastCandidates = result.getCandidates().isEmpty() ? new ArrayList<>() : stationsOf(result);

        summaryText.setText(getString(R.string.route_summary, result.getOrigin(), result.getDestination(),
                result.getTotalDistanceKm(), Formatters.minutes(result.getDriveMinutes()),
                Formatters.minutes(result.getChargingMinutes()),
                Formatters.minutes(result.getTotalJourneyMinutes())));
        confidenceText.setText(getString(R.string.route_confidence, result.getConfidence())
                + " · corridor " + (int) result.getCorridorKm() + " km · "
                + result.getCandidates().size() + " compatible charger(s) in the corridor · "
                + result.getExcluded().size() + " excluded");

        if (!bundle.knownPlaces) {
            planStatusText.setVisibility(View.VISIBLE);
            planStatusText.setText("Place lookup fell back to the pilot corridor for one of the endpoints, "
                    + "so distances are straight-line estimates between the resolved points.");
        } else if (result.getNoStopWarning() != null) {
            planStatusText.setVisibility(View.VISIBLE);
            planStatusText.setText(result.getNoStopWarning());
        } else if (result.getPlannedStops().isEmpty()) {
            planStatusText.setVisibility(View.VISIBLE);
            planStatusText.setText("No charging stop is needed for this trip at "
                    + result.getStartSoc() + "% battery. Chargers along the corridor are listed below as options.");
        } else {
            planStatusText.setVisibility(View.GONE);
        }

        socSourceText.setText(bundle.fromProfile
                ? "Amperly estimated your starting battery from the vehicle profile — enter the dashboard value to override it."
                : (AppStateStore.get().isSocAuthoritative()
                ? getString(R.string.soc_now_authoritative, AppStateStore.get().getCurrentSoc(),
                Formatters.agoFromNow(AppStateStore.get().getSocUpdatedAtMs()))
                : "Using the battery percentage you entered. This is not a reading from the car."));

        List<RouteStopAdapter.StopRow> planned = new ArrayList<>();
        for (RoutePlannerEngine.PlannedStop stop : result.getPlannedStops()) {
            planned.add(RouteStopAdapter.fromPlannedStop(stop));
        }
        plannedAdapter.submit(planned);

        List<RouteStopAdapter.StopRow> backups = new ArrayList<>();
        for (RoutePlannerEngine.PlannedStop stop : result.getBackups()) {
            backups.add(RouteStopAdapter.fromPlannedStop(stop));
        }
        backupsAdapter.submit(backups);

        List<RouteStopAdapter.StopRow> candidates = new ArrayList<>();
        int sequence = 1;
        for (RoutePlannerEngine.CandidateEvaluation evaluation : result.getCandidates()) {
            candidates.add(RouteStopAdapter.fromCandidate(evaluation, sequence++, false));
        }
        candidatesAdapter.submit(candidates);

        assumptionsContainer.removeAllViews();
        for (String assumption : result.getAssumptions()) {
            TextView line = new TextView(requireContext());
            line.setText("• " + assumption);
            line.setTextAppearance(R.style.TextAppearance_Amperly_Body);
            line.setPadding(0, 4, 0, 4);
            assumptionsContainer.addView(line);
        }
        for (RoutePlannerEngine.ExcludedStation excluded : result.getExcluded()) {
            TextView line = new TextView(requireContext());
            line.setText("✕ " + excluded.getStation().getName() + " — " + excluded.getReason());
            line.setTextAppearance(R.style.TextAppearance_Amperly_Body);
            line.setPadding(0, 4, 0, 4);
            assumptionsContainer.addView(line);
        }

        List<ChargerStation> markers = new ArrayList<>();
        for (RoutePlannerEngine.CandidateEvaluation candidate : result.getCandidates()) {
            markers.add(candidate.getStation());
        }
        MapHelper.attach(this, mapContainer, map -> MapHelper.plotRoute(map,
                result.getOriginLat(), result.getOriginLng(), result.getDestinationLat(),
                result.getDestinationLng(), markers,
                result.getRecommendedStop() == null ? null : result.getRecommendedStop().getStation().getId()));
    }

    private List<ChargerStation> stationsOf(RoutePlannerEngine.RoutePlanResult result) {
        List<ChargerStation> stations = new ArrayList<>();
        for (RoutePlannerEngine.CandidateEvaluation candidate : result.getCandidates()) {
            stations.add(candidate.getStation());
        }
        return stations;
    }

    private void applySocCorrection(int reserveOverridePercent) {
        String text = actualSocEdit.getText().toString().trim();
        if (TextUtils.isEmpty(text)) {
            Ux.toast(this, "Enter the battery percentage shown on your vehicle dashboard.");
            return;
        }
        int actual = safeInt(text);
        if (actual < 0 || actual > 100) {
            Ux.toast(this, "Battery percentage must be between 0 and 100.");
            return;
        }
        if (lastPlan == null) {
            planRoute();
            return;
        }
        final RoutePlan plan = lastPlan;
        final int previousEstimate = AppStateStore.get().getCurrentSoc() >= 0
                ? AppStateStore.get().getCurrentSoc() : plan.getPlannedStartSoc();
        final String userId = AuthManager.getInstance().getCurrentUserId();

        repo.background(() -> {
            Vehicle vehicle = repo.getVehicleSync(userId);
            List<ChargerStation> stations = repo.getApprovedStationsSync();
            List<ChargerStation> previouslyReachable = AppStateStore.get().safeReachableStations();
            if (lastCandidates != null && !lastCandidates.isEmpty()) {
                stations = lastCandidates;
            }
            double currentLat = plan.getOriginLat() + (0.4 * (plan.getDestinationLat() - plan.getOriginLat()));
            double currentLng = plan.getOriginLng() + (0.4 * (plan.getDestinationLng() - plan.getOriginLng()));
            double remainingKm = plan.getTotalDistanceKm() * 0.6;

            SoCEstimatorEngine.RecalculationResult result =
                    SoCEstimatorEngine.applyAuthoritativeSocOverride(
                            plan.getVehicleId(), plan.getId(), previousEstimate, actual,
                            currentLat, currentLng, remainingKm, plan.getDestinationLat(),
                            plan.getDestinationLng(), vehicle, stations, previouslyReachable,
                            reserveOverridePercent);

            repo.saveBatteryUpdate(result.getAuditRecord());
            if (vehicle != null) {
                double efficiency = vehicle.effectiveEfficiencyKmPerKwh();
                double estimatedDrain = efficiency > 0
                        ? plan.getTotalDistanceKm() / efficiency : 0;
                // The actual drain is only known after the trip, so it is recorded as zero and
                // filled in later by the consumer's post-trip report.
                repo.saveTripEstimate(new TripEstimate(UUID.randomUUID().toString(), plan.getId(),
                        vehicle.getId(), plan.getTotalDistanceKm(), estimatedDrain, 0,
                        previousEstimate, result.getActualDashboardSoc(), plan.getConfidence(),
                        "Recorded when the consumer corrected the battery mid-trip.",
                        System.currentTimeMillis()));
            }
            return result;
        }, result -> {
            if (result == null || !isAdded()) {
                return;
            }
            renderRecalculation(result, previousEstimate);
        });
    }

    private void renderRecalculation(SoCEstimatorEngine.RecalculationResult result, int previousEstimate) {
        AppStateStore.get().applySocCorrection(previousEstimate, result.getActualDashboardSoc());
        AppStateStore.get().setLastRecalculationSummary(result.getExplanation());
        AppStateStore.get().setNoSafeChargerMessage(result.getWarningMessage() == null ? ""
                : result.getWarningMessage());

        recalcContainer.removeAllViews();
        TextView header = new TextView(requireContext());
        header.setText("Original estimate → actual update → revised recommendation");
        header.setTextAppearance(R.style.TextAppearance_Amperly_SectionTitle);
        recalcContainer.addView(header);

        addLine(recalcContainer, getString(R.string.soc_previous_estimate, previousEstimate));
        addLine(recalcContainer, getString(R.string.soc_now_authoritative, result.getActualDashboardSoc(),
                Formatters.agoFromNow(System.currentTimeMillis())));
        addLine(recalcContainer, result.getExplanation());
        addLine(recalcContainer, "Usable range at this battery: about " + result.getEstimatedRangeKm() + " km. "
                + "Remaining trip: " + Formatters.minutes(result.getRemainingJourneyMinutes())
                + " (drive " + Formatters.minutes(result.getRemainingDriveMinutes())
                + " + charge " + Formatters.minutes(result.getRemainingChargingMinutes()) + ").");
        addLine(recalcContainer, getString(R.string.soc_removed_stations,
                result.getUnreachableStations().size())
                + (result.getNewlyReachableStations().isEmpty() ? ""
                : " · newly reachable: " + result.getNewlyReachableStations().size()));
        addLine(recalcContainer, result.getReservationAdvice());

        View alternatives = requireView().findViewById(R.id.plannedStopsRecyclerView);
        List<RouteStopAdapter.StopRow> rows = new ArrayList<>();
        int index = 1;
        for (SoCEstimatorEngine.RemainingStop stop : result.getRemainingOptions()) {
            rows.add(new RouteStopAdapter.StopRow(index == 1 ? "NEAREST SAFE" : "ALTERNATIVE",
                    String.valueOf(index++), stop.getStation().getName(),
                    String.format(Locale.US, "%.1f km away · +%.1f km detour (+%d min) · %d min charge",
                            stop.getDistanceFromCurrentKm(), stop.getDetourKm(), stop.getDetourMinutes(),
                            stop.getChargingMinutes()),
                    stop.getNote(), stop.isReachable(), stop.getStation().getId()));
        }
        plannedAdapter.submit(rows);

        if (result.isNoSafeCharger()) {
            noSafeChargerCard.setVisibility(View.VISIBLE);
        } else {
            noSafeChargerCard.setVisibility(View.GONE);
        }
        Ux.toast(this, "Remaining route recalculated using your dashboard value of "
                + result.getActualDashboardSoc() + "%.");
    }

    private void addLine(LinearLayout container, String text) {
        TextView line = new TextView(requireContext());
        line.setText(text);
        line.setTextAppearance(R.style.TextAppearance_Amperly_Body);
        line.setPadding(0, 6, 0, 6);
        container.addView(line);
    }

    private void showEmergencyGuidance() {
        new androidx.appcompat.app.AlertDialog.Builder(requireContext())
                .setTitle(R.string.soc_emergency)
                .setMessage("Amperly is not an emergency service. If you are in danger call your local "
                        + "emergency number (112 in India). Otherwise: move the vehicle to a safe place, "
                        + "keep your hazard lights on, and use the Safety tab to share your live location "
                        + "with a trusted contact while you wait for assistance.")
                .setNegativeButton(R.string.action_close, null)
                .setPositiveButton("Call 112", (dialog, which) -> Navigator.dial(requireContext(), "112"))
                .show();
    }

    @Override
    public void onReserveStop(String stationId, String stationName) {
        ReservationFragment fragment = new ReservationFragment();
        Bundle args = new Bundle();
        args.putString(ReservationFragment.ARG_STATION_ID, stationId);
        fragment.setArguments(args);
        Navigator.open(this, fragment, "reserve");
    }

    private List<RouteStop> toStops(String planId, RoutePlannerEngine.RoutePlanResult result) {
        List<RouteStop> stops = new ArrayList<>();
        int sequence = 1;
        for (RoutePlannerEngine.PlannedStop stop : result.getPlannedStops()) {
            stops.add(new RouteStop(UUID.randomUUID().toString(), planId, sequence++,
                    stop.getStation().getId(), stop.getStation().getName(), false, stop.isReachable(),
                    stop.getDistanceAlongRouteKm(), stop.getDetourKm(), stop.getDetourMinutes(),
                    stop.getArrivalSoc(), stop.getDepartureSoc(), stop.getEnergyAddedKwh(),
                    stop.getChargingMinutes(), stop.getEstimatedCost(), stop.getRecommendationReason(), null));
        }
        for (RoutePlannerEngine.PlannedStop stop : result.getBackups()) {
            stops.add(new RouteStop(UUID.randomUUID().toString(), planId, sequence++,
                    stop.getStation().getId(), stop.getStation().getName(), true, stop.isReachable(),
                    stop.getDistanceAlongRouteKm(), stop.getDetourKm(), stop.getDetourMinutes(),
                    stop.getArrivalSoc(), stop.getDepartureSoc(), stop.getEnergyAddedKwh(),
                    stop.getChargingMinutes(), stop.getEstimatedCost(), stop.getRecommendationReason(), null));
        }
        return stops;
    }

    private String join(List<String> values) {
        StringBuilder builder = new StringBuilder();
        for (String value : values) {
            if (builder.length() > 0) {
                builder.append("\n");
            }
            builder.append("• ").append(value);
        }
        return builder.toString();
    }

    private int safeInt(String value) {
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    private static class PlanBundle {
        private final RoutePlannerEngine.RoutePlanResult result;
        private final RoutePlan plan;
        private final List<ChargerStation> stations;
        private final boolean knownPlaces;
        private final boolean fromProfile;

        PlanBundle(RoutePlannerEngine.RoutePlanResult result, RoutePlan plan,
                   List<ChargerStation> stations, boolean knownPlaces, boolean fromProfile) {
            this.result = result;
            this.plan = plan;
            this.stations = stations;
            this.knownPlaces = knownPlaces;
            this.fromProfile = fromProfile;
        }
    }
}
