package com.amperly.app;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.content.res.AppCompatResources;
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
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;
import com.google.android.material.color.MaterialColors;

import java.util.List;

/**
 * The application shell: app bar, mode strip, one fragment container and the bottom
 * navigation.
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

    /** The role list the chips were last built for, so they are only rebuilt when it changes. */
    private String builtRoleSignature = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
            setContentView(R.layout.activity_main);
            applyWindowInsets();

            repo = AmperlyRepository.getInstance(this);

            Toolbar toolbar = findViewById(R.id.topToolbar);
            setSupportActionBar(toolbar);
            applyBrandMark(toolbar);

            bottomNavigationView = findViewById(R.id.bottomNavigationView);
            currentUserText = findViewById(R.id.currentUserText);
            roleChipGroup = findViewById(R.id.roleChipGroup);
            roleStrip = findViewById(R.id.roleStrip);

            if (roleChipGroup != null) {
                roleChipGroup.setOnCheckedStateChangeListener((group, checkedIds) -> {
                    if (applyingRole || checkedIds.isEmpty()) {
                        return;
                    }
                    View chip = group.findViewById(checkedIds.get(0));
                    if (chip == null || chip.getTag() == null) {
                        return;
                    }
                    applyRole(String.valueOf(chip.getTag()));
                });
            }

            handleDeepLink(getIntent());
            startBackend();
        } catch (Exception e) {
            Log.e(TAG, "Critical error in MainActivity onCreate: " + e.getMessage(), e);
            try {
                startOfflineDemo();
            } catch (Exception ignored) {}
        }
    }

    @Override
    protected void onNewIntent(android.content.Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        handleDeepLink(intent);
    }

    private void handleDeepLink(android.content.Intent intent) {
        if (intent != null && intent.getData() != null) {
            android.net.Uri data = intent.getData();
            if ("amperly".equals(data.getScheme()) && "auth-callback".equals(data.getHost())) {
                Ux.toast(this, "Email Confirmed Successfully! Welcome to Amperly.");
            }
        }
    }

    private void applyWindowInsets() {
        View appBar = findViewById(R.id.appBarLayout);
        if (appBar != null) {
            final int appBarStart = appBar.getPaddingStart();
            final int appBarTop = appBar.getPaddingTop();
            final int appBarEnd = appBar.getPaddingEnd();
            ViewCompat.setOnApplyWindowInsetsListener(appBar, (view, windowInsets) -> {
                Insets bars = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
                view.setPadding(appBarStart, appBarTop + bars.top, appBarEnd, view.getPaddingBottom());
                return windowInsets;
            });
        }

        View bottomNav = findViewById(R.id.bottomNavigationView);
        if (bottomNav != null) {
            final int navStart = bottomNav.getPaddingStart();
            final int navBottom = bottomNav.getPaddingBottom();
            final int navEnd = bottomNav.getPaddingEnd();
            ViewCompat.setOnApplyWindowInsetsListener(bottomNav, (view, windowInsets) -> {
                Insets bars = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
                view.setPadding(navStart, view.getPaddingTop(), navEnd, navBottom + bars.bottom);
                return windowInsets;
            });
        }
    }

    private void applyBrandMark(Toolbar toolbar) {
        if (toolbar == null) return;
        Drawable mark = AppCompatResources.getDrawable(this, R.drawable.ic_brand_mark);
        if (mark == null) {
            return;
        }
        mark = mark.mutate();
        mark.setTint(MaterialColors.getColor(toolbar,
                com.google.android.material.R.attr.colorOnPrimary));
        toolbar.setLogo(mark);
        toolbar.setLogoDescription(getString(R.string.app_name));
    }

    private void startBackend() {
        try {
            if (!SupabaseConfig.isConfigured()) {
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
            if (SupabaseAuth.hasStoredSession(this)) {
                if (roleStrip != null) roleStrip.setVisibility(View.GONE);
                if (bottomNavigationView != null) bottomNavigationView.setVisibility(View.GONE);
                restoreSession();
            } else {
                showSignIn();
            }
        } catch (Exception e) {
            Log.e(TAG, "Error starting backend, falling back to offline demo: " + e.getMessage());
            startOfflineDemo();
        }
    }

    public void startOfflineDemo() {
        DemoMode.setOfflineDemo(this, true);
        AuthManager.getInstance().startDemoSession();
        if (roleStrip != null) roleStrip.setVisibility(View.VISIBLE);
        // The screens are built only once the seed has committed. Building them first gave an
        // empty Discover screen that never refreshed.
        if (bottomNavigationView != null) bottomNavigationView.setVisibility(View.GONE);
        PilotDataSeeder.seedPilotData(this, () -> {
            if (isFinishing() || isDestroyed()) {
                return;
            }
            if (bottomNavigationView != null) bottomNavigationView.setVisibility(View.VISIBLE);
            applyRole(AppConstants.ROLE_CONSUMER);
            invalidateOptionsMenu();
        });
    }

    public void showSignIn() {
        DemoMode.setOfflineDemo(this, false);
        if (roleStrip != null) roleStrip.setVisibility(View.GONE);
        if (bottomNavigationView != null) bottomNavigationView.setVisibility(View.GONE);
        getSupportFragmentManager()
                .popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragment_container, new SignInFragment(), "sign_in")
                .commit();
        invalidateOptionsMenu();
    }

    public void onSignedIn(User user) {
        boolean wasOfflineDemo = DemoMode.isOfflineDemo(this);
        DemoMode.setOfflineDemo(this, false);
        AuthManager.getInstance().setCurrentUser(user);
        // The role strip stays available to signed-in users: the same account is a Consumer and a
        // Host, so switching capacity is a normal part of using the app, not a demo control.
        if (roleStrip != null) roleStrip.setVisibility(View.VISIBLE);
        if (bottomNavigationView != null) bottomNavigationView.setVisibility(View.VISIBLE);
        applyRole(AppConstants.ROLE_CONSUMER);
        invalidateOptionsMenu();
        Ux.toast(this, getString(R.string.auth_signed_in_as) + " " + user.getName());
        if (repo.didProfileWriteFail()) {
            // The account exists on the device but not in public.users, which makes it anonymous
            // to every RLS policy. Say so instead of showing an app that looks broken.
            Ux.toast(this, getString(R.string.auth_profile_local_only));
        }
        syncAfterSignIn(wasOfflineDemo);
    }

    public void onSignedOut() {
        AuthManager.getInstance().clearCurrentUser();
        AppStateStore.get().reset();
        showSignIn();
    }

    private void restoreSession() {
        repo.background(() -> SupabaseAuth.restoreSession(this), session -> {
            if (session == null) {
                showSignIn();
                return;
            }
            repo.background(
                    () -> repo.resolveOrCreateAppUser(session.authUserId, session.email, null),
                    user -> {
                        if (user == null) {
                            Ux.toast(this, getString(R.string.auth_profile_offline));
                            showSignIn();
                            return;
                        }
                        onSignedIn(user);
                    });
        });
    }

    private void syncAfterSignIn(boolean discardDemoData) {
        repo.background(() -> {
            if (discardDemoData) {
                User currentUser = AuthManager.getInstance().getCurrentUser();
                repo.clearLocalData();
                if (currentUser != null) {
                    try {
                        repo.database().userDao().insert(currentUser);
                    } catch (Exception ignored) {}
                }
            }
            return SyncEngine.syncNow(this, repo.database());
        }, result -> {
            if (result != null) {
                Log.i(TAG, "Signed-in sync: " + result.summary());
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.main_menu, menu);
        return true;
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        boolean inApp = bottomNavigationView != null && bottomNavigationView.getVisibility() == View.VISIBLE;
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

    private void selectRole(String role) {
        applyRole(role);
    }

    /**
     * Switches capacity. The account never changes, only what it is currently acting as, so a
     * Consumer booking a slot and a Host listing a charger are the same signed-in person.
     */
    private void applyRole(String role) {
        AuthManager auth = AuthManager.getInstance();
        String target = role;
        if (!auth.setRole(target)) {
            // No authority for that capacity; fall back rather than pretend otherwise.
            target = AppConstants.ROLE_CONSUMER;
            auth.setRole(target);
        }
        buildRoleChips(target);
        AppStateStore.get().setUserId(auth.getCurrentUserId());
        if (currentUserText != null) {
            currentUserText.setText(auth.describeCurrentUser());
        }
        buildNavigation(target);
    }

    /**
     * Rebuilds the chips from the roles this account actually holds. Consumer and Host are always
     * offered together; Admin appears only when the server says the account is platform ops.
     */
    private void buildRoleChips(String activeRole) {
        if (roleChipGroup == null) {
            return;
        }
        List<String> roles = AuthManager.getInstance().availableRoles();
        String signature = roles + "|" + activeRole;
        if (signature.equals(builtRoleSignature)) {
            return;
        }
        builtRoleSignature = signature;

        applyingRole = true;
        roleChipGroup.removeAllViews();
        LayoutInflater inflater = LayoutInflater.from(this);
        for (String role : roles) {
            Chip chip = (Chip) inflater.inflate(R.layout.item_role_chip, roleChipGroup, false);
            chip.setId(View.generateViewId());
            chip.setText(AuthManager.roleLabel(role));
            chip.setTag(role);
            chip.setChecked(role.equals(activeRole));
            roleChipGroup.addView(chip);
        }
        applyingRole = false;
    }

    private void buildNavigation(String role) {
        if (bottomNavigationView == null) return;
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
