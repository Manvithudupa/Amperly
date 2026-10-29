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
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.ui.Ux;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.google.android.material.textfield.TextInputLayout;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * One vehicle, on its own screen.
 *
 * <p>Opened from a card in the garage to edit that profile, or from Add a car with no id to create
 * a new one. Saving writes the profile and makes it the one in use, exactly as selecting a car used
 * to; deleting promotes another profile so planning never runs without a vehicle. Leaving with
 * unsaved edits asks before they are thrown away.
 */
public class VehicleFormFragment extends Fragment {

    private static final String ARG_VEHICLE_ID = "vehicle_id";

    private static final String[] CONNECTORS = {"TYPE_2_AC", "CCS_2_DC", "GB_T", "CHADEMO"};
    private static final String[] CONNECTOR_LABELS = {"Type 2 (AC)", "CCS 2 (DC)", "GB/T", "CHAdeMO"};

    private AmperlyRepository repo;
    private String userId;

    private TextView titleText;
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
    private MaterialButton deleteButton;

    /** The profile being edited, or null while a new one is being entered. */
    @Nullable
    private Vehicle vehicle;

    private int connectorIndex;

    /** Field values as they were loaded, so Back can tell an edit from an untouched form. */
    @Nullable
    private String baseline;

    public static VehicleFormFragment newInstance(@Nullable String vehicleId) {
        VehicleFormFragment fragment = new VehicleFormFragment();
        Bundle args = new Bundle();
        args.putString(ARG_VEHICLE_ID, vehicleId);
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_vehicle_form, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());
        userId = AuthManager.getInstance().getCurrentUserId();

        titleText = view.findViewById(R.id.vehicleFormTitle);
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
        deleteButton = view.findViewById(R.id.deleteVehicleButton);

        connectorDropdown.setAdapter(new ArrayAdapter<>(requireContext(),
                R.layout.item_dropdown, CONNECTOR_LABELS));
        connectorDropdown.setText(CONNECTOR_LABELS[0], false);
        connectorDropdown.setOnItemClickListener((parent, v, position, id) -> connectorIndex = position);
        clearErrorsWhileEditing();
        guardBackWhileEditing();
        // Every field lifts itself above the keyboard once it takes focus.
        Ux.keepFieldsVisible(view);
        buildDerivedPreview();

        view.findViewById(R.id.saveVehicleButton).setOnClickListener(v -> save());
        deleteButton.setOnClickListener(v -> confirmDelete());

