package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.TextView;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.ui.Ux;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.google.android.material.textfield.TextInputLayout;

import java.util.Locale;
import java.util.UUID;

public class VehicleProfileFragment extends Fragment {

    private static final String[] CONNECTORS = {"TYPE_2_AC", "CCS_2_DC", "GB_T", "CHADEMO"};
    private static final String[] CONNECTOR_LABELS = {"Type 2 (AC)", "CCS 2 (DC)", "GB/T", "CHAdeMO"};

    private AmperlyRepository repo;
    private EditText makeEdit;
    private EditText modelEdit;
    private EditText variantEdit;
    private EditText yearEdit;
    private EditText capacityEdit;
    private EditText maxAcEdit;
    private EditText maxDcEdit;
    private EditText efficiencyEdit;
    private EditText healthEdit;
    private EditText minArrivalEdit;
    private EditText maxChargeEdit;
    private EditText plateEdit;
    private TextInputLayout makeField;
    private TextInputLayout modelField;
    private MaterialAutoCompleteTextView connectorDropdown;
    private TextView derivedText;
    private String vehicleId;
    /** The choice the removed Spinner used to hold as its selected position. */
    private int connectorIndex;

    /** Field values as they were loaded, so Back can tell an edit from an untouched form. */
    @Nullable
    private String baseline;

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

        makeEdit = view.findViewById(R.id.makeEdit);
        modelEdit = view.findViewById(R.id.modelEdit);
        variantEdit = view.findViewById(R.id.variantEdit);
        yearEdit = view.findViewById(R.id.yearEdit);
        capacityEdit = view.findViewById(R.id.capacityEdit);
        maxAcEdit = view.findViewById(R.id.maxAcEdit);
        maxDcEdit = view.findViewById(R.id.maxDcEdit);
        efficiencyEdit = view.findViewById(R.id.efficiencyEdit);
        healthEdit = view.findViewById(R.id.healthEdit);
        minArrivalEdit = view.findViewById(R.id.minArrivalEdit);
        maxChargeEdit = view.findViewById(R.id.maxChargeEdit);
        plateEdit = view.findViewById(R.id.plateEdit);
        makeField = view.findViewById(R.id.makeField);
        modelField = view.findViewById(R.id.modelField);
        connectorDropdown = view.findViewById(R.id.connectorDropdown);
        derivedText = view.findViewById(R.id.vehicleDerivedText);

        connectorDropdown.setAdapter(new ArrayAdapter<>(requireContext(),
                R.layout.item_dropdown, CONNECTOR_LABELS));
        connectorDropdown.setText(CONNECTOR_LABELS[0], false);
        connectorDropdown.setOnItemClickListener((parent, v, position, id) -> connectorIndex = position);
        clearErrorsWhileEditing();
        guardBackWhileEditing();

        String userId = AuthManager.getInstance().getCurrentUserId();
        repo.background(() -> repo.getVehicleSync(userId), vehicle -> {
            if (!isAdded()) {
                return;
            }
            if (vehicle == null) {
                vehicleId = UUID.randomUUID().toString();
                derivedText.setText(R.string.vehicle_empty_hint);
                baseline = snapshot();
                return;
            }
            vehicleId = vehicle.getId();
            makeEdit.setText(vehicle.getMake());
            modelEdit.setText(vehicle.getModel());
            variantEdit.setText(vehicle.getVariant());
            yearEdit.setText(String.valueOf(vehicle.getPurchaseYear()));
            capacityEdit.setText(String.format(Locale.US, "%.1f", vehicle.getBatteryCapacityKwh()));
            maxAcEdit.setText(String.format(Locale.US, "%.1f", vehicle.getMaxAcKw()));
            maxDcEdit.setText(String.format(Locale.US, "%.1f", vehicle.getMaxDcKw()));
            efficiencyEdit.setText(String.format(Locale.US, "%.1f", vehicle.getTypicalEfficiencyKmPerKwh()));
            healthEdit.setText(String.format(Locale.US, "%.0f", vehicle.getBatteryHealthPercent()));
            minArrivalEdit.setText(String.valueOf(vehicle.getMinArrivalSocPercent()));
            maxChargeEdit.setText(String.valueOf(vehicle.getMaxChargeSocPercent()));
            plateEdit.setText(vehicle.getLicensePlate());
            connectorIndex = indexOf(vehicle.getConnectorType());
            connectorDropdown.setText(CONNECTOR_LABELS[connectorIndex], false);
            AppStateStore.get().setVehicle(vehicle);
            updateDerived(vehicle);
            baseline = snapshot();
        });

