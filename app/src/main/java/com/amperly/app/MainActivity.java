package com.amperly.app;

import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.core.state.DemoMode;
import com.amperly.app.data.local.PilotDataSeeder;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.remote.SupabaseAuth;
import com.amperly.app.data.remote.SupabaseConfig;
import com.amperly.app.data.remote.SyncEngine;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.feature.admin.AdminDashboardFragment;
import com.amperly.app.feature.auth.AccountFragment;
import com.amperly.app.feature.auth.SignInFragment;
import com.amperly.app.feature.consumer.ActiveSessionFragment;
import com.amperly.app.feature.consumer.ChargerDiscoveryFragment;
import com.amperly.app.feature.consumer.HostChatFragment;
import com.amperly.app.feature.consumer.ReservationFragment;
import com.amperly.app.feature.consumer.RoutePlannerFragment;
import com.amperly.app.feature.consumer.SafetySOSFragment;
import com.amperly.app.feature.consumer.VehicleProfileFragment;
import com.amperly.app.feature.host.HostDashboardFragment;
import com.amperly.app.feature.host.RegisterStationFragment;
import com.amperly.app.ui.Ux;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.android.material.chip.ChipGroup;

/**
 * The application shell: app bar, mode strip, one fragment container and the bottom
 * navigation.
 *
 * <p>It starts in one of two modes.
 *
 * <ul>
 *   <li><b>Signed in</b> — a Supabase project is configured and an account is available.
 *       The server decides the role, so the role switch is hidden and the navigation is
 *       built from the profile.</li>
 *   <li><b>Offline demo</b> — either no project is configured, or the user chose demo mode.
 *       Everything runs on the seeded pilot data, on this device only, and the role switch
 *       is shown so all three roles can be reviewed without an account.</li>
 * </ul>
 *
 * <p>Which one applies is decided by {@link #startBackend()} before any screen is loaded.
 */
public class MainActivity extends AppCompatActivity {

    private static final String TAG = "Amperly";

    private BottomNavigationView bottomNavigationView;
    private TextView currentUserText;
    private ChipGroup roleChipGroup;
    private View roleStrip;

    private AmperlyRepository repo;

    /** Set while the code, rather than the user, changes the chip selection. */
    private boolean applyingRole;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // targetSdk 35 enforces edge-to-edge on Android 15. Without this, content draws
        // behind the system bars and the toolbar title collides with the status bar clock.
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        setContentView(R.layout.activity_main);
        applyWindowInsets();

        repo = AmperlyRepository.getInstance(this);

        Toolbar toolbar = findViewById(R.id.topToolbar);
        setSupportActionBar(toolbar);

        bottomNavigationView = findViewById(R.id.bottomNavigationView);
        currentUserText = findViewById(R.id.currentUserText);
        roleChipGroup = findViewById(R.id.roleChipGroup);
        roleStrip = findViewById(R.id.roleStrip);

