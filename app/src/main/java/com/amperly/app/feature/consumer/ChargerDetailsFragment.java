package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.core.map.MapHelper;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.ChargerPort;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Report;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.availability.AvailabilityEngine;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.dialog.ReportDialog;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class ChargerDetailsFragment extends Fragment {

    public static final String ARG_STATION_ID = "station_id";

    private AmperlyRepository repo;
    private String stationId;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_charger_details, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());
        stationId = getArguments() == null ? null : getArguments().getString(ARG_STATION_ID);

        if (stationId == null) {
            Ux.toast(this, "No station selected.");
            return;
        }

        repo.background(() -> repo.getStationSync(stationId), station -> {
            if (station == null || !isAdded()) {
                Ux.toast(this, "Station not found.");
                return;
            }
            bind(view, station);
        });
    }

    private void bind(View view, ChargerStation station) {
        TextView name = view.findViewById(R.id.detailsNameText);
        TextView address = view.findViewById(R.id.detailsAddressText);
        TextView availability = view.findViewById(R.id.availabilityText);
        TextView freshness = view.findViewById(R.id.freshnessText);
        TextView verification = view.findViewById(R.id.verificationText);
        TextView gating = view.findViewById(R.id.meterGatingWarningText);
        TextView access = view.findViewById(R.id.accessText);
        TextView incident = view.findViewById(R.id.incidentText);
        TextView energyPrice = view.findViewById(R.id.energyPriceText);
        TextView serviceFee = view.findViewById(R.id.serviceFeeText);
        TextView gatewayFee = view.findViewById(R.id.gatewayFeeText);
        TextView total = view.findViewById(R.id.totalPerKwhText);
        LinearLayout portsContainer = view.findViewById(R.id.portsContainer);
        FrameLayout mapContainer = view.findViewById(R.id.detailsMapContainer);

        name.setText(station.getName());
        address.setText(station.getAddress());

        ArrayList<ChargerPort> ports = new ArrayList<>();
        repo.background(() -> {
            ports.addAll(repo.getPortsSync(station.getId()));
            return repo.getAvailabilitySummary(station.getId());
        }, summary -> {
            if (summary == null || !isAdded()) {
                return;
            }
            availability.setText(summary.getLabel());
            freshness.setText(getString(R.string.label_availability_freshness,
                    Formatters.agoFromNow(summary.getLastUpdatedMs())));
        });

        verification.setText(verificationLabel(station));
        gating.setVisibility(station.supportsPaidEnergyBilling() ? View.GONE : View.VISIBLE);
        access.setText(station.getAccessRules() == null ? "No access instructions published yet."
                : station.getAccessRules());
        incident.setText("Reliability " + (int) station.getReliabilityScore() + "% · rating "
                + String.format(Locale.US, "%.1f", station.getRating()) + " ★ · incidents: "
                + station.getIncidentCount()
                + (station.getHostName() == null ? "" : "\nHost: " + station.getHostName()));

        energyPrice.setText(Formatters.money(station.getPricePerKwh()));
        serviceFee.setText(Formatters.money(station.getServiceFee()));
        gatewayFee.setText(Formatters.money(station.getGatewayFee()));
        total.setText(Formatters.money(station.getPricePerKwh() + station.getServiceFee()
                + station.getGatewayFee()));

        portsContainer.removeAllViews();
        for (ChargerPort port : ports) {
            View row = LayoutInflater.from(requireContext()).inflate(R.layout.item_port, portsContainer, false);
            TextView label = row.findViewById(R.id.portLabelText);
            TextView status = row.findViewById(R.id.portStatusText);
            label.setText(AvailabilityEngine.portLabel(port) + " · "
                    + (port.isDc() ? "DC fast" : "AC"));
            status.setText(port.getStatus());
            portsContainer.addView(row);
        }
        if (ports.isEmpty()) {
            TextView empty = new TextView(requireContext());
            empty.setText("No ports published for this station yet.");
            portsContainer.addView(empty);
        }

        MapHelper.attach(this, mapContainer, map ->
                MapHelper.plotStations(map, Collections.singletonList(station), station.getId()));

        view.findViewById(R.id.reserveButton).setOnClickListener(v -> {
            ReservationFragment fragment = new ReservationFragment();
            Bundle args = new Bundle();
            args.putString(ReservationFragment.ARG_STATION_ID, station.getId());
            fragment.setArguments(args);
            Navigator.open(this, fragment, "reserve");
        });

        view.findViewById(R.id.navigateDetailsButton).setOnClickListener(v ->
                Navigator.navigateTo(requireContext(), station.getLatitude(), station.getLongitude(),
                        station.getName()));

        view.findViewById(R.id.reportButton).setOnClickListener(v ->
                ReportDialog.show(this, getString(R.string.report_title), null, (type, details) -> {
                    Report report = new Report(UUID.randomUUID().toString(),
                            AuthManager.getInstance().getCurrentUserId(),
                            AuthManager.getInstance().getCurrentUser().getName(),
                            station.getId(), station.getHostId(), null, type,
                            details == null || details.isEmpty() ? "(no details provided)" : details,
                            "OPEN", System.currentTimeMillis());
                    repo.saveReport(report);
                    Ux.toast(this, getString(R.string.report_submitted));
                }));
    }

    private String verificationLabel(ChargerStation station) {
        if (AppConstants.LEVEL_2_SIMULATED_SMART_METER.equals(station.getVerificationLevel())) {
            return getString(R.string.label_meter_level_2);
        }
        if (AppConstants.LEVEL_3_NO_VERIFIED_METER.equals(station.getVerificationLevel())) {
            return getString(R.string.label_meter_level_3);
        }
        return getString(R.string.label_meter_level_1);
    }
}
