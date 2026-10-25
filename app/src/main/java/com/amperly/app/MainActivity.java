package com.amperly.app;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
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
import com.amperly.app.core.state.SocStore;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.local.entity.Vehicle;
import com.amperly.app.data.remote.SupabaseAuth;
import com.amperly.app.data.remote.SupabaseConfig;
import com.amperly.app.data.remote.SyncEngine;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.feature.admin.AdminDashboardFragment;
import com.amperly.app.feature.auth.AccountFragment;
import com.amperly.app.feature.auth.SignInFragment;
import com.amperly.app.feature.common.NotificationsFragment;
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
import com.google.android.material.dialog.MaterialAlertDialogBuilder;

/**
 * The application shell: app bar, mode strip, one fragment container and the bottom
 * navigation.
 */
public class MainActivity extends AppCompatActivity {

    private static final String TAG = "Amperly";

    /** Remembers which account the on-device cache belongs to, so it is only wiped for a new one. */
    private static final String PREFS = "amperly_session";
    private static final String KEY_LAST_USER = "last_user_id";

    private BottomNavigationView bottomNavigationView;

    /** The profile trigger in the top bar, kept so its name and role can be re-rendered. */
    private View profileBadgeView;

    /** The shell's chrome, hidden on the sign-in screen so its own brand header is the only one. */
    private View appBarLayout;
    private View appBarDivider;
    private View fragmentContainer;

    private AmperlyRepository repo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
            setContentView(R.layout.activity_main);
            applyWindowInsets();

            repo = AmperlyRepository.getInstance(this);

            // Registers the back handling before any screen can be shown, so a gesture made
            // straight after launch is never answered by the system finishing the activity.
            getOnBackPressedDispatcher().addCallback(this, new OnBackPressedCallback(true) {
                @Override
                public void handleOnBackPressed() {
                    handleBack();
                }
            });

            Toolbar toolbar = findViewById(R.id.topToolbar);
            setSupportActionBar(toolbar);
            // The wordmark in the custom lock-up is the title. An empty toolbar title is not
            // enough: AppCompat restores the activity label, which drew "Amperly" beside the
            // lock-up and pushed it into the middle of the bar. Turning the title off is what
            // actually removes it.
            if (getSupportActionBar() != null) {
                getSupportActionBar().setDisplayShowTitleEnabled(false);
            }
            makeToolbarHome(toolbar);

            bottomNavigationView = findViewById(R.id.bottomNavigationView);
            appBarLayout = findViewById(R.id.appBarLayout);
            appBarDivider = findViewById(R.id.appBarDivider);
            fragmentContainer = findViewById(R.id.fragment_container);

