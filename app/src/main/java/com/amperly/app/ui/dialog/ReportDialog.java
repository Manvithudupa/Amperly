package com.amperly.app.ui.dialog;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.google.android.material.textfield.TextInputEditText;

/**
 * The consumer reporting flow. Categories mirror the spec so reports reach the admin queue with the
 * right context (charger unavailable, incorrect meter reading, off-platform payment, and so on).
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

    private ReportDialog() {
    }

    public static void show(Fragment fragment, String title, String selectedType, OnSubmit onSubmit) {
        Context context = fragment.getContext();
        if (context == null) {
            return;
        }

        View content = LayoutInflater.from(context).inflate(R.layout.dialog_report, null, false);
        Spinner spinner = content.findViewById(R.id.reportTypeSpinner);
        ArrayAdapter<String> adapter = new ArrayAdapter<>(context,
                android.R.layout.simple_spinner_dropdown_item, REPORT_TYPES);
        spinner.setAdapter(adapter);
        if (selectedType != null) {
            for (int i = 0; i < REPORT_TYPES.length; i++) {
                if (REPORT_TYPES[i].equalsIgnoreCase(selectedType)) {
                    spinner.setSelection(i);
                    break;
                }
            }
        }
        TextInputEditText details = content.findViewById(R.id.reportDetailsEdit);

        new AlertDialog.Builder(context)
                .setTitle(title == null ? context.getString(R.string.report_title) : title)
                .setView(content)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.report_submit, (dialog, which) -> {
                    String type = (String) spinner.getSelectedItem();
                    if (onSubmit != null) {
                        onSubmit.onSubmit(type, details.getText().toString().trim());
                    }
                })
                .show();
    }
}
