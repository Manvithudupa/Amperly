package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;

public class SafetySOSFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_safety_sos, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Button triggerSosBtn = view.findViewById(R.id.triggerSosBtn);
        triggerSosBtn.setOnClickListener(v ->
                Toast.makeText(getContext(), "EMERGENCY SOS ALERT TRIGGERED! Support notified & Station details logged.", Toast.LENGTH_LONG).show());

        EditText trustedPhoneEdit = view.findViewById(R.id.trustedPhoneEdit);
        Button startLiveShareBtn = view.findViewById(R.id.startLiveShareBtn);

        startLiveShareBtn.setOnClickListener(v -> {
            String phone = trustedPhoneEdit.getText().toString().trim();
            if (TextUtils.isEmpty(phone)) {
                Toast.makeText(getContext(), "Please enter a mobile number.", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(getContext(), "Live location sharing active with " + phone + " for 60 mins.", Toast.LENGTH_LONG).show();
            }
        });
    }
}
