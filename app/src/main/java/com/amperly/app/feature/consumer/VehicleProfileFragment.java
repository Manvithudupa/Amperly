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
import com.google.android.material.button.MaterialButton;
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.google.android.material.textfield.TextInputLayout;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * The vehicle garage.
 *
 * <p>An account can keep more than one EV — a second car, a van — and each has its own battery,
 * connector and preferences. Every saved profile is a row in {@code vehicles}; exactly one of
 * them carries {@code isActive}, and that is the profile every range, compatibility and
 * reservation rule is evaluated against. Picking a chip here switches the active profile, so
 * the plan follows the car the driver is actually in.
 *
 * <p>The screen edits one profile at a time. Switching profile, adding a vehicle or leaving the
 * screen drops nothing silently: typed edits are only discarded after the driver says so.
 */
public class VehicleProfileFragment extends Fragment {

    private static final String[] CONNECTORS = {"TYPE_2_AC", "CCS_2_DC", "GB_T", "CHADEMO"};
    private static final String[] CONNECTOR_LABELS = {"Type 2 (AC)", "CCS 2 (DC)", "GB/T", "CHAdeMO"};

    /** Tag on the Add chip, which is not a vehicle. */
    private static final String ADD_TAG = "__add_vehicle__";

    private AmperlyRepository repo;
    private String userId;

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
    private ChipGroup vehicleChipGroup;
    private TextView garageHintText;
    private TextView derivedText;
    private MaterialButton deleteButton;

    /** The profile currently in the form, or null when a new one is being entered. */
    @Nullable
    private String vehicleId;

    /** The garage as last read or written, so the chips never need a second round trip. */
    private final List<Vehicle> vehicles = new ArrayList<>();

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
        userId = AuthManager.getInstance().getCurrentUserId();

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
        vehicleChipGroup = view.findViewById(R.id.vehicleChipGroup);
        garageHintText = view.findViewById(R.id.vehicleGarageHint);
        derivedText = view.findViewById(R.id.vehicleDerivedText);
        deleteButton = view.findViewById(R.id.deleteVehicleButton);

        connectorDropdown.setAdapter(new ArrayAdapter<>(requireContext(),
                R.layout.item_dropdown, CONNECTOR_LABELS));
        connectorDropdown.setText(CONNECTOR_LABELS[0], false);
        connectorDropdown.setOnItemClickListener((parent, v, position, id) -> connectorIndex = position);
        clearErrorsWhileEditing();
        guardBackWhileEditing();
        buildDerivedPreview();

        view.findViewById(R.id.saveVehicleButton).setOnClickListener(v -> save());
        deleteButton.setOnClickListener(v -> confirmDelete());

