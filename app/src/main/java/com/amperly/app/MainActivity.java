package com.amperly.app;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.content.res.AppCompatResources;
import androidx.appcompat.widget.PopupMenu;
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
import com.google.android.material.dialog.MaterialAlertDialogBuilder;

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
            makeToolbarHome(toolbar);

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
        MenuItem profileAction = menu.findItem(R.id.action_profile);
        if (profileAction != null) {
            profileAction.setActionView(buildProfileBadge());
        }
        return true;
    }

    /**
     * The circular profile badge shown in the top bar: the signed-in user's initials, and a tap
     * opens the dropdown of the remaining destinations.
     */
    private View buildProfileBadge() {
        View badge = LayoutInflater.from(this).inflate(R.layout.view_profile_button, null);
        TextView initials = badge.findViewById(R.id.profileBadgeText);
        User user = AuthManager.getInstance().getCurrentUser();
        initials.setText(initialsOf(user == null ? null : user.getName()));
        badge.setOnClickListener(this::showProfileMenu);
        return badge;
    }

    private void showProfileMenu(View anchor) {
        PopupMenu popup = new PopupMenu(this, anchor);
        popup.inflate(R.menu.profile_menu);
        popup.getMenu().findItem(R.id.profile_action_sign_out)
                .setVisible(SupabaseAuth.isSignedIn());
        popup.setOnMenuItemClickListener(item -> {
            int id = item.getItemId();
            if (id == R.id.profile_action_account) {
                Navigator.openRoot(this, new AccountFragment(), "account");
                return true;
            }
            if (id == R.id.profile_action_vehicle) {
                selectRole(AppConstants.ROLE_CONSUMER);
                Navigator.openRoot(this, new VehicleProfileFragment(), "vehicle");
                return true;
            }
            if (id == R.id.profile_action_safety) {
                Navigator.openRoot(this, new SafetySOSFragment(), "safety");
                return true;
            }
            if (id == R.id.profile_action_sign_out) {
                confirmSignOut();
                return true;
            }
            return false;
        });
        popup.show();
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
        // The three destinations that used to sit here now live in the profile dropdown, which is
        // triggered from the badge's own click listener rather than from a menu item id.
        return super.onOptionsItemSelected(item);
    }

    /**
     * Makes the brand mark and title in the top bar a link home. Toolbar lays its title view out
     * after it is attached, so the children are wired both now and once more after layout.
     */
    private void makeToolbarHome(Toolbar toolbar) {
        if (toolbar == null) {
            return;
        }
        View.OnClickListener home = v -> goHome();
        toolbar.setClickable(true);
        toolbar.setOnClickListener(home);
        wireHome(toolbar, home);
        toolbar.post(() -> wireHome(toolbar, home));
    }

    /**
     * Points the title and the empty bar area at home, while leaving the action area — which holds
     * the profile badge and its own click behaviour — alone.
     */
    private void wireHome(Toolbar toolbar, View.OnClickListener home) {
        for (int i = 0; i < toolbar.getChildCount(); i++) {
            View child = toolbar.getChildAt(i);
            if (child == null || child.getId() == R.id.profileBadge) {
                continue;
            }
            if (child instanceof androidx.appcompat.widget.ActionMenuView) {
                continue;
            }
            child.setOnClickListener(home);
        }
    }

    /** Opens the default page for the role the account is currently acting as. */
    public void goHome() {
        if (bottomNavigationView == null
                || bottomNavigationView.getVisibility() != View.VISIBLE) {
            return;
        }
        buildNavigation(AuthManager.getInstance().getCurrentRole());
    }

    /** Up to two initials from a display name, matching the account page's monogram. */
    private static String initialsOf(@Nullable String name) {
        if (name == null || name.trim().isEmpty()) {
            return "\u2022";
        }
        String[] words = name.trim().split("\\s+");
        StringBuilder initials = new StringBuilder();
        for (String word : words) {
            if (word.isEmpty()) {
                continue;
            }
            initials.append(Character.toUpperCase(word.charAt(0)));
            if (initials.length() == 2) {
                break;
            }
        }
        return initials.length() == 0 ? "\u2022" : initials.toString();
    }

    private void confirmSignOut() {
        new MaterialAlertDialogBuilder(this)
                .setTitle(R.string.account_sign_out)
                .setMessage(R.string.account_sign_out_confirm)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.account_sign_out, (dialog, which) -> performSignOut())
                .show();
    }

    /** Ends the session and wipes the local copy, exactly as the account page does. */
    private void performSignOut() {
        repo.background(() -> {
            SupabaseAuth.signOut(getApplicationContext());
            repo.clearLocalData();
            return Boolean.TRUE;
        }, done -> {
            AuthManager.getInstance().clearCurrentUser();
            AppStateStore.get().reset();
            onSignedOut();
        });
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
            menu.add(0, R.id.nav_host_dashboard, 0, R.string.nav_dashboard).setIcon(R.drawable.ic_dashboard);
            menu.add(0, R.id.nav_host_add_station, 1, R.string.nav_add_station).setIcon(R.drawable.ic_add);
            menu.add(0, R.id.nav_host_chat, 2, R.string.nav_chat).setIcon(R.drawable.ic_chat);
            bottomNavigationView.setOnItemSelectedListener(item -> loadHostScreen(item.getItemId()));
            bottomNavigationView.setSelectedItemId(R.id.nav_host_dashboard);
            loadRoot(new HostDashboardFragment(), "host_dashboard");
            return;
        }

        if (AppConstants.ROLE_ADMIN.equals(role)) {
            menu.add(0, R.id.nav_admin, 0, R.string.nav_admin).setIcon(R.drawable.ic_admin);
            bottomNavigationView.setOnItemSelectedListener(item -> loadAdminScreen(item.getItemId()));
            bottomNavigationView.setSelectedItemId(R.id.nav_admin);
            loadRoot(new AdminDashboardFragment(), "admin_dashboard");
            return;
        }

        menu.add(0, R.id.nav_discover, 0, R.string.nav_discover).setIcon(R.drawable.ic_discover);
        menu.add(0, R.id.nav_route_plan, 1, R.string.nav_route).setIcon(R.drawable.ic_route);
        menu.add(0, R.id.nav_reserve, 2, R.string.nav_reserve).setIcon(R.drawable.ic_reserve);
        menu.add(0, R.id.nav_session, 3, R.string.nav_session).setIcon(R.drawable.ic_session);
        menu.add(0, R.id.nav_safety, 4, R.string.nav_safety).setIcon(R.drawable.ic_safety);
        bottomNavigationView.setOnItemSelectedListener(item -> loadConsumerScreen(item.getItemId()));
        bottomNavigationView.setSelectedItemId(R.id.nav_discover);
        loadRoot(new ChargerDiscoveryFragment(), "discover");
    }

    private boolean loadConsumerScreen(int itemId) {
        Fragment fragment;
        String tag;
        if (itemId == R.id.nav_route_plan) {
            fragment = new RoutePlannerFragment();
            tag = "route";
        } else if (itemId == R.id.nav_reserve) {
            fragment = new ReservationFragment();
            tag = "reserve";
        } else if (itemId == R.id.nav_session) {
            fragment = new ActiveSessionFragment();
            tag = "session";
        } else if (itemId == R.id.nav_safety) {
            fragment = new SafetySOSFragment();
            tag = "safety";
        } else {
            fragment = new ChargerDiscoveryFragment();
            tag = "discover";
        }
        loadRoot(fragment, tag);
        return true;
    }

    private boolean loadHostScreen(int itemId) {
        if (itemId == R.id.nav_host_add_station) {
            loadRoot(new RegisterStationFragment(), "register");
            return true;
        }
        if (itemId == R.id.nav_host_chat) {
            loadRoot(new HostChatFragment(), "chat");
            return true;
        }
        loadRoot(new HostDashboardFragment(), "host_dashboard");
        return true;
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