            handleDeepLink(getIntent());
            startBackend();
        } catch (Exception e) {
            Log.e(TAG, "Critical error in MainActivity onCreate: " + e.getMessage(), e);
            try {
                // Never fall back to fabricated data: show the sign-in screen, which can
                // explain that the account is what the data is authorised against.
                showSignIn();
            } catch (Exception ignored) {}
        }
    }

    /**
     * Back, from either the gesture or the navigation bar.
     *
     * <p>Three levels, in order: the fragment stack (station details → reservation → booking),
     * the role's home screen (a tab, the account page or another root-level page), and finally
     * the system, which leaves the app. Without the middle level every root-level page — the
     * account page, a tab, a host screen — left the app on the first gesture, because those
     * pages replace the container rather than stacking on it.
     */
    private void handleBack() {
        FragmentManager manager = getSupportFragmentManager();
        if (manager.getBackStackEntryCount() > 0) {
            manager.popBackStack();
            return;
        }
        if (isAtHomeScreen() || bottomNavigationView == null
                || bottomNavigationView.getVisibility() != View.VISIBLE) {
            // Home is the top of the in-app stack: leaving it leaves the app, as expected.
            finish();
            return;
        }
        goHome();
    }

    /** True when the container already shows the current role's home screen (or sign-in). */
    private boolean isAtHomeScreen() {
        Fragment current = getSupportFragmentManager()
                .findFragmentById(R.id.fragment_container);
        if (current == null) {
            return true;
        }
        if (current instanceof SignInFragment) {
            return true;
        }
        String role = AuthManager.getInstance().getCurrentRole();
        if (AppConstants.ROLE_HOST.equals(role)) {
            return current instanceof HostDashboardFragment;
        }
        if (AppConstants.ROLE_ADMIN.equals(role)) {
            return current instanceof AdminDashboardFragment;
        }
        return current instanceof ChargerDiscoveryFragment;
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
                // Any installed app can fire this custom scheme, so the intent is treated as
                // "the user came back", never as proof that an address was confirmed. The
                // real confirmation is the session GoTrue issues at sign-in.
                Ux.toast(this, getString(R.string.auth_callback_return));
            }
        }
    }

    /**
     * Shows or hides the top bar.
     *
     * <p>Hidden only on sign-in, where the page carries its own brand lock-up; drawing both
     * would spell the brand twice, one above the other. The container is asked for fresh insets
     * so its top padding follows the change instead of waiting for the next configuration pass.
     */
    private void setChromeVisible(boolean visible) {
        int visibility = visible ? View.VISIBLE : View.GONE;
        if (appBarLayout != null) appBarLayout.setVisibility(visibility);
        if (appBarDivider != null) appBarDivider.setVisibility(visibility);
        if (fragmentContainer != null) ViewCompat.requestApplyInsets(fragmentContainer);
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

        // The sign-in screen has no app bar, so the container takes the status-bar inset itself
        // in that state; otherwise the page would slide under the clock.
        if (fragmentContainer != null) {
            ViewCompat.setOnApplyWindowInsetsListener(fragmentContainer, (view, windowInsets) -> {
                Insets bars = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
                boolean chromeVisible = appBarLayout != null
                        && appBarLayout.getVisibility() == View.VISIBLE;
                view.setPadding(0, chromeVisible ? 0 : bars.top, 0, 0);
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

    private void startBackend() {
        try {
            if (!SupabaseConfig.isConfigured() || SupabaseConfig.looksLikeSecretKey()) {
                // The server is the only source of truth, so there is nothing to show without
                // it. The sign-in screen states the problem instead of seeding a local pilot.
                if (SupabaseConfig.looksLikeSecretKey()) {
                    Log.e(TAG, "SUPABASE_PUBLISHABLE_KEY is a secret key. Sync is disabled; replace "
                            + "it with the publishable key in local.properties.");
                    Ux.toast(this, getString(R.string.auth_secret_key));
                }
                showSignIn();
                return;
            }
            if (SupabaseAuth.hasStoredSession(this)) {
                if (bottomNavigationView != null) bottomNavigationView.setVisibility(View.GONE);
                restoreSession();
            } else {
                showSignIn();
            }
        } catch (Exception e) {
            Log.e(TAG, "Error starting backend: " + e.getMessage());
            showSignIn();
        }
    }

    public void showSignIn() {
        if (bottomNavigationView != null) bottomNavigationView.setVisibility(View.GONE);
        setChromeVisible(false);
        getSupportFragmentManager()
                .popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
        getSupportFragmentManager()
                .beginTransaction()
                .replace(R.id.fragment_container, new SignInFragment(), "sign_in")
                .commit();
        invalidateOptionsMenu();
    }

    public void onSignedIn(User user) {
        AuthManager.getInstance().setCurrentUser(user);
        // The battery reading the driver last confirmed survives a restart, but it belongs to
        // a vehicle: once the cache says which profile is active, that profile's reading is
        // applied and the previous vehicle's figure is dropped instead of following the switch.
        repo.background(() -> repo.getVehicleSync(user.getId()), active -> {
            Vehicle vehicle = active;
            if (vehicle == null) {
                AppStateStore.get().applyStoredSoc(null, -1);
                return;
            }
            AppStateStore.get().applyStoredSoc(vehicle.getId(),
                    SocStore.load(this, user.getId(), vehicle.getId()));
        });
        // Capacity is switched on the Profile page, so the shell itself stays identical.
        if (bottomNavigationView != null) bottomNavigationView.setVisibility(View.VISIBLE);
        setChromeVisible(true);
        // An administrator signs in to work the verification queue, not to browse chargers;
        // landing them in Consumer hid the only screens their account exists for.
        applyRole(user.isPlatformAdmin() ? AppConstants.ROLE_ADMIN : AppConstants.ROLE_CONSUMER);
        invalidateOptionsMenu();
        Ux.toast(this, getString(R.string.auth_signed_in_as) + " " + user.getName());
        if (repo.didProfileWriteFail()) {
            // The account exists on the device but not in public.users, which makes it anonymous
            // to every RLS policy. Say so instead of showing an app that looks broken.
            Ux.toast(this, getString(R.string.auth_profile_local_only));
        }
        syncAfterSignIn();
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

    /**
     * Pulls the account's data from Supabase after a sign-in.
     *
     * <p>Room is only a cache, so it is wiped when a DIFFERENT account signs in — otherwise one
     * person's stations and reservations would linger under another person's session. The same
     * account signing in again keeps its cache, which is what makes the app usable offline.
     */
    private void syncAfterSignIn() {
        repo.background(() -> {
            User currentUser = AuthManager.getInstance().getCurrentUser();
            if (currentUser != null) {
                String previousUserId = getSharedPreferences(PREFS, MODE_PRIVATE)
                        .getString(KEY_LAST_USER, "");
                if (!currentUser.getId().equals(previousUserId)) {
                    repo.clearLocalData();
                    try {
                        repo.database().userDao().insert(currentUser);
                    } catch (Exception ignored) {}
                    getSharedPreferences(PREFS, MODE_PRIVATE).edit()
                            .putString(KEY_LAST_USER, currentUser.getId()).apply();
                }
            }
            return SyncEngine.syncNow(this, repo.database());
        }, result -> {
            if (result != null) {
                Log.i(TAG, "Signed-in sync: " + result.summary());
                // The screens were built against an empty cache; rebuild so the pulled rows
                // appear without the user having to leave and come back.
                if (bottomNavigationView != null
                        && bottomNavigationView.getVisibility() == View.VISIBLE) {
                    buildNavigation(AuthManager.getInstance().getCurrentRole());
                }
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
        profileBadgeView = badge;
        renderProfileBadge();
        badge.setOnClickListener(this::showProfileMenu);

        // Toolbar action views ignore their own layout margin, so the chip used to sit flush
        // against the right edge. A holder whose padding is part of its measured width keeps
        // the gutter without hard-coding it into the chip.
        FrameLayout holder = new FrameLayout(this);
        int end = Math.round(getResources().getDisplayMetrics().density * 8);
        holder.setPadding(0, 0, end, 0);
        holder.addView(badge, new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.MATCH_PARENT));
        return holder;
    }

    /**
     * Paints the monogram, the name and the current capacity into the top bar.
     *
     * <p>Called again after a rename and after a role switch, so the bar never shows a stale
     * name or the wrong capacity. The menu is not invalidated: replacing the action view while
     * its popup is open would detach the view the popup is anchored to.
     */
    private void renderProfileBadge() {
        if (profileBadgeView == null) {
            return;
        }
        AuthManager auth = AuthManager.getInstance();
        User user = auth.getCurrentUser();

        TextView initials = profileBadgeView.findViewById(R.id.profileBadgeText);
        TextView nameText = profileBadgeView.findViewById(R.id.profileNameText);
        TextView roleText = profileBadgeView.findViewById(R.id.profileRoleText);

        if (initials != null) {
            initials.setText(initialsOf(user == null ? null : user.getName()));
        }
        if (nameText != null) {
            nameText.setText(user == null
                    ? getString(R.string.account_signed_in)
                    : user.getName());
        }
        if (roleText != null) {
            roleText.setText(AuthManager.roleLabel(auth.getCurrentRole()));
        }
    }

    /** Re-renders the top-bar identity after the account page renames the signed-in person. */
    public void refreshProfileBadge() {
        renderProfileBadge();
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
        if (item.getItemId() == R.id.action_notifications) {
            // The bell is the shortcut to the same inbox the Account page links to, so the
            // inbox is one tap away from any tab instead of three.
            Navigator.openRoot(this, new NotificationsFragment(), "notifications");
            return true;
        }
        // The remaining destinations live in the profile dropdown, which is triggered from the
        // badge's own click listener rather than from a menu item id.
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
        getSharedPreferences(PREFS, MODE_PRIVATE).edit().remove(KEY_LAST_USER).apply();
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
     * Switches capacity from the Profile page. The account never changes, only what it is
     * currently acting as, so a Consumer booking a slot and a Host listing a charger are the
     * same signed-in person.
     */
    public void switchRole(String role) {
        applyRole(role);
        // Stay on the Profile page while the capacity changes: rebuilding the navigation
        // selects the role's home, so ask for Profile again. Admin has no Profile tab.
        if (bottomNavigationView != null
                && !AppConstants.ROLE_ADMIN.equals(AuthManager.getInstance().getCurrentRole())) {
            bottomNavigationView.setSelectedItemId(R.id.nav_profile);
        }
    }

    private void applyRole(String role) {
        AuthManager auth = AuthManager.getInstance();
        String target = role;
        if (!auth.setRole(target)) {
            // No authority for that capacity; fall back rather than pretend otherwise.
            target = AppConstants.ROLE_CONSUMER;
            auth.setRole(target);
        }
        AppStateStore.get().setUserId(auth.getCurrentUserId());
        renderProfileBadge();
        buildNavigation(target);
    }

    private void buildNavigation(String role) {
        if (bottomNavigationView == null) return;
        Menu menu = bottomNavigationView.getMenu();
        menu.clear();
        bottomNavigationView.setOnItemSelectedListener(null);

        if (AppConstants.ROLE_HOST.equals(role)) {
            menu.add(0, R.id.nav_host_dashboard, 0, R.string.nav_dashboard).setIcon(R.drawable.ic_dashboard);
            menu.add(0, R.id.nav_host_add_station, 1, R.string.nav_stations).setIcon(R.drawable.ic_pin);
            menu.add(0, R.id.nav_host_bookings, 2, R.string.nav_bookings).setIcon(R.drawable.ic_reserve);
            menu.add(0, R.id.nav_profile, 3, R.string.nav_profile).setIcon(R.drawable.ic_account);
            bottomNavigationView.setOnItemSelectedListener(item -> loadHostScreen(item.getItemId()));
            // Selecting the item runs the listener above, which loads the screen. Calling
            // loadRoot here as well built a second fragment and detached the first one while its
            // map was still being attached — the crash this method used to cause on sign-in.
            selectNavigationItem(R.id.nav_host_dashboard);
            return;
        }

        if (AppConstants.ROLE_ADMIN.equals(role)) {
            menu.add(0, R.id.nav_admin_queue, 0, R.string.nav_admin_queue).setIcon(R.drawable.ic_queue);
            menu.add(0, R.id.nav_admin_disputes, 1, R.string.nav_admin_disputes).setIcon(R.drawable.ic_gavel);
            menu.add(0, R.id.nav_admin_reports, 2, R.string.nav_admin_reports).setIcon(R.drawable.ic_flag);
            bottomNavigationView.setOnItemSelectedListener(item -> loadAdminScreen(item.getItemId()));
            selectNavigationItem(R.id.nav_admin_queue);
            return;
        }

        menu.add(0, R.id.nav_discover, 0, R.string.nav_discover).setIcon(R.drawable.ic_discover);
        menu.add(0, R.id.nav_route_plan, 1, R.string.nav_trips).setIcon(R.drawable.ic_route);
        menu.add(0, R.id.nav_reserve, 2, R.string.nav_bookings).setIcon(R.drawable.ic_reserve);
        menu.add(0, R.id.nav_profile, 3, R.string.nav_profile).setIcon(R.drawable.ic_account);
        bottomNavigationView.setOnItemSelectedListener(item -> loadConsumerScreen(item.getItemId()));
        selectNavigationItem(R.id.nav_discover);
    }

    /**
     * Selects a tab, and loads its screen even when that tab was already the selected one.
     *
     * <p>{@code setSelectedItemId} fires the listener only when the id actually changes. After a
     * pull the shell rebuilds the menu with the same tab still selected, so the listener never ran
     * and the screen kept the rows it had read from an empty cache. Loading explicitly is what
     * makes the post-sync rebuild do something.
     */
    private void selectNavigationItem(int itemId) {
        if (bottomNavigationView == null) {
            return;
        }
        if (bottomNavigationView.getSelectedItemId() == itemId) {
            loadNavigationItem(itemId);
            return;
        }
        bottomNavigationView.setSelectedItemId(itemId);
    }

    /** Routes a tab id to the loader for the role that is currently acting. */
    private void loadNavigationItem(int itemId) {
        String role = AuthManager.getInstance().getCurrentRole();
        if (AppConstants.ROLE_HOST.equals(role)) {
            loadHostScreen(itemId);
        } else if (AppConstants.ROLE_ADMIN.equals(role)) {
            loadAdminScreen(itemId);
        } else {
            loadConsumerScreen(itemId);
        }
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
        } else if (itemId == R.id.nav_profile) {
            fragment = new AccountFragment();
            tag = "account";
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
        if (itemId == R.id.nav_profile) {
            loadRoot(new AccountFragment(), "account");
            return true;
        }
        if (itemId == R.id.nav_host_bookings) {
            HostDashboardFragment bookings = new HostDashboardFragment();
            Bundle args = new Bundle();
            args.putString(HostDashboardFragment.ARG_SECTION, HostDashboardFragment.SECTION_BOOKINGS);
            bookings.setArguments(args);
            loadRoot(bookings, "host_dashboard");
            return true;
        }
        loadRoot(new HostDashboardFragment(), "host_dashboard");
        return true;
    }

    private boolean loadAdminScreen(int itemId) {
        AdminDashboardFragment admin = new AdminDashboardFragment();
        Bundle args = new Bundle();
        if (itemId == R.id.nav_admin_disputes) {
            args.putString(AdminDashboardFragment.ARG_SECTION, AdminDashboardFragment.SECTION_DISPUTES);
        } else if (itemId == R.id.nav_admin_reports) {
            args.putString(AdminDashboardFragment.ARG_SECTION, AdminDashboardFragment.SECTION_REPORTS);
        } else {
            args.putString(AdminDashboardFragment.ARG_SECTION, AdminDashboardFragment.SECTION_QUEUE);
        }
        admin.setArguments(args);
        loadRoot(admin, "admin");
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
