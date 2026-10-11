package com.amperly.app.feature.auth;

import android.content.Context;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.MainActivity;
import com.amperly.app.R;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.core.state.DemoMode;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.remote.SupabaseAuth;
import com.amperly.app.data.remote.SupabaseConfig;
import com.amperly.app.data.repository.AmperlyRepository;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;

/**
 * The account page: who is signed in, what the sync engine is doing, and how to sign out.
 *
 * <p>It doubles as the honest status report for the two other modes the app can be in —
 * offline demo on a build with no project, and offline demo on a build that has one but
 * has not been signed in to — because "why is my data missing" is the question this screen
 * exists to answer.
 */
public class AccountFragment extends Fragment {

    private AmperlyRepository repo;
    private LinearLayout detailContainer;
    private TextView subtitleText;
    private TextView syncStatusText;
    private TextView demoNoteText;
    private TextView roleNoteText;
    private MaterialButton accountSignInButton;
    private MaterialButton syncNowButton;
    private MaterialButton signOutButton;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_account, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());

        detailContainer = view.findViewById(R.id.accountDetailContainer);
        subtitleText = view.findViewById(R.id.accountSubtitleText);
        syncStatusText = view.findViewById(R.id.accountSyncStatusText);
        demoNoteText = view.findViewById(R.id.accountDemoNoteText);
        roleNoteText = view.findViewById(R.id.accountRoleNoteText);
        accountSignInButton = view.findViewById(R.id.accountSignInButton);
        syncNowButton = view.findViewById(R.id.syncNowButton);
        signOutButton = view.findViewById(R.id.signOutButton);

        boolean signedIn = SupabaseAuth.isSignedIn();
        boolean configured = SupabaseConfig.isConfigured() && !SupabaseConfig.looksLikeSecretKey();
        boolean offlineDemo = DemoMode.isOfflineDemo(requireContext());

        signOutButton.setVisibility(signedIn ? View.VISIBLE : View.GONE);
        syncNowButton.setVisibility(signedIn ? View.VISIBLE : View.GONE);
        demoNoteText.setVisibility(signedIn ? View.GONE : View.VISIBLE);
        roleNoteText.setVisibility(signedIn ? View.VISIBLE : View.GONE);
        accountSignInButton.setVisibility(
                !signedIn && configured && offlineDemo ? View.VISIBLE : View.GONE);

        render(AuthManager.getInstance().getCurrentUser(), signedIn);

        syncNowButton.setOnClickListener(v -> syncNow());
        signOutButton.setOnClickListener(v -> confirmSignOut());
        accountSignInButton.setOnClickListener(v -> {
            if (getActivity() instanceof MainActivity) {
                ((MainActivity) getActivity()).showSignIn();
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();
        loadSyncStatus();
    }

    /**
     * Reads the sync state off the main thread.
     *
     * <p>{@code statusSummary} counts rows in the outbox and Room refuses queries on the main
     * thread, so it cannot be read inline. The label keeps its previous text until the answer
     * arrives rather than flashing empty.
     */
    private void loadSyncStatus() {
        repo.background(() -> repo.syncStatus(), status -> {
            if (isAdded() && status != null) {
                syncStatusText.setText(status);
            }
        });
    }

    // ------------------------------------------------------------------ render

    private void render(@Nullable User user, boolean signedIn) {
        detailContainer.removeAllViews();

        if (user == null) {
            subtitleText.setText(R.string.account_demo_mode);
            return;
        }

        subtitleText.setText(signedIn
                ? getString(R.string.auth_signed_in_as) + " " + user.getName()
                : getString(R.string.account_demo_mode));

        addRow(getString(R.string.account_name), user.getName());
        addRow(getString(R.string.account_email), user.getEmail());
        addRow(getString(R.string.account_role), AuthManager.roleLabel(user.getRole()));
        addRow(getString(R.string.account_organization), user.getOrganizationName());
        addRow(getString(R.string.account_verification), user.getVerificationStatus());
        addRow(getString(R.string.account_id), user.getId());
    }

    /**
     * A label above its value. Built in code rather than declared, so the six rows stay
     * identical instead of drifting apart in XML.
     */
    private void addRow(String label, @Nullable String value) {
        Context context = requireContext();
        float density = getResources().getDisplayMetrics().density;

        LinearLayout row = new LinearLayout(context);
        row.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams rowParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        rowParams.topMargin = (int) (density * 10);
        row.setLayoutParams(rowParams);

        TextView labelView = new TextView(context);
        labelView.setText(label);
        labelView.setTextAppearance(R.style.TextAppearance_Amperly_Label);
        row.addView(labelView);

        TextView valueView = new TextView(context);
        valueView.setText(value == null || value.trim().isEmpty() ? "—" : value);
        valueView.setTextAppearance(R.style.TextAppearance_Amperly_BodyStrong);
        valueView.setGravity(Gravity.START);
        row.addView(valueView);

        detailContainer.addView(row);
    }

    // ------------------------------------------------------------------ actions

    private void syncNow() {
        syncNowButton.setEnabled(false);
        repo.syncNow(result -> {
            if (!isAdded()) {
                return;
            }
            syncNowButton.setEnabled(true);
            if (result == null) {
                loadSyncStatus();
            } else {
                syncStatusText.setText(getString(R.string.account_synced, result.summary()));
            }
        });
    }

    private void confirmSignOut() {
        new MaterialAlertDialogBuilder(requireContext())
                .setTitle(R.string.account_sign_out)
                .setMessage(R.string.account_sign_out_confirm)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.account_sign_out, (dialog, which) -> signOut())
                .show();
    }

    /**
     * Ends the session and wipes the local copy.
     *
     * <p>Wiping matters: Room holds the reservations, receipts and messages that Row Level
     * Security only let this account see. Leaving them behind would show them to whoever
     * signs in next on a shared device.
     */
    private void signOut() {
        Context appContext = requireContext().getApplicationContext();
        repo.background(() -> {
            SupabaseAuth.signOut(appContext);
            repo.clearLocalData();
            return Boolean.TRUE;
        }, done -> {
            if (!isAdded()) {
                return;
            }
            AuthManager.getInstance().clearCurrentUser();
            AppStateStore.get().reset();
            if (getActivity() instanceof MainActivity) {
                ((MainActivity) getActivity()).onSignedOut();
            }
        });
    }
}
