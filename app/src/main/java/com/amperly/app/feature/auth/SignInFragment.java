package com.amperly.app.feature.auth;

import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.MainActivity;
import com.amperly.app.R;
import com.amperly.app.core.common.UserMessages;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.remote.SupabaseAuth;
import com.amperly.app.data.remote.SupabaseConfig;
import com.amperly.app.data.remote.SupabaseRest;
import com.amperly.app.data.repository.AmperlyRepository;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.progressindicator.LinearProgressIndicator;
import com.google.android.material.textfield.TextInputLayout;

/**
 * Sign in or create an account.
 *
 * <p>Why this screen exists at all: every read and write in the app is authorised against
 * the signed-in Supabase account. With no session, Row Level Security returns no rows, so
 * the app would look empty — the screen is the difference between "nothing here" and a
 * working pilot. There is no offline demo path: the server is the only source of truth.
 *
 * <p>The work happens on a background thread through {@code AmperlyRepository.background},
 * and every failure is caught inside {@link #attempt} so that the reason survives. Letting
 * the executor swallow it would reduce a wrong password and an unreachable server to the
 * same blank look.
 */
public class SignInFragment extends Fragment {

    private AmperlyRepository repo;
    private EditText nameEdit;
    private EditText emailEdit;
    private EditText passwordEdit;
    private TextInputLayout nameField;
    private TextInputLayout emailField;
    private TextInputLayout passwordField;
    private TextView headingText;
    private TextView errorText;
    private TextView infoText;
    private TextView offlineNoteText;
    private MaterialButton signInButton;
    private MaterialButton createAccountButton;
    private LinearProgressIndicator progress;

