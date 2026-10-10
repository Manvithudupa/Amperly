package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;

public class ReservationFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_reservation, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Spinner timeSlotSpinner = view.findViewById(R.id.timeSlotSpinner);
        String[] slots = {"Today, 10:00 AM - 11:30 AM", "Today, 02:00 PM - 03:30 PM", "Tomorrow, 09:00 AM - 10:30 AM"};
        if (getContext() != null) {
            ArrayAdapter<String> adapter = new ArrayAdapter<>(getContext(), android.R.layout.simple_spinner_dropdown_item, slots);
            timeSlotSpinner.setAdapter(adapter);
        }

        Button authPaymentBtn = view.findViewById(R.id.authorizePaymentBtn);
        authPaymentBtn.setOnClickListener(v ->
                Toast.makeText(getContext(), "Payment Authorized in Sandbox Mode! Booking ID: AMP-8921", Toast.LENGTH_LONG).show());
    }
}