        view.findViewById(R.id.saveVehicleButton).setOnClickListener(v -> save(userId));
        buildDerivedPreview();
    }

    /**
     * Asks before Back throws away typed edits.
     *
     * <p>The form is long enough that a stray gesture loses a minute of typing, and nothing else
     * on this screen persists until Save is pressed. The guard only speaks when something changed.
     */
    private void guardBackWhileEditing() {
        requireActivity().getOnBackPressedDispatcher().addCallback(getViewLifecycleOwner(),
                new OnBackPressedCallback(true) {
                    @Override
                    public void handleOnBackPressed() {
                        if (!hasUnsavedChanges()) {
                            setEnabled(false);
                            requireActivity().getOnBackPressedDispatcher().onBackPressed();
                            return;
                        }
                        new MaterialAlertDialogBuilder(requireContext())
                                .setTitle(R.string.unsaved_changes_title)
                                .setMessage(R.string.unsaved_changes_body)
                                .setNegativeButton(R.string.unsaved_changes_keep, null)
                                .setPositiveButton(R.string.unsaved_changes_discard,
                                        (dialog, which) -> {
                                            setEnabled(false);
                                            requireActivity().getOnBackPressedDispatcher()
                                                    .onBackPressed();
                                        })
                                .show();
                    }
                });
    }

    private boolean hasUnsavedChanges() {
        return baseline != null && !snapshot().equals(baseline);
    }

    /** Everything the driver can change, in one comparable string. */
    private String snapshot() {
        StringBuilder out = new StringBuilder();
        for (EditText field : new EditText[]{makeEdit, modelEdit, variantEdit, yearEdit,
                capacityEdit, maxAcEdit, maxDcEdit, efficiencyEdit, healthEdit,
                minArrivalEdit, maxChargeEdit, plateEdit}) {
            out.append(field == null ? "" : field.getText().toString()).append('\u0001');
        }
        return out.append(connectorIndex).toString();
    }

    private int indexOf(String connector) {
        for (int i = 0; i < CONNECTORS.length; i++) {
            if (CONNECTORS[i].equalsIgnoreCase(connector)) {
                return i;
            }
        }
        return 0;
    }

    /** A field-level error disappears the moment the driver starts correcting the field. */
    private void clearErrorsWhileEditing() {
        makeEdit.addTextChangedListener(clearOnEdit(makeField));
        modelEdit.addTextChangedListener(clearOnEdit(modelField));
    }

    private TextWatcher clearOnEdit(final TextInputLayout field) {
        return new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (field != null) {
                    field.setError(null);
                }
            }
        };
    }

    private void buildDerivedPreview() {
        View.OnFocusChangeListener listener = (v, hasFocus) -> {
            if (!hasFocus) {
                derivedText.setText(deriveText());
            }
        };
        capacityEdit.setOnFocusChangeListener(listener);
        efficiencyEdit.setOnFocusChangeListener(listener);
        healthEdit.setOnFocusChangeListener(listener);
    }

    private String deriveText() {
        try {
            double capacity = parseDouble(capacityEdit.getText().toString(), 40);
            double efficiency = parseDouble(efficiencyEdit.getText().toString(), 6.5);
            double health = parseDouble(healthEdit.getText().toString(), 100);
            double effectiveCapacity = capacity * (health / 100.0);
            return getString(R.string.vehicle_planning_from_inputs, effectiveCapacity,
                    effectiveCapacity * efficiency);
        } catch (Exception e) {
            return getString(R.string.vehicle_planning_default);
        }
    }

    private void updateDerived(Vehicle vehicle) {
        derivedText.setText(getString(R.string.vehicle_planning_line,
                vehicle.effectiveCapacityKwh(), vehicle.effectiveEfficiencyKmPerKwh(),
                vehicle.effectiveCapacityKwh() * vehicle.effectiveEfficiencyKmPerKwh()));
    }

    private void save(String userId) {
        String make = makeEdit.getText().toString().trim();
        String model = modelEdit.getText().toString().trim();
        if (TextUtils.isEmpty(make) || TextUtils.isEmpty(model)) {
            if (TextUtils.isEmpty(make) && makeField != null) {
                makeField.setError(getString(R.string.vehicle_error_make_model));
                makeEdit.requestFocus();
            }
            if (TextUtils.isEmpty(model) && modelField != null) {
                modelField.setError(getString(R.string.vehicle_error_make_model));
            }
            return;
        }
        int year = safeInt(yearEdit.getText().toString(), 2023);
        double capacity = parseDouble(capacityEdit.getText().toString(), 40.5);
        double maxAc = parseDouble(maxAcEdit.getText().toString(), 7.2);
        double maxDc = parseDouble(maxDcEdit.getText().toString(), 30);
        double efficiency = parseDouble(efficiencyEdit.getText().toString(), 6.5);
        double health = parseDouble(healthEdit.getText().toString(),
                Vehicle.defaultHealthForYear(year));
        int minArrival = safeInt(minArrivalEdit.getText().toString(), 15);
        int maxCharge = safeInt(maxChargeEdit.getText().toString(), 80);
        String connector = CONNECTORS[connectorIndex >= 0 && connectorIndex < CONNECTORS.length
                ? connectorIndex : 0];

        Vehicle vehicle = new Vehicle(vehicleId == null ? UUID.randomUUID().toString() : vehicleId,
                userId, make, model, variantEdit.getText().toString().trim(), year, capacity,
                connector, maxAc, maxDc, efficiency, health, 0.0,
                Math.max(5, Math.min(40, minArrival)), Math.max(50, Math.min(100, maxCharge)),
                plateEdit.getText().toString().trim());

        repo.saveVehicle(vehicle);
        AppStateStore.get().setVehicle(vehicle);
        AppStateStore.get().setUserId(userId);
        updateDerived(vehicle);
        baseline = snapshot();
        Ux.success(this, getString(R.string.vehicle_saved));
    }

    private int safeInt(String value, int fallback) {
        try {
            return Integer.parseInt(value.trim());
        } catch (Exception e) {
            return fallback;
        }
    }

    private double parseDouble(String value, double fallback) {
        try {
            return Double.parseDouble(value.trim());
        } catch (Exception e) {
            return fallback;
        }
    }
}
