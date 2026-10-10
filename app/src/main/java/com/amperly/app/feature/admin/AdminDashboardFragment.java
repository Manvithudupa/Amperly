package com.amperly.app.feature.admin;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;

public class AdminDashboardFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_admin_dashboard, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Button approveBtn = view.findViewById(R.id.approveStationBtn);
        approveBtn.setOnClickListener(v ->
                Toast.makeText(getContext(), "Station approved & Level 1 verification granted!", Toast.LENGTH_SHORT).show());

        Button refundBtn = view.findViewById(R.id.resolveRefundBtn);
        refundBtn.setOnClickListener(v ->
                Toast.makeText(getContext(), "Consumer refund processed for Dispute #DSP-102.", Toast.LENGTH_SHORT).show());

        Button warningBtn = view.findViewById(R.id.issueWarningBtn);
        warningBtn.setOnClickListener(v ->
                Toast.makeText(getContext(), "Host Warning & Policy Fine issued.", Toast.LENGTH_SHORT).show());
    }
}