        roleChipGroup.setOnCheckedStateChangeListener((group, checkedIds) -> {
            if (applyingRole || checkedIds.isEmpty()) {
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

        startBackend();
    }

    /**
     * Pads the app bar down past the status bar and the bottom navigation up past the
     * gesture bar. Padding is applied to the views themselves so their backgrounds still
     * fill the inset area, giving an unbroken surface rather than a gap.
     */
    private void applyWindowInsets() {
        View appBar = findViewById(R.id.appBarLayout);
        final int appBarStart = appBar.getPaddingStart();
        final int appBarTop = appBar.getPaddingTop();
        final int appBarEnd = appBar.getPaddingEnd();
        ViewCompat.setOnApplyWindowInsetsListener(appBar, (view, windowInsets) -> {
            Insets bars = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            view.setPadding(appBarStart, appBarTop + bars.top, appBarEnd, view.getPaddingBottom());
            return windowInsets;
        });

        View bottomNav = findViewById(R.id.bottomNavigationView);
        final int navStart = bottomNav.getPaddingStart();
        final int navBottom = bottomNav.getPaddingBottom();
        final int navEnd = bottomNav.getPaddingEnd();
        ViewCompat.setOnApplyWindowInsetsListener(bottomNav, (view, windowInsets) -> {
            Insets bars = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            view.setPadding(navStart, view.getPaddingTop(), navEnd, navBottom + bars.bottom);
            return windowInsets;
        });
    }

    // ------------------------------------------------------------------ modes

    /**
     * Picks the mode before anything is loaded: offline demo, or require a sign-in.
     *
     * <p>A configured project is not optional. The app cannot read the pilot data without a
     * session, because Row Level Security is what authorises it, so showing the seeded data
     * as if it were the account's own would be a lie. The demo mode is therefore an explicit
     * choice, and while it is on nothing is ever sent to the server.
     */
    private void startBackend() {
        if (!SupabaseConfig.isConfigured()) {
            // Device only: no project to talk to at all.
            startOfflineDemo();
            return;
        }
        if (SupabaseConfig.looksLikeSecretKey()) {
            Log.e(TAG, "SUPABASE_PUBLISHABLE_KEY is a secret key. Sync is disabled; replace it "
                    + "with the publishable key in local.properties.");
            Ux.toast(this, getString(R.string.auth_secret_key));
            startOfflineDemo();
            return;
        }
        if (DemoMode.isOfflineDemo(this)) {
            startOfflineDemo();
            return;
        }
        showSignIn();
        restoreSession();
    }

    /** Runs the whole app on the seeded pilot data, with the role switch available. */
    public void startOfflineDemo() {
        DemoMode.setOfflineDemo(this, true);
        PilotDataSeeder.seedPilotData(this);
        roleStrip.setVisibility(View.VISIBLE);
        bottomNavigationView.setVisibility(View.VISIBLE);
        selectRole(AppConstants.ROLE_CONSUMER);
        invalidateOptionsMenu();
    }

    /** Shows the sign-in page and hides everything that needs an account. */
    public void showSignIn() {
        DemoMode.setOfflineDemo(this, false);
        roleStrip.setVisibility(View.GONE);
        bottomNavigationView.setVisibility(View.GONE);
        getSupportFragmentManager()
                .popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragment_container, new SignInFragment(), "sign_in")
                .commit();
        invalidateOptionsMenu();
    }

    /**
     * A session exists. The sign-in page calls this once it has one; restoring a stored
     * session goes through the same path so both behave identically.
     */
    public void onSignedIn(User user) {
        boolean wasOfflineDemo = DemoMode.isOfflineDemo(this);
        DemoMode.setOfflineDemo(this, false);
        AuthManager.getInstance().setCurrentUser(user);
        // The role belongs to the account on the server, so the switch is not offered here.
        roleStrip.setVisibility(View.GONE);
        bottomNavigationView.setVisibility(View.VISIBLE);
        applyRole(user.getRole() == null ? AppConstants.ROLE_CONSUMER : user.getRole());
        invalidateOptionsMenu();
        Ux.toast(this, getString(R.string.auth_signed_in_as) + " " + user.getName());
        syncAfterSignIn(wasOfflineDemo);
    }

    /** Called by the account page once the session has been cleared. */
    public void onSignedOut() {
        AuthManager.getInstance().clearCurrentUser();
        AppStateStore.get().reset();
        showSignIn();
    }

    /**
     * Restores a stored session and, if there is one, the profile behind it. Both happen off
     * the main thread and failure is not fatal: the sign-in page simply stays put.
     */
    private void restoreSession() {
        repo.background(() -> SupabaseAuth.restoreSession(this), session -> {
            if (session == null) {
                return;
            }
            repo.background(
                    () -> repo.resolveOrCreateAppUser(session.authUserId, session.email, null),
                    user -> {
                        if (user == null) {
                            // The token is good but the profile could not be read — almost
                            // always because the device is offline.
                            Ux.toast(this, getString(R.string.auth_profile_offline));
                            return;
                        }
                        onSignedIn(user);
                    });
        });
    }

    /**
     * First sync after signing in.
     *
     * <p>If the device had been in offline demo mode, the local copy is the seeded demo data
     * and must not reach the real project; demo writes cannot be pushed (there was no
     * session), but they would be the moment a session existed. So they are dropped first.
     */
    private void syncAfterSignIn(boolean discardDemoData) {
        repo.background(() -> {
            if (discardDemoData) {
                repo.clearLocalData();
            }
            return SyncEngine.syncNow(this, repo.database());
        }, result -> {
            if (result != null) {
                Log.i(TAG, "Signed-in sync: " + result.summary());
            }
        });
    }

    // ------------------------------------------------------------------ menu

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main_menu, menu);
        return true;
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        // On the sign-in page there is no account, vehicle or session to act on yet.
        boolean inApp = bottomNavigationView.getVisibility() == View.VISIBLE;
        for (int i = 0; i < menu.size(); i++) {
            menu.getItem(i).setVisible(inApp);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == R.id.action_account) {
            Navigator.openRoot(this, new AccountFragment(), "account");
            return true;
        }
        if (item.getItemId() == R.id.action_vehicle) {
            selectRole(AppConstants.ROLE_CONSUMER);
            Navigator.openRoot(this, new VehicleProfileFragment(), "vehicle");
            return true;
        }
        if (item.getItemId() == R.id.action_safety) {
            Navigator.openRoot(this, new SafetySOSFragment(), "safety");
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    // ------------------------------------------------------------------ role

    /** Moves the chips to a role without the listener treating it as a user action. */
    private void selectRole(String role) {
        applyingRole = true;
        if (AppConstants.ROLE_HOST.equals(role)) {
            roleChipGroup.check(R.id.roleChipHost);
        } else if (AppConstants.ROLE_ADMIN.equals(role)) {
            roleChipGroup.check(R.id.roleChipAdmin);
        } else {
            roleChipGroup.check(R.id.roleChipConsumer);
        }
        applyingRole = false;
        applyRole(role);
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
                .popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragment_container, fragment, tag)
                .commit();
    }
}
