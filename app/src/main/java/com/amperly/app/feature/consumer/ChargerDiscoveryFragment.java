package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;

public class ChargerDiscoveryFragment extends Fragment {

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_charger_discovery, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        view.findViewById(R.id.filterAllBtn).setOnClickListener(v ->
                Toast.makeText(getContext(), "Showing all nearby stations", Toast.LENGTH_SHORT).show());
        view.findViewById(R.id.filterCampusBtn).setOnClickListener(v ->
                Toast.makeText(getContext(), "Filtered: Campus Chargers", Toast.LENGTH_SHORT).show());
        view.findViewById(R.id.filterApartmentBtn).setOnClickListener(v ->
                Toast.makeText(getContext(), "Filtered: Apartment Chargers", Toast.LENGTH_SHORT).show());
        view.findViewById(R.id.filterDcBtn).setOnClickListener(v ->
                Toast.makeText(getContext(), "Filtered: DC Fast Chargers", Toast.LENGTH_SHORT).show());
    }
}
