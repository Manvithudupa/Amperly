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
import com.amperly.app.engine.billing.BillingEngine;

public class ActiveSessionFragment extends Fragment {

    private EditText startMeterEdit, endMeterEdit;
    private TextView receiptText;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_active_session, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        startMeterEdit = view.findViewById(R.id.startMeterEdit);
        endMeterEdit = view.findViewById(R.id.endMeterEdit);
        receiptText = view.findViewById(R.id.receiptText);

        Button checkInBtn = view.findViewById(R.id.checkInBtn);
        checkInBtn.setOnClickListener(v ->
                Toast.makeText(getContext(), "Checked in successfully! Station starting reading captured.", Toast.LENGTH_SHORT).show());

        Button completeSessionBtn = view.findViewById(R.id.completeSessionBtn);
        completeSessionBtn.setOnClickListener(v -> calculateInvoice());
    }

    private void calculateInvoice() {
        String startStr = startMeterEdit.getText().toString().trim();
        String endStr = endMeterEdit.getText().toString().trim();

        if (TextUtils.isEmpty(startStr) || TextUtils.isEmpty(endStr)) {
            Toast.makeText(getContext(), "Please enter starting and ending meter readings.", Toast.LENGTH_SHORT).show();
            return;
        }

        double startKwh = Double.parseDouble(startStr);
        double endKwh = Double.parseDouble(endStr);

        ChargerStation station = new ChargerStation("s1", "h1", "ABC College Campus Charger", "Campus Gate 2", 12.3, 76.6, "CAMPUS", "24/7", 18.0, 5.0, 4.0, "LEVEL_1", true, false, 4.9, System.currentTimeMillis());

        BillingEngine.BillingCalculationResult billing = BillingEngine.calculateBill(
                "sess_101", "cons_1", "host_1", station, startKwh, endKwh
        );

        if (!billing.isValid()) {
            receiptText.setText("ERROR: " + billing.getErrorMessage());
            return;
        }

        StringBuilder sb = new StringBuilder();
        sb.append("ITEMIZED BILLING RECEIPT\n");
        sb.append("----------------------------------\n");
        sb.append("Starting Meter: ").append(startKwh).append(" kWh\n");
        sb.append("Ending Meter: ").append(endKwh).append(" kWh\n");
        sb.append("Verified Energy Consumed: ").append(billing.getVerifiedKwh()).append(" kWh\n");
        sb.append("Energy Charge (@ ₹18.00/kWh): ₹").append(billing.getEnergyCharge()).append("\n");
        sb.append("Amperly Service Fee: ₹").append(billing.getServiceFee()).append("\n");
        sb.append("Payment Gateway Charge: ₹").append(billing.getGatewayFee()).append("\n");
        sb.append("----------------------------------\n");
        sb.append("FINAL TOTAL PAID: ₹").append(billing.getFinalTotal()).append("\n");

        receiptText.setText(sb.toString());
        Toast.makeText(getContext(), "Invoice Generated & Sandbox Payment Captured!", Toast.LENGTH_LONG).show();
    }
}
