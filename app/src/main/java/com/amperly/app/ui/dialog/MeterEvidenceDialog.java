package com.amperly.app.ui.dialog;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.engine.meter.MeterSimulator;
import com.google.android.material.textfield.TextInputEditText;

/**
 * Host-side meter evidence capture. The prototype always labels readings as simulated or manually
 * entered because there is no live charger integration.
 */
public final class MeterEvidenceDialog {

    public interface OnSubmit {
        void onSubmit(double startReading, double endReading, String note);
    }

    private MeterEvidenceDialog() {
    }

    public static void show(Fragment fragment, String stationName, String stationId,
                           double suggestedStart, OnSubmit onSubmit) {
        Context context = fragment.getContext();
        if (context == null) {
            return;
        }
        View content = LayoutInflater.from(context)
                .inflate(R.layout.dialog_meter_evidence, null, false);

        TextView header = content.findViewById(R.id.meterEvidenceHeader);
        header.setText(stationName + "\nDemo meter reading: "
                + String.format(java.util.Locale.US, "%.2f kWh", MeterSimulator.currentReading(stationId))
                + "\nReadings are simulated or entered by hand, not read from live hardware.");

        TextInputEditText startEdit = content.findViewById(R.id.meterStartEdit);
        startEdit.setText(String.format(java.util.Locale.US, "%.2f", suggestedStart));
        TextInputEditText endEdit = content.findViewById(R.id.meterEndEdit);
        TextInputEditText noteEdit = content.findViewById(R.id.meterNoteEdit);

        new AlertDialog.Builder(context)
                .setTitle(R.string.host_record_readings)
                .setView(content)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.action_save, (dialog, which) -> {
                    double start = parse(startEdit.getText().toString(), suggestedStart);
                    double end = parse(endEdit.getText().toString(), start);
                    if (onSubmit != null) {
                        onSubmit.onSubmit(start, end, noteEdit.getText().toString().trim());
                    }
                })
                .show();
    }

    private static double parse(String value, double fallback) {
        try {
            return Double.parseDouble(value.trim());
        } catch (Exception e) {
            return fallback;
        }
    }
}
