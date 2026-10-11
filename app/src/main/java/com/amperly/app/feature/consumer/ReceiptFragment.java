package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;

public class ReceiptFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_receipt, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        TextView invoiceText = view.findViewById(R.id.invoiceDetailsText);
        invoiceText.setText("ITEMIZED BILLING RECEIPT\n----------------------------------\nStarting Meter: 120.0 kWh\nEnding Meter: 132.5 kWh\nVerified Energy: 12.5 kWh\nEnergy Charge (@ ₹18/kWh): ₹225.00\nAmperly Service Fee: ₹5.00\nPayment Gateway Charge: ₹4.00\n----------------------------------\nFINAL TOTAL: ₹234.00");
    }
}