    /** True while the page is asking for a new account rather than signing an existing one in. */
    private boolean createMode;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_sign_in, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());

        nameEdit = view.findViewById(R.id.signInNameEdit);
        emailEdit = view.findViewById(R.id.signInEmailEdit);
        passwordEdit = view.findViewById(R.id.signInPasswordEdit);
        nameField = view.findViewById(R.id.nameInputLayout);
        emailField = view.findViewById(R.id.emailInputLayout);
        passwordField = view.findViewById(R.id.passwordInputLayout);
        headingText = view.findViewById(R.id.authHeadingText);
        errorText = view.findViewById(R.id.signInErrorText);
        infoText = view.findViewById(R.id.signInInfoText);
        offlineNoteText = view.findViewById(R.id.signInOfflineNoteText);
        signInButton = view.findViewById(R.id.signInButton);
        createAccountButton = view.findViewById(R.id.createAccountButton);
        progress = view.findViewById(R.id.signInProgress);

        boolean configured = serverConfigured();
        // Without a configured project there is no account to authorise against, so the screen
        // says exactly that instead of offering a local-only way in.
        offlineNoteText.setVisibility(configured ? View.GONE : View.VISIBLE);

        signInButton.setOnClickListener(v -> submit(createMode));
        // "Create account" is a mode switch, not an immediate sign-up: it reveals the name
        // field and turns the primary button into the one that creates the account.
        createAccountButton.setOnClickListener(v -> setCreateMode(!createMode));
        // A field-level error belongs on the field, and it goes away as soon as the field is
        // edited rather than staying until the next submit.
        nameEdit.addTextChangedListener(clearErrorOnEdit(nameField));
        emailEdit.addTextChangedListener(clearErrorOnEdit(emailField));
        passwordEdit.addTextChangedListener(clearErrorOnEdit(passwordField));
        passwordEdit.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                submit(createMode);
                return true;
            }
            return false;
        });

        setBusy(false, false);
    }

    @Override
    public void onResume() {
        super.onResume();
        setBusy(false, false);
    }

    private boolean serverConfigured() {
        return SupabaseConfig.isConfigured() && !SupabaseConfig.looksLikeSecretKey();
    }

    // ------------------------------------------------------------------ actions

    private void submit(boolean createAccount) {
        String name = nameEdit.getText().toString().trim();
        String email = emailEdit.getText().toString().trim();
        String password = passwordEdit.getText().toString();
        hideMessages();
        if (nameField != null) nameField.setError(null);
        if (emailField != null) emailField.setError(null);
        if (passwordField != null) passwordField.setError(null);

        if (createAccount && TextUtils.isEmpty(name)) {
            if (nameField != null) {
                nameField.setError(getString(R.string.auth_name_required));
            }
            nameEdit.requestFocus();
            return;
        }
        if (TextUtils.isEmpty(email) || !email.contains("@")) {
            if (emailField != null) {
                emailField.setError(getString(R.string.auth_email_required));
            }
            emailEdit.requestFocus();
            return;
        }
        if (password.length() < 6) {
            if (passwordField != null) {
                passwordField.setError(getString(R.string.auth_password_too_short));
            }
            passwordEdit.requestFocus();
            return;
        }

        Context appContext = requireContext().getApplicationContext();
        setBusy(true, createAccount);
        repo.background(() -> attempt(appContext, name, email, password, createAccount), this::handle);
    }

    // ------------------------------------------------------------- background

    /** Runs on a background thread. Never throws: the reason for a failure is the result. */
    private Outcome attempt(Context appContext, String name, String email, String password,
                            boolean createAccount) {
        try {
            SupabaseAuth.Session session = createAccount
                    ? SupabaseAuth.signUp(appContext, email, password, name)
                    : SupabaseAuth.signIn(appContext, email, password);

            if (session == null) {
                // Sign-up succeeded but the project requires email confirmation.
                return Outcome.notice(
                        appContext.getString(R.string.auth_confirm_email, email));
            }

            User user = repo.resolveOrCreateAppUser(session.authUserId, session.email,
                    createAccount ? name : null);
            if (user == null) {
                return Outcome.failed(appContext.getString(R.string.auth_no_profile));
            }
            return Outcome.signedIn(user);
        } catch (SupabaseAuth.Failure failure) {
            // A rejected sign-in is about the credentials, not the network. The generic text
            // says so when the server's reason is something the classifier does not know.
            return Outcome.failed(UserMessages.from(appContext, failure,
                    R.string.auth_failed_generic));
        } catch (SupabaseAuth.NetworkFailure network) {
            return Outcome.failed(UserMessages.from(appContext, network,
                    R.string.auth_unexpected));
        } catch (SupabaseRest.RestException rest) {
            return Outcome.failed(UserMessages.from(appContext, rest,
                    R.string.auth_no_profile));
        } catch (RuntimeException unexpected) {
            // Not necessarily a connection problem: a local failure (the secure session store,
            // for one) lands here, and blaming the internet sent people the wrong way.
            return Outcome.failed(UserMessages.from(appContext, unexpected,
                    R.string.auth_not_completed));
        }
    }

    private void handle(@Nullable Outcome outcome) {
        if (!isAdded()) {
            return;
        }
        setBusy(false, false);
        if (outcome == null) {
            showError(getString(R.string.auth_not_completed));
            return;
        }
        if (outcome.isSuccess()) {
            passwordEdit.setText("");
            if (getActivity() instanceof MainActivity) {
                ((MainActivity) getActivity()).onSignedIn(outcome.user);
            }
            return;
        }
        if (outcome.info) {
            // Sign-up succeeded but the email still has to be confirmed. Go back to sign-in
            // so the confirmed address can be used without the name field in the way.
            setCreateMode(false);
            showInfo(outcome.message);
        } else {
            showError(outcome.message);
        }
    }

    // ------------------------------------------------------------------- view

    private void setBusy(boolean busy, boolean createAccount) {
        boolean configured = serverConfigured();
        progress.setVisibility(busy ? View.VISIBLE : View.GONE);
        nameEdit.setEnabled(!busy);
        emailEdit.setEnabled(!busy);
        passwordEdit.setEnabled(!busy);
        signInButton.setEnabled(!busy && configured);
        createAccountButton.setEnabled(!busy && configured);
        if (busy) {
            signInButton.setText(createAccount
                    ? R.string.auth_creating : R.string.auth_signing_in);
        } else {
            signInButton.setText(createMode
                    ? R.string.auth_create_account : R.string.auth_sign_in);
        }
    }

    /**
     * Switches between signing in and creating an account.
     *
     * <p>The name field exists only in create mode: an existing account already has a display
     * name, and asking for it again on every sign-in would be noise. The label on the primary
     * button follows the mode, so there is one action to take in each state.
     */
    private void setCreateMode(boolean enabled) {
        createMode = enabled;
        nameField.setVisibility(enabled ? View.VISIBLE : View.GONE);
        headingText.setText(enabled ? R.string.auth_create_account : R.string.auth_title);
        signInButton.setText(enabled ? R.string.auth_create_account : R.string.auth_sign_in);
        createAccountButton.setText(enabled
                ? R.string.auth_have_account : R.string.auth_create_account);
        if (nameField != null) nameField.setError(null);
        hideMessages();
        if (enabled) {
            nameEdit.requestFocus();
        }
    }

    private void hideMessages() {
        errorText.setVisibility(View.GONE);
        infoText.setVisibility(View.GONE);
    }

    private android.text.TextWatcher clearErrorOnEdit(final TextInputLayout field) {
        return new android.text.TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(android.text.Editable s) {
                if (field != null) {
                    field.setError(null);
                }
            }
        };
    }

    private void showError(String message) {
        errorText.setText(message);
        errorText.setVisibility(View.VISIBLE);
        infoText.setVisibility(View.GONE);
    }

    private void showInfo(String message) {
        infoText.setText(message);
        infoText.setVisibility(View.VISIBLE);
        errorText.setVisibility(View.GONE);
    }

    /** What a background attempt produced, so the message is decided off the main thread. */
    private static final class Outcome {
        @Nullable
        final User user;
        @Nullable
        final String message;
        final boolean info;

        private Outcome(@Nullable User user, @Nullable String message, boolean info) {
            this.user = user;
            this.message = message;
            this.info = info;
        }

        static Outcome signedIn(User user) {
            return new Outcome(user, null, false);
        }

        static Outcome failed(String message) {
            return new Outcome(null, message, false);
        }

        static Outcome notice(String message) {
            return new Outcome(null, message, true);
        }

        boolean isSuccess() {
            return user != null;
        }
    }
}
