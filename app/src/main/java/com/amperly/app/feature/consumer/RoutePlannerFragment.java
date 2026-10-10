package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.engine.routing.RoutePlannerEngine;
import com.amperly.app.engine.soc.SoCEstimatorEngine;

import java.util.ArrayList;
import java.util.List;

public class RoutePlannerFragment extends Fragment {

    private EditText originEdit, destinationEdit, startSocEdit, actualSocEdit;
    private TextView routeSummaryText;
    private Button planRouteBtn, updateActualSocBtn;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_route_planner, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        originEdit = view.findViewById(R.id.originEdit);
        destinationEdit = view.findViewById(R.id.destinationEdit);
        startSocEdit = view.findViewById(R.id.startSocEdit);
        actualSocEdit = view.findViewById(R.id.actualSocEdit);
        routeSummaryText = view.findViewById(R.id.routeSummaryText);
        planRouteBtn = view.findViewById(R.id.planRouteBtn);
        updateActualSocBtn = view.findViewById(R.id.updateActualSocBtn);

        planRouteBtn.setOnClickListener(v -> executeRoutePlan());
        updateActualSocBtn.setOnClickListener(v -> executeSocOverride());

        executeRoutePlan();
    }

    private void executeRoutePlan() {
        String origin = originEdit.getText().toString().trim();
        String destination = destinationEdit.getText().toString().trim();
        int soc = 100;
        try {
            soc = Integer.parseInt(startSocEdit.getText().toString().trim());
        } catch (Exception ignored) {}

        Vehicle mockVehicle = new Vehicle("v1", "u1", "Tata", "Nexon EV", "Max", 2023, 40.5, "CCS_2_DC", 7.2, 30.0, 6.5, 2.5, 15, 80, "KA09EV1234");
        List<ChargerStation> mockStations = new ArrayList<>();
        mockStations.add(new ChargerStation("s1", "h1", "Highway Hub Charger", "Mysore-Mangalore Rd", 12.3, 76.6, "COMMERCIAL", "24/7", 18.0, 5.0, 4.0, "LEVEL_1", true, false, 4.8, System.currentTimeMillis()));
        mockStations.add(new ChargerStation("s2", "h2", "GreenPark Station", "Madikeri Bypass", 12.4, 75.7, "APARTMENT", "24/7", 16.0, 5.0, 4.0, "LEVEL_1", true, false, 4.5, System.currentTimeMillis()));

        RoutePlannerEngine.RoutePlanResult result = RoutePlannerEngine.planRoute(origin, destination, 140.0, soc, mockVehicle, mockStations);

        StringBuilder sb = new StringBuilder();
        sb.append("Route: ").append(result.getOrigin()).append(" -> ").append(result.getDestination()).append("\n");
        sb.append("Total Distance: ").append(result.getTotalDistanceKm()).append(" km (~").append(result.getEstimatedDriveMins()).append(" mins)\n");
        if (result.getRecommendedStop() != null) {
            RoutePlannerEngine.CandidateEvaluation rec = result.getRecommendedStop();
            sb.append("\nRECOMMENDED STOP:\n");
            sb.append("Station: ").append(rec.getStation().getName()).append("\n");
            sb.append("Detour: +").append(rec.getDetourKm()).append(" km / +").append(rec.getDetourMins()).append(" mins\n");
            sb.append("Expected Arrival Battery: ").append(rec.getExpectedArrivalSoc()).append("%\n");
            sb.append("Estimated Charge Time: ").append(rec.getChargingTimeMins()).append(" mins (+").append(rec.getEnergyAddedKwh()).append(" kWh)\n");
            sb.append("Expected Arrival at Destination: ").append(rec.getFinalArrivalSoc()).append("%\n");
        }
        routeSummaryText.setText(sb.toString());
    }

    private void executeSocOverride() {
        String text = actualSocEdit.getText().toString().trim();
        if (TextUtils.isEmpty(text)) {
            Toast.makeText(getContext(), "Please enter actual dashboard SoC %", Toast.LENGTH_SHORT).show();
            return;
        }
        int actualSoc = Integer.parseInt(text);
        Vehicle mockVehicle = new Vehicle("v1", "u1", "Tata", "Nexon EV", "Max", 2023, 40.5, "CCS_2_DC", 7.2, 30.0, 6.5, 2.5, 15, 80, "KA09EV1234");
        List<ChargerStation> mockStations = new ArrayList<>();
        mockStations.add(new ChargerStation("s1", "h1", "Highway Hub Charger", "Mysore-Mangalore Rd", 12.3, 76.6, "COMMERCIAL", "24/7", 18.0, 5.0, 4.0, "LEVEL_1", true, false, 4.8, System.currentTimeMillis()));

        SoCEstimatorEngine.RecalculationResult result = SoCEstimatorEngine.applyAuthoritativeSocOverride(
                "v1", "trip1", 35, actualSoc, 60.0, 80.0, 12.3, 76.6, mockVehicle, mockStations
        );

        StringBuilder sb = new StringBuilder();
        sb.append("AUTHORITATIVE DASHBOARD OVERRIDE APPLIED:\n");
        sb.append("Previous Estimated SoC: 35% -> Actual Dashboard SoC: ").append(result.getActualDashboardSoc()).append("%\n");
        if (result.getRecommendedNextCharger() != null) {
            sb.append("Safe Next Charger: ").append(result.getRecommendedNextCharger().getName()).append("\n");
        }
        if (result.getWarningMessage() != null) {
            sb.append("\n").append(result.getWarningMessage()).append("\n");
        }
        routeSummaryText.setText(sb.toString());
        Toast.makeText(getContext(), "Remaining route recalculated using " + actualSoc + "% SoC", Toast.LENGTH_SHORT).show();
    }
}
