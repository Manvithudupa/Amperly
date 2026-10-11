package com.amperly.app;

import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.Fragment;

import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.PilotDataSeeder;
import com.amperly.app.feature.admin.AdminDashboardFragment;
import com.amperly.app.feature.consumer.ActiveSessionFragment;
import com.amperly.app.feature.consumer.ChargerDiscoveryFragment;
import com.amperly.app.feature.consumer.HostChatFragment;
import com.amperly.app.feature.consumer.ReservationFragment;
import com.amperly.app.feature.consumer.RoutePlannerFragment;
import com.amperly.app.feature.consumer.SafetySOSFragment;
import com.amperly.app.feature.consumer.VehicleProfileFragment;
import com.amperly.app.feature.host.HostDashboardFragment;
import com.amperly.app.feature.host.RegisterStationFragment;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.chip.ChipGroup;

public class MainActivity extends AppCompatActivity {

    private BottomNavigationView bottomNavigationView;
    private TextView currentUserText;
    private ChipGroup roleChipGroup;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        PilotDataSeeder.seedPilotData(this);

        Toolbar toolbar = findViewById(R.id.topToolbar);
        setSupportActionBar(toolbar);

        bottomNavigationView = findViewById(R.id.bottomNavigationView);
        currentUserText = findViewById(R.id.currentUserText);
        roleChipGroup = findViewById(R.id.roleChipGroup);

        roleChipGroup.setOnCheckedStateChangeListener((group, checkedIds) -> {
            if (checkedIds.isEmpty()) {
                return;
            }
            int id = checkedIds.get(0);
            if (id == R.id.roleChipHost) {
                applyRole(AppConstants.ROLE_HOST);
            } else if (id == R.id.roleChipAdmin) {
                applyRole(AppConstants.ROLE_ADMIN);
            } else {
                applyRole(AppConstants.ROLE_CONSUMER);
            }
        });

        roleChipGroup.check(R.id.roleChipConsumer);
        applyRole(AppConstants.ROLE_CONSUMER);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.action_vehicle) {
            roleChipGroup.check(R.id.roleChipConsumer);
            applyRole(AppConstants.ROLE_CONSUMER);
            Navigator.openRoot(this, new VehicleProfileFragment(), "vehicle");
            return true;
        }
        if (item.getItemId() == R.id.action_safety) {
            Navigator.openRoot(this, new SafetySOSFragment(), "safety");
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void applyRole(String role) {
        AuthManager.getInstance().setRole(role);
        AppStateStore.get().setUserId(AuthManager.getInstance().getCurrentUserId());
        currentUserText.setText(AuthManager.getInstance().describeCurrentUser());
        buildNavigation(role);
    }

    private void buildNavigation(String role) {
        Menu menu = bottomNavigationView.getMenu();
        menu.clear();
        bottomNavigationView.setOnItemSelectedListener(null);

        if (AppConstants.ROLE_HOST.equals(role)) {
            menu.add(0, 10, 0, R.string.nav_dashboard).setIcon(R.drawable.ic_dashboard);
            menu.add(0, 11, 1, R.string.nav_add_station).setIcon(R.drawable.ic_add);
            menu.add(0, 12, 2, R.string.nav_chat).setIcon(R.drawable.ic_chat);
            bottomNavigationView.setOnItemSelectedListener(item -> loadHostScreen(item.getItemId()));
            bottomNavigationView.setSelectedItemId(10);
            loadRoot(new HostDashboardFragment(), "host_dashboard");
            return;
        }

        if (AppConstants.ROLE_ADMIN.equals(role)) {
            menu.add(0, 20, 0, R.string.nav_admin).setIcon(R.drawable.ic_admin);
            bottomNavigationView.setOnItemSelectedListener(item -> loadAdminScreen(item.getItemId()));
            bottomNavigationView.setSelectedItemId(20);
            loadRoot(new AdminDashboardFragment(), "admin_dashboard");
            return;
        }

        menu.add(0, 1, 0, R.string.nav_discover).setIcon(R.drawable.ic_discover);
        menu.add(0, 2, 1, R.string.nav_route).setIcon(R.drawable.ic_route);
        menu.add(0, 3, 2, R.string.nav_reserve).setIcon(R.drawable.ic_reserve);
        menu.add(0, 4, 3, R.string.nav_session).setIcon(R.drawable.ic_session);
        menu.add(0, 5, 4, R.string.nav_safety).setIcon(R.drawable.ic_safety);
        bottomNavigationView.setOnItemSelectedListener(item -> loadConsumerScreen(item.getItemId()));
        bottomNavigationView.setSelectedItemId(1);
        loadRoot(new ChargerDiscoveryFragment(), "discover");
    }

    private boolean loadConsumerScreen(int itemId) {
        Fragment fragment;
        String tag;
        switch (itemId) {
            case 2:
                fragment = new RoutePlannerFragment();
                tag = "route";
                break;
            case 3:
                fragment = new ReservationFragment();
                tag = "reserve";
                break;
            case 4:
                fragment = new ActiveSessionFragment();
                tag = "session";
                break;
            case 5:
                fragment = new SafetySOSFragment();
                tag = "safety";
                break;
            default:
                fragment = new ChargerDiscoveryFragment();
                tag = "discover";
                break;
        }
        loadRoot(fragment, tag);
        return true;
    }

    private boolean loadHostScreen(int itemId) {
        switch (itemId) {
            case 11:
                loadRoot(new RegisterStationFragment(), "register");
                return true;
            case 12:
                loadRoot(new HostChatFragment(), "chat");
                return true;
            default:
                loadRoot(new HostDashboardFragment(), "host_dashboard");
                return true;
        }
    }

    private boolean loadAdminScreen(int itemId) {
        loadRoot(new AdminDashboardFragment(), "admin");
        return true;
    }

    private void loadRoot(Fragment fragment, String tag) {
        getSupportFragmentManager()
                .popBackStack(null, androidx.fragment.app.FragmentManager.POP_BACK_STACK_INCLUSIVE);
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragment_container, fragment, tag)
                .commit();
    }
}
