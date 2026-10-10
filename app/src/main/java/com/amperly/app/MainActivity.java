package com.amperly.app;

import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.amperly.app.data.local.PilotDataSeeder;
import com.amperly.app.feature.admin.AdminDashboardFragment;
import com.amperly.app.feature.consumer.ActiveSessionFragment;
import com.amperly.app.feature.consumer.ChargerDiscoveryFragment;
import com.amperly.app.feature.consumer.HostChatFragment;
import com.amperly.app.feature.consumer.ReservationFragment;
import com.amperly.app.feature.consumer.RoutePlannerFragment;
import com.amperly.app.feature.consumer.SafetySOSFragment;
import com.amperly.app.feature.host.HostDashboardFragment;
import com.amperly.app.feature.host.RegisterStationFragment;
import com.google.android.material.bottomnavigation.BottomNavigationView;

public class MainActivity extends AppCompatActivity {

    private BottomNavigationView bottomNavigationView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Seed pilot data
        PilotDataSeeder.seedPilotData(this);

        Spinner roleSpinner = findViewById(R.id.roleSpinner);
        bottomNavigationView = findViewById(R.id.bottomNavigationView);

        String[] roles = {"Consumer Mode", "Host Mode", "Administrator Mode"};
        ArrayAdapter<String> roleAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, roles);
        roleSpinner.setAdapter(roleAdapter);

        roleSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                setupRoleNavigation(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {}
        });

        // Initial default: Consumer Mode
        setupRoleNavigation(0);
    }

    private void setupRoleNavigation(int roleIndex) {
        bottomNavigationView.getMenu().clear();

        if (roleIndex == 0) { // Consumer
            bottomNavigationView.getMenu().add(0, 1, 0, "Discover").setIcon(android.R.drawable.ic_menu_search);
            bottomNavigationView.getMenu().add(0, 2, 1, "Route").setIcon(android.R.drawable.ic_menu_directions);
            bottomNavigationView.getMenu().add(0, 3, 2, "Reserve").setIcon(android.R.drawable.ic_menu_day);
            bottomNavigationView.getMenu().add(0, 4, 3, "Session").setIcon(android.R.drawable.ic_menu_agenda);
            bottomNavigationView.getMenu().add(0, 5, 4, "Safety").setIcon(android.R.drawable.ic_menu_help);

            bottomNavigationView.setOnItemSelectedListener(item -> {
                switch (item.getItemId()) {
                    case 1: loadFragment(new ChargerDiscoveryFragment()); return true;
                    case 2: loadFragment(new RoutePlannerFragment()); return true;
                    case 3: loadFragment(new ReservationFragment()); return true;
                    case 4: loadFragment(new ActiveSessionFragment()); return true;
                    case 5: loadFragment(new SafetySOSFragment()); return true;
                }
                return false;
            });
            loadFragment(new ChargerDiscoveryFragment());

        } else if (roleIndex == 1) { // Host
            bottomNavigationView.getMenu().add(0, 10, 0, "Dashboard").setIcon(android.R.drawable.ic_menu_manage);
            bottomNavigationView.getMenu().add(0, 11, 1, "Add Station").setIcon(android.R.drawable.ic_menu_add);
            bottomNavigationView.getMenu().add(0, 12, 2, "Messages").setIcon(android.R.drawable.ic_menu_send);

            bottomNavigationView.setOnItemSelectedListener(item -> {
                switch (item.getItemId()) {
                    case 10: loadFragment(new HostDashboardFragment()); return true;
                    case 11: loadFragment(new RegisterStationFragment()); return true;
                    case 12: loadFragment(new HostChatFragment()); return true;
                }
                return false;
            });
            loadFragment(new HostDashboardFragment());

        } else if (roleIndex == 2) { // Admin
            bottomNavigationView.getMenu().add(0, 20, 0, "Admin Desk").setIcon(android.R.drawable.ic_menu_edit);

            bottomNavigationView.setOnItemSelectedListener(item -> {
                if (item.getItemId() == 20) {
                    loadFragment(new AdminDashboardFragment());
                    return true;
                }
                return false;
            });
            loadFragment(new AdminDashboardFragment());
        }
    }

    private void loadFragment(Fragment fragment) {
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.fragment_container, fragment)
                .commit();
    }
}
