package com.amperly.app.feature.host;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.AvailabilitySchedule;
import com.amperly.app.data.local.entity.ChargerPort;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Notification;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.meter.MeterSimulator;
import com.amperly.app.ui.Ux;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.UUID;

/**
 * Registers an existing charger. The station is submitted as PENDING and only goes live after an
 * administrator verifies it — nothing is promised to consumers before that.
 */
public class RegisterStationFragment extends Fragment {

    private static final String[] LOCATION_TYPES = {"CAMPUS", "APARTMENT", "OFFICE", "CAFE",
            "HOTEL", "PARKING", "PETROL_PUMP", "COMMERCIAL"};
    private static final String[] LOCATION_LABELS = {"Campus", "Apartment", "Office", "Café", "Hotel",
            "Parking", "Petrol pump", "Commercial"};
    private static final String[] METER_LEVELS = {"LEVEL_1", "LEVEL_2", "LEVEL_3"};
    private static final String[] METER_LABELS = {
            "Level 1 — visible/connected manual meter",
            "Level 2 — integrated smart meter (simulated)",
            "Level 3 — no verified meter (discovery only)"};
    private static final String[] CONNECTORS = {"TYPE_2_AC", "CCS_2_DC", "GB_T", "CHADEMO"};

    private AmperlyRepository repo;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_register_station, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());

        ((Spinner) view.findViewById(R.id.locationTypeSpinner)).setAdapter(new ArrayAdapter<>(
                requireContext(), android.R.layout.simple_spinner_dropdown_item, LOCATION_LABELS));
        ((Spinner) view.findViewById(R.id.meterLevelSpinner)).setAdapter(new ArrayAdapter<>(
                requireContext(), android.R.layout.simple_spinner_dropdown_item, METER_LABELS));
        ((Spinner) view.findViewById(R.id.portConnectorSpinner)).setAdapter(new ArrayAdapter<>(
                requireContext(), android.R.layout.simple_spinner_dropdown_item, CONNECTORS));

        view.findViewById(R.id.saveStationButton).setOnClickListener(v -> save(view));
    }

    private void save(View view) {
        if (!AppConstants.ROLE_HOST.equals(AuthManager.getInstance().getCurrentRole())
                && !AppConstants.ROLE_ADMIN.equals(AuthManager.getInstance().getCurrentRole())) {
            Ux.toast(this, "Switch to Host mode to register a charger.");
            return;
        }

        String name = text(view, R.id.stationNameEdit);
        String address = text(view, R.id.addressEdit);
        if (TextUtils.isEmpty(name) || TextUtils.isEmpty(address)) {
            Ux.toast(this, "Station name and address are required.");
            return;
        }
        double latitude = parse(text(view, R.id.latitudeEdit), AppConstants.PILOT_CENTER_LAT);
        double longitude = parse(text(view, R.id.longitudeEdit), AppConstants.PILOT_CENTER_LNG);
        double price = parse(text(view, R.id.priceEdit), AppConstants.DEFAULT_TARIFF_INR_PER_KWH);
        double serviceFee = parse(text(view, R.id.serviceFeeEdit), AppConstants.DEFAULT_SERVICE_FEE_INR);
        double gatewayFee = parse(text(view, R.id.gatewayFeeEdit), AppConstants.DEFAULT_GATEWAY_FEE_INR);
        int portCount = (int) parse(text(view, R.id.portCountEdit), 1);
        double portPower = parse(text(view, R.id.portPowerEdit), 7.2);
        String connector = CONNECTORS[((Spinner) view.findViewById(R.id.portConnectorSpinner))
                .getSelectedItemPosition()];
        boolean dc = ((CheckBox) view.findViewById(R.id.portDcCheck)).isChecked();
        String locationType = LOCATION_TYPES[((Spinner) view.findViewById(R.id.locationTypeSpinner))
                .getSelectedItemPosition()];
        String meterLevel = METER_LEVELS[((Spinner) view.findViewById(R.id.meterLevelSpinner))
                .getSelectedItemPosition()];
        String hours = text(view, R.id.hoursEdit);
        String access = text(view, R.id.accessRulesEdit);

        User host = AuthManager.getInstance().getCurrentUser();
        String stationId = UUID.randomUUID().toString();
        long now = System.currentTimeMillis();

        ChargerStation station = new ChargerStation(stationId, host.getId(), host.getName(), name, address,
                latitude, longitude, locationType, TextUtils.isEmpty(hours) ? "08:00 - 20:00" : hours,
                price, serviceFee, gatewayFee, meterLevel, false, false,
                AppConstants.APPROVAL_PENDING, "",
                connector, portPower, dc, Math.max(1, portCount),
                TextUtils.isEmpty(access) ? "Contact the host on arrival." : access,
                0.0, 0.0, 0, now);

        List<ChargerPort> ports = new ArrayList<>();
        for (int i = 1; i <= Math.max(1, portCount); i++) {
            ports.add(new ChargerPort(UUID.randomUUID().toString(), stationId, String.valueOf(i),
                    connector, portPower, dc, AppConstants.PORT_AVAILABLE));
        }

        List<AvailabilitySchedule> schedules = new ArrayList<>();
        int open = 8 * 60;
        int close = 20 * 60;
        for (ChargerPort port : ports) {
            for (int day = Calendar.SUNDAY; day <= Calendar.SATURDAY; day++) {
                schedules.add(new AvailabilitySchedule(port.getId() + "_d" + day, stationId,
                        port.getId(), day, open, close, false, null, now));
            }
        }

        repo.background(() -> {
            repo.saveStation(station);
            repo.savePorts(ports);
            repo.saveSchedules(schedules);
            MeterSimulator.setReading(stationId, 100.0 + (Math.random() * 50.0));

            for (User admin : repo.getAllUsersSync()) {
                if (AppConstants.ROLE_ADMIN.equals(admin.getRole())) {
                    repo.saveNotification(new Notification(UUID.randomUUID().toString(), admin.getId(),
                            "Station awaiting verification", name + " was submitted by " + host.getName()
                            + " (" + meterLevel + ").", false, System.currentTimeMillis()));
                }
            }
            return stationId;
        }, id -> {
            if (!isAdded() || id == null) {
                return;
            }
            ((TextView) requireView().findViewById(R.id.registerStatusText)).setText(
                    getString(R.string.host_station_saved) + "\nAvailability last updated just now. "
                            + "Stations without a verified meter are published for discovery only.");
            Ux.toast(this, getString(R.string.host_station_saved));
            Navigator.openRoot(requireActivity(), new HostDashboardFragment(), "host_dashboard");
        });
    }

    private String text(View view, int id) {
        EditText edit = view.findViewById(id);
        return edit == null ? "" : edit.getText().toString().trim();
    }

    private double parse(String value, double fallback) {
        try {
            return Double.parseDouble(value);
        } catch (Exception e) {
            return fallback;
        }
    }
}