        String vehicleId = getArguments() == null ? null : getArguments().getString(ARG_VEHICLE_ID);
        if (TextUtils.isEmpty(vehicleId)) {
            startNewVehicle();
        } else {
            loadVehicle(vehicleId);
        }
    }

    private void loadVehicle(@NonNull String vehicleId) {
        repo.background(() -> repo.database().vehicleDao().getByIdSync(vehicleId), loaded -> {
            if (!isAdded()) {
                return;
            }
            if (loaded == null) {
                // The profile was deleted on another device; start a fresh one rather than
                // leaving a form that can never save over the row it names.
                startNewVehicle();
                return;
            }
            vehicle = loaded;
            fillForm(loaded);
            updateDerived(loaded);
            titleText.setText(R.string.vehicle_form_title_edit);
            deleteButton.setVisibility(View.VISIBLE);
            baseline = snapshot();
        });
    }

    private void startNewVehicle() {
        vehicle = null;
        clearForm();
        titleText.setText(R.string.vehicle_form_title_new);
        deleteButton.setVisibility(View.GONE);
        derivedText.setText(R.string.vehicle_new_hint);
        baseline = snapshot();
    }

    // ------------------------------------------------------------------- form

    private void fillForm(Vehicle loaded) {
        makeEdit.setText(loaded.getMake());
        modelEdit.setText(loaded.getModel());
        variantEdit.setText(loaded.getVariant());
        yearEdit.setText(String.valueOf(loaded.getPurchaseYear()));
        capacityEdit.setText(String.format(Locale.US, "%.1f", loaded.getBatteryCapacityKwh()));
        maxAcEdit.setText(String.format(Locale.US, "%.1f", loaded.getMaxAcKw()));
        maxDcEdit.setText(String.format(Locale.US, "%.1f", loaded.getMaxDcKw()));
        efficiencyEdit.setText(String.format(Locale.US, "%.1f",
                loaded.getTypicalEfficiencyKmPerKwh()));
        healthEdit.setText(String.format(Locale.US, "%.0f", loaded.getBatteryHealthPercent()));
        minArrivalEdit.setText(String.valueOf(loaded.getMinArrivalSocPercent()));
        maxChargeEdit.setText(String.valueOf(loaded.getMaxChargeSocPercent()));
        plateEdit.setText(loaded.getLicensePlate());
        connectorIndex = indexOf(loaded.getConnectorType());
        connectorDropdown.setText(CONNECTOR_LABELS[connectorIndex], false);
    }

    private void clearForm() {
        for (EditText field : new EditText[]{makeEdit, modelEdit, variantEdit, yearEdit,
                capacityEdit, maxAcEdit, maxDcEdit, efficiencyEdit, healthEdit,
                minArrivalEdit, maxChargeEdit, plateEdit}) {
            if (field != null) {
                field.setText("");
            }
        }
        connectorIndex = 0;
        connectorDropdown.setText(CONNECTOR_LABELS[0], false);
        if (makeField != null) makeField.setError(null);
        if (modelField != null) modelField.setError(null);
    }

    /**
     * Asks before Back throws away typed edits.
     *
     * <p>The form is long enough that a stray gesture loses a minute of typing, and nothing here
     * persists until Save is pressed. The guard only speaks when something changed.
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
        // The form-wide focus handler is kept underneath, so these fields both refresh the
        // preview and scroll themselves clear of the keyboard.
        Ux.keepVisibleOnFocus(capacityEdit, listener);
        Ux.keepVisibleOnFocus(efficiencyEdit, listener);
        Ux.keepVisibleOnFocus(healthEdit, listener);
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

    private void updateDerived(Vehicle loaded) {
        derivedText.setText(getString(R.string.vehicle_planning_line,
                loaded.effectiveCapacityKwh(), loaded.effectiveEfficiencyKmPerKwh(),
                loaded.effectiveCapacityKwh() * loaded.effectiveEfficiencyKmPerKwh()));
    }

    // ------------------------------------------------------------------- save

    private void save() {
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

        // Saving a profile selects it: the car being edited is the car being driven.
        Vehicle saved = new Vehicle(vehicle == null ? UUID.randomUUID().toString() : vehicle.getId(),
                userId, make, model, variantEdit.getText().toString().trim(), year, capacity,
                connector, maxAc, maxDc, efficiency, health, 0.0,
                Math.max(5, Math.min(40, minArrival)), Math.max(50, Math.min(100, maxCharge)),
                plateEdit.getText().toString().trim(), true);

        repo.saveVehicle(saved);
        AppStateStore.get().setVehicle(saved);
        AppStateStore.get().setUserId(userId);
        Ux.success(this, getString(R.string.vehicle_saved));
        close();
    }

    private void close() {
        if (!Navigator.pop(this)) {
            Navigator.openRoot(requireActivity(), new VehicleProfileFragment(), "vehicle");
        }
    }

    // ----------------------------------------------------------------- delete

    private void confirmDelete() {
        if (vehicle == null) {
            return;
        }
        new MaterialAlertDialogBuilder(requireContext())
                .setTitle(getString(R.string.vehicle_delete_title, vehicle.displayName()))
                .setMessage(R.string.vehicle_delete_body)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.vehicle_delete, (dialog, which) -> delete())
                .show();
    }

    private void delete() {
        if (vehicle == null) {
            return;
        }
        repo.deleteVehicle(vehicle, remaining -> {
            if (!isAdded() || remaining == null) {
                return;
            }
            AppStateStore.get().setVehicle(activeOf(remaining));
            Ux.toast(this, getString(R.string.vehicle_deleted));
            close();
        });
    }

    @Nullable
    private static Vehicle activeOf(List<Vehicle> vehicles) {
        for (Vehicle candidate : vehicles) {
            if (candidate.isActive()) {
                return candidate;
            }
        }
        return vehicles.isEmpty() ? null : vehicles.get(0);
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
