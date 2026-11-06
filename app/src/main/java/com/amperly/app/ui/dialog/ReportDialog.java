package com.amperly.app.ui.dialog;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;

import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.ui.Ux;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

/**
 * The reporting flow, with a category set for each side of a session.
 *
 * <p>{@link #REPORT_TYPES} is what a consumer files about a charger or a host;
 * {@link #HOST_REPORT_TYPES} is what a host files about a driver. Both stay in English because
 * that is the value stored on the server; the dialog shows the translated label for the same
 * position.
 */
public final class ReportDialog {

    public interface OnSubmit {
        void onSubmit(String reportType, String details);
    }

    public static final String[] REPORT_TYPES = {
            "Charger unavailable",
            "Incorrect connector information",
            "Incorrect meter reading",
            "Overcharging",
            "Host requested off-platform payment",
            "Unsafe access conditions",
            "Incorrect station listing",
            "Reservation conflict",
            "Route estimate did not match actual battery usage",
            "Planned charging stop was unavailable"
    };

    private static final int[] REPORT_TYPE_LABELS = {
            R.string.report_type_unavailable,
            R.string.report_type_connector,
            R.string.report_type_meter,
            R.string.report_type_overcharge,
            R.string.report_type_offplatform,
            R.string.report_type_unsafe,
            R.string.report_type_listing,
            R.string.report_type_conflict,
            R.string.report_type_route_estimate,
            R.string.report_type_stop_unavailable
    };

    /** What a host can report about a driver, instead of the charger-side categories above. */
    public static final String[] HOST_REPORT_TYPES = {
            "Driver left without paying",
            "Unsafe or abusive behaviour",
            "Damage to the charger",
            "Incorrect booking details",
            "Other"
    };

    private static final int[] HOST_REPORT_TYPE_LABELS = {
            R.string.report_type_host_unpaid,
            R.string.report_type_host_behaviour,
            R.string.report_type_host_damage,
            R.string.report_type_host_booking,
            R.string.report_type_host_other
    };

    private ReportDialog() {
    }

    public static void show(Fragment fragment, String title, String selectedType, OnSubmit onSubmit) {
        show(fragment, title, selectedType, REPORT_TYPES, REPORT_TYPE_LABELS, onSubmit);
    }

    /** The host side of the same dialog: a report about a driver or a finished session. */
    public static void showHost(Fragment fragment, String title, String selectedType,
                                OnSubmit onSubmit) {
        show(fragment, title, selectedType, HOST_REPORT_TYPES, HOST_REPORT_TYPE_LABELS, onSubmit);
    }

    private static void show(Fragment fragment, String title, String selectedType,
                             String[] types, int[] labelResources, OnSubmit onSubmit) {
        Context context = fragment.getContext();
        if (context == null) {
            return;
        }

        View content = LayoutInflater.from(context).inflate(R.layout.dialog_report, null, false);
        TextInputLayout typeField = content.findViewById(R.id.reportTypeField);
        MaterialAutoCompleteTextView dropdown = content.findViewById(R.id.reportTypeDropdown);
        String[] labels = typeLabels(context, labelResources);

        final int[] selectedIndex = {0};
        if (selectedType != null) {
            for (int i = 0; i < types.length; i++) {
                if (types[i].equalsIgnoreCase(selectedType)) {
                    selectedIndex[0] = i;
                    break;
                }
            }
        }
        dropdown.setAdapter(new ArrayAdapter<>(context, R.layout.item_dropdown, labels));
        dropdown.setText(labels[selectedIndex[0]], false);
        dropdown.setOnItemClickListener((parent, view, position, id) -> {
            if (position < 0 || position >= labels.length) {
                return;
            }
            selectedIndex[0] = position;
            dropdown.setText(labels[position], false);
            if (typeField != null) {
                typeField.setError(null);
            }
        });

        TextInputEditText details = content.findViewById(R.id.reportDetailsEdit);

        // The details are typed in: the dialog scrolls and resizes so the keyboard never covers
        // the field being filled in.
        Ux.keepFieldsVisible(content);
        androidx.appcompat.app.AlertDialog dialog = new MaterialAlertDialogBuilder(context)
                .setTitle(title == null ? context.getString(R.string.report_title) : title)
                .setView(content)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.report_submit, (shown, which) -> {
                    if (onSubmit != null) {
                        String text = details.getText() == null
                                ? "" : details.getText().toString().trim();
                        onSubmit.onSubmit(types[selectedIndex[0]], text);
                    }
                })
                .create();
        Ux.resizeForKeyboard(dialog);
        dialog.show();
    }

    private static String[] typeLabels(Context context, int[] labelResources) {
        String[] labels = new String[labelResources.length];
        for (int i = 0; i < labelResources.length; i++) {
            labels[i] = context.getString(labelResources[i]);
        }
        return labels;
    }
}
