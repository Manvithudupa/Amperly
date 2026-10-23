package com.amperly.app.ui.dialog;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;

import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.MaterialAutoCompleteTextView;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

/**
 * The consumer reporting flow. Categories mirror the spec so reports reach the admin queue with the
 * right context (charger unavailable, incorrect meter reading, off-platform payment, and so on).
 *
 * <p>{@link #REPORT_TYPES} stays in English because it is the value stored on the server; the
 * dialog shows the translated label for the same position.
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

    private ReportDialog() {
    }

    public static void show(Fragment fragment, String title, String selectedType, OnSubmit onSubmit) {
        Context context = fragment.getContext();
        if (context == null) {
            return;
        }

        View content = LayoutInflater.from(context).inflate(R.layout.dialog_report, null, false);
        TextInputLayout typeField = content.findViewById(R.id.reportTypeField);
        MaterialAutoCompleteTextView dropdown = content.findViewById(R.id.reportTypeDropdown);
        String[] labels = typeLabels(context);

        final int[] selectedIndex = {0};
        if (selectedType != null) {
            for (int i = 0; i < REPORT_TYPES.length; i++) {
                if (REPORT_TYPES[i].equalsIgnoreCase(selectedType)) {
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

        new MaterialAlertDialogBuilder(context)
                .setTitle(title == null ? context.getString(R.string.report_title) : title)
                .setView(content)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.report_submit, (dialog, which) -> {
                    if (onSubmit != null) {
                        String text = details.getText() == null
                                ? "" : details.getText().toString().trim();
                        onSubmit.onSubmit(REPORT_TYPES[selectedIndex[0]], text);
                    }
                })
                .show();
    }

    private static String[] typeLabels(Context context) {
        String[] labels = new String[REPORT_TYPE_LABELS.length];
        for (int i = 0; i < REPORT_TYPE_LABELS.length; i++) {
            labels[i] = context.getString(REPORT_TYPE_LABELS[i]);
        }
        return labels;
    }
}
