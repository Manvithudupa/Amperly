package com.amperly.app.feature.host;

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

public class RegisterStationFragment extends Fragment {

    private EditText stationNameEdit;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_register_station, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        stationNameEdit = view.findViewById(R.id.stationNameEdit);

        Button saveStationBtn = view.findViewById(R.id.saveStationBtn);
        saveStationBtn.setOnClickListener(v -> {
            String name = stationNameEdit.getText().toString().trim();
            if (TextUtils.isEmpty(name)) {
                Toast.makeText(getContext(), "Please enter a station name.", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(getContext(), "Charger station '" + name + "' submitted for verification!", Toast.LENGTH_LONG).show();
            }
        });
    }
}