        loadGarage(null);
    }

    // --------------------------------------------------------------- the garage

    /**
     * Reads every saved profile and opens one of them.
     *
     * @param preferredId the profile to show; the active one is used when null or gone.
     */
    private void loadGarage(@Nullable String preferredId) {
        repo.background(() -> repo.getVehiclesSync(userId), list -> {
            if (!isAdded() || list == null) {
                return;
            }
            vehicles.clear();
            vehicles.addAll(list);

            Vehicle selected = findById(preferredId);
            if (selected == null) {
                selected = activeVehicle();
            }
            if (selected == null && !vehicles.isEmpty()) {
                selected = vehicles.get(0);
            }

            if (selected == null) {
                startNewVehicle();
            } else {
                selectVehicle(selected);
            }
            renderChips();
            updateGarageHint();
            updateDeleteButton();
            baseline = snapshot();
        });
    }

    @Nullable
    private Vehicle findById(@Nullable String id) {
        if (id == null) {
            return null;
        }
        for (Vehicle vehicle : vehicles) {
            if (id.equals(vehicle.getId())) {
                return vehicle;
            }
        }
        return null;
    }

    @Nullable
    private Vehicle activeVehicle() {
        for (Vehicle vehicle : vehicles) {
            if (vehicle.isActive()) {
                return vehicle;
            }
        }
        return null;
    }

    /** One chip per saved profile, plus Add. The checked chip is the one in use. */
    private void renderChips() {
        if (vehicleChipGroup == null) {
            return;
        }
        vehicleChipGroup.removeAllViews();
        LayoutInflater inflater = LayoutInflater.from(requireContext());
        for (Vehicle vehicle : vehicles) {
            Chip chip = (Chip) inflater.inflate(R.layout.item_vehicle_chip, vehicleChipGroup,
                    false);
            chip.setText(chipLabel(vehicle));
            chip.setTag(vehicle.getId());
            chip.setChecked(vehicle.getId().equals(vehicleId));
            chip.setContentDescription(chip.getText());
            chip.setOnClickListener(v -> onVehiclePicked(vehicle));
            vehicleChipGroup.addView(chip);
        }
        // With an empty garage the form already is the new-vehicle form, so the extra chip
        // would only repeat it.
        if (!vehicles.isEmpty()) {
            Chip add = (Chip) inflater.inflate(R.layout.item_vehicle_chip, vehicleChipGroup, false);
            add.setTag(ADD_TAG);
            add.setCheckable(false);
            add.setChipIconResource(R.drawable.ic_add);
            add.setChipIconVisible(true);
            add.setText(R.string.vehicle_add);
            add.setOnClickListener(v -> onAddPicked());
            vehicleChipGroup.addView(add);
        }
    }

    private String chipLabel(Vehicle vehicle) {
        String plate = vehicle.getLicensePlate();
        String name = vehicle.displayName();
        if (plate == null || plate.trim().isEmpty() || name.equals(plate.trim())) {
            return name;
        }
        return name + " · " + plate.trim();
    }

    /** Tapping the chip of the profile already on screen does nothing. */
    private void onVehiclePicked(Vehicle vehicle) {
        if (vehicle.getId().equals(vehicleId)) {
            renderChips();
            return;
        }
        if (hasUnsavedChanges()) {
            // The chip was already toggled by the touch; put the checked state back until the
            // driver answers, so a cancelled switch leaves the picker showing reality.
            renderChips();
            confirmDiscard(() -> switchTo(vehicle));
            return;
        }
        switchTo(vehicle);
    }

    private void onAddPicked() {
        if (hasUnsavedChanges()) {
            renderChips();
            confirmDiscard(this::startNewVehicle);
            return;
        }
        startNewVehicle();
    }

    private void switchTo(Vehicle vehicle) {
        if (!isAdded()) {
            return;
        }
        selectVehicle(vehicle);
        renderChips();
        baseline = snapshot();
    }

    /** Opens a saved profile in the form and makes it the one the app plans against. */
    private void selectVehicle(Vehicle vehicle) {
        vehicleId = vehicle.getId();
        fillForm(vehicle);
        updateDerived(vehicle);
        AppStateStore.get().setUserId(userId);
        AppStateStore.get().setVehicle(vehicle);
        if (!vehicle.isActive() || countActive() > 1) {
            repo.setActiveVehicle(vehicle);
            for (Vehicle other : vehicles) {
                other.setActive(other.getId().equals(vehicle.getId()));
            }
        }
        updateDeleteButton();
        updateGarageHint();
    }

    private int countActive() {
        int active = 0;
        for (Vehicle vehicle : vehicles) {
            if (vehicle.isActive()) {
                active++;
            }
        }
        return active;
    }

    /** A blank form for the next vehicle. Nothing is written until Save. */
    private void startNewVehicle() {
        vehicleId = null;
        clearForm();
        setDerivedHint();
        AppStateStore.get().setUserId(userId);
        renderChips();
        updateDeleteButton();
        updateGarageHint();
        baseline = snapshot();
    }

    private void updateGarageHint() {
        if (garageHintText != null) {
            garageHintText.setVisibility(vehicles.isEmpty() ? View.GONE : View.VISIBLE);
        }
    }

    private void updateDeleteButton() {
        if (deleteButton != null) {
            deleteButton.setVisibility(findById(vehicleId) == null ? View.GONE : View.VISIBLE);
        }
    }

    private void confirmDelete() {
        Vehicle selected = findById(vehicleId);
        if (selected == null) {
            return;
        }
        new MaterialAlertDialogBuilder(requireContext())
                .setTitle(getString(R.string.vehicle_delete_title, selected.displayName()))
                .setMessage(R.string.vehicle_delete_body)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.vehicle_delete, (dialog, which) -> delete(selected))
                .show();
    }

    private void delete(Vehicle vehicle) {
        repo.deleteVehicle(vehicle, remaining -> {
            if (!isAdded() || remaining == null) {
                return;
            }
            vehicles.clear();
            vehicles.addAll(remaining);
            Vehicle next = activeVehicle();
            if (next == null && !vehicles.isEmpty()) {
                next = vehicles.get(0);
            }
            if (next == null) {
                AppStateStore.get().setVehicle(null);
                startNewVehicle();
            } else {
                selectVehicle(next);
            }
            renderChips();
            updateGarageHint();
            updateDeleteButton();
            baseline = snapshot();
            Ux.toast(this, getString(R.string.vehicle_deleted));
        });
    }

    // ------------------------------------------------------------------- form

    private void fillForm(Vehicle vehicle) {
        makeEdit.setText(vehicle.getMake());
        modelEdit.setText(vehicle.getModel());
        variantEdit.setText(vehicle.getVariant());
        yearEdit.setText(String.valueOf(vehicle.getPurchaseYear()));
        capacityEdit.setText(String.format(Locale.US, "%.1f", vehicle.getBatteryCapacityKwh()));
        maxAcEdit.setText(String.format(Locale.US, "%.1f", vehicle.getMaxAcKw()));
        maxDcEdit.setText(String.format(Locale.US, "%.1f", vehicle.getMaxDcKw()));
        efficiencyEdit.setText(String.format(Locale.US, "%.1f",
                vehicle.getTypicalEfficiencyKmPerKwh()));
        healthEdit.setText(String.format(Locale.US, "%.0f", vehicle.getBatteryHealthPercent()));
        minArrivalEdit.setText(String.valueOf(vehicle.getMinArrivalSocPercent()));
        maxChargeEdit.setText(String.valueOf(vehicle.getMaxChargeSocPercent()));
        plateEdit.setText(vehicle.getLicensePlate());
        connectorIndex = indexOf(vehicle.getConnectorType());
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

    /** Same question, for a switch that is about to replace the form's contents. */
    private void confirmDiscard(Runnable action) {
        new MaterialAlertDialogBuilder(requireContext())
                .setTitle(R.string.unsaved_changes_title)
                .setMessage(R.string.unsaved_changes_body)
                .setNegativeButton(R.string.unsaved_changes_keep, null)
                .setPositiveButton(R.string.unsaved_changes_discard, (dialog, which) -> {
                    if (isAdded()) {
                        action.run();
                    }
                })
                .show();
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

    private void setDerivedHint() {
        derivedText.setText(vehicles.isEmpty()
                ? R.string.vehicle_empty_hint
                : R.string.vehicle_new_hint);
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
        Vehicle vehicle = new Vehicle(vehicleId == null ? UUID.randomUUID().toString() : vehicleId,
                userId, make, model, variantEdit.getText().toString().trim(), year, capacity,
                connector, maxAc, maxDc, efficiency, health, 0.0,
                Math.max(5, Math.min(40, minArrival)), Math.max(50, Math.min(100, maxCharge)),
                plateEdit.getText().toString().trim(), true);

        vehicleId = vehicle.getId();
        AppStateStore.get().setVehicle(vehicle);
        AppStateStore.get().setUserId(userId);
        repo.saveVehicle(vehicle);

        // Keep the local mirror in step with what was just written, so the garage chips show
        // the new profile without waiting for a database round trip.
        int existing = -1;
        for (int i = 0; i < vehicles.size(); i++) {
            if (vehicles.get(i).getId().equals(vehicle.getId())) {
                existing = i;
                break;
            }
        }
        if (existing >= 0) {
            vehicles.set(existing, vehicle);
        } else {
            vehicles.add(vehicle);
        }
        for (Vehicle other : vehicles) {
            other.setActive(other.getId().equals(vehicle.getId()));
        }

        renderChips();
        updateGarageHint();
        updateDeleteButton();
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
