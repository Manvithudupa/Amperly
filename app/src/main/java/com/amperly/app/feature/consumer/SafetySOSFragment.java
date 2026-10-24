package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.SafetyEvent;
import com.amperly.app.data.local.entity.TrustedContact;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.adapter.ContactAdapter;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.google.android.material.textfield.TextInputLayout;

import java.util.List;
import java.util.UUID;

/**
 * Session safety. Everything here is opt-in, visible while active and time limited, and the screen
 * states plainly that Amperly is not an emergency service.
 */
public class SafetySOSFragment extends Fragment implements ContactAdapter.Listener {

    private static final long SHARING_WINDOW_MS = 60L * 60L * 1000L;

    private AmperlyRepository repo;
    private ContactAdapter contactAdapter;
    private TextView sosStatusText;
    private TextView sharingStatusText;
    private TextView historyText;
    private TextInputLayout contactNameField;
    private TextInputLayout contactPhoneField;
    private String userId;
    private SafetyEvent activeSharing;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_safety_sos, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());
        userId = AuthManager.getInstance().getCurrentUserId();

        sosStatusText = view.findViewById(R.id.sosStatusText);
        sharingStatusText = view.findViewById(R.id.sharingStatusText);
        historyText = view.findViewById(R.id.safetyHistoryText);
        contactNameField = view.findViewById(R.id.contactNameField);
        contactPhoneField = view.findViewById(R.id.contactPhoneField);

        RecyclerView contacts = view.findViewById(R.id.contactsRecyclerView);
        contacts.setLayoutManager(new LinearLayoutManager(requireContext()));
        contacts.setNestedScrollingEnabled(false);
        contactAdapter = new ContactAdapter(this);
        contacts.setAdapter(contactAdapter);

        repo.observeTrustedContacts(userId).observe(getViewLifecycleOwner(), list -> {
            contactAdapter.submit(list);
            updateSharingStatus();
        });

        ((TextView) view.findViewById(R.id.emergencyNumbersText)).setText(
                R.string.safety_demo_notice);

        View sosButton = view.findViewById(R.id.sosButton);
        sosButton.setOnClickListener(v -> Ux.info(this, getString(R.string.safety_confirm_sos)));
        sosButton.setOnLongClickListener(v -> {
            triggerSos();
            return true;
        });

        view.findViewById(R.id.addContactButton).setOnClickListener(v -> addContact(view));
        view.findViewById(R.id.shareLocationButton).setOnClickListener(v -> startSharing());
        view.findViewById(R.id.stopSharingButton).setOnClickListener(v -> stopSharing());

        clearErrorsWhileEditing(view);

        repo.expireStaleLocationSharing();
        loadState();
    }

    /** A field-level error disappears the moment the contact is corrected. */
    private void clearErrorsWhileEditing(View view) {
        TextWatcher clear = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (contactNameField != null) {
                    contactNameField.setError(null);
                }
                if (contactPhoneField != null) {
                    contactPhoneField.setError(null);
                }
            }
        };
        android.widget.EditText nameEdit = view.findViewById(R.id.contactNameEdit);
        android.widget.EditText phoneEdit = view.findViewById(R.id.contactPhoneEdit);
        if (nameEdit != null) {
            nameEdit.addTextChangedListener(clear);
        }
        if (phoneEdit != null) {
            phoneEdit.addTextChangedListener(clear);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        repo.expireStaleLocationSharing();
        loadState();
    }

    private void loadState() {
        repo.background(() -> {
            List<SafetyEvent> events = repo.getSafetyEventsSync(userId);
            activeSharing = repo.getActiveLocationSharingSync(userId);
            return events;
        }, events -> {
            if (events == null || !isAdded()) {
                return;
            }
            StringBuilder history = new StringBuilder(
                    getString(R.string.safety_history_header, events.size()));
            int shown = 0;
            for (SafetyEvent event : events) {
                if (shown++ >= 3) {
                    break;
                }
                history.append(getString(R.string.safety_history_line, event.getEmergencyType(),
                        Formatters.dateTime(event.getCreatedAtMs())))
                        .append(event.isLiveLocationSharingActive()
                                ? getString(R.string.safety_sharing_active_suffix) : "")
                        .append(event.getExpiresAtMs() > 0 && event.getExpiresAtMs() < System.currentTimeMillis()
                                ? getString(R.string.safety_sharing_ended_suffix) : "")
                        .append("\n");
            }
            historyText.setText(history.toString());
            updateSharingStatus();
        });
    }

    private void updateSharingStatus() {
        if (activeSharing != null && activeSharing.isLiveLocationSharingActive()
                && activeSharing.getExpiresAtMs() > System.currentTimeMillis()) {
            sharingStatusText.setText(getString(R.string.safety_sharing_active,
                    activeSharing.getTrustedContactPhone(),
                    Formatters.dateTime(activeSharing.getExpiresAtMs())));
        } else {
            sharingStatusText.setText(R.string.safety_sharing_off);
        }
    }

    private void triggerSos() {
        repo.background(() -> {
            SafetyEvent event = new SafetyEvent(UUID.randomUUID().toString(), userId,
                    com.amperly.app.core.state.AppStateStore.get().getActiveReservationId(),
                    "SOS", false, null, 0, System.currentTimeMillis());
            repo.saveSafetyEvent(event);
            // The SOS event itself is the record an administrator reads. A notification owned
            // by another user cannot be inserted under Row Level Security, so none is written.
            return Boolean.TRUE;
        }, ok -> {
            sosStatusText.setText(getString(R.string.safety_sos_active));
            Ux.success(this, getString(R.string.safety_sos_active));
            loadState();
        });
    }

    private void startSharing() {
        List<TrustedContact> contacts = repo.getTrustedContactsSync(userId);
        if (contacts.isEmpty()) {
            Ux.error(this, getString(R.string.safety_add_contact_first));
            return;
        }
        TrustedContact contact = contacts.get(0);
        repo.background(() -> {
            SafetyEvent event = new SafetyEvent(UUID.randomUUID().toString(), userId,
                    com.amperly.app.core.state.AppStateStore.get().getActiveReservationId(),
                    "LIVE_LOCATION", true, contact.getPhone(),
                    System.currentTimeMillis() + SHARING_WINDOW_MS, System.currentTimeMillis());
            repo.saveSafetyEvent(event);
            return event;
        }, event -> {
            activeSharing = event;
            updateSharingStatus();
            Ux.success(this, getString(R.string.safety_sharing_started, contact.getName()));
            loadState();
        });
    }

    private void stopSharing() {
        if (activeSharing == null) {
            Ux.info(this, getString(R.string.safety_sharing_already_off));
            return;
        }
        repo.background(() -> {
            activeSharing.setLiveLocationSharingActive(false);
            activeSharing.setExpiresAtMs(System.currentTimeMillis());
            repo.updateSafetyEvent(activeSharing);
            return Boolean.TRUE;
        }, ok -> {
            activeSharing = null;
            updateSharingStatus();
            Ux.success(this, getString(R.string.safety_sharing_stopped));
            loadState();
        });
    }

    private void addContact(View view) {
        android.widget.EditText nameEdit = view.findViewById(R.id.contactNameEdit);
        android.widget.EditText phoneEdit = view.findViewById(R.id.contactPhoneEdit);
        String name = nameEdit.getText().toString().trim();
        String phone = phoneEdit.getText().toString().trim();
        boolean valid = true;
        if (name.isEmpty()) {
            if (contactNameField != null) {
                contactNameField.setError(getString(R.string.safety_contact_invalid));
            }
            valid = false;
        }
        if (phone.length() < 6) {
            if (contactPhoneField != null) {
                contactPhoneField.setError(getString(R.string.safety_contact_invalid));
            }
            valid = false;
        }
        if (!valid) {
            return;
        }
        repo.background(() -> {
            repo.saveTrustedContact(new TrustedContact(UUID.randomUUID().toString(), userId, name, phone));
            return Boolean.TRUE;
        }, ok -> {
            nameEdit.setText("");
            phoneEdit.setText("");
            Ux.success(this, getString(R.string.safety_contact_saved));
        });
    }

    @Override
    public void onCall(TrustedContact contact) {
        Navigator.dial(requireContext(), contact.getPhone());
    }

    @Override
    public void onDelete(TrustedContact contact) {
        // Removing a contact is destructive: the person can no longer receive a shared location.
        new MaterialAlertDialogBuilder(requireContext())
                .setTitle(R.string.safety_delete_contact_title)
                .setMessage(getString(R.string.safety_delete_contact_body, contact.getName()))
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.action_delete, (dialog, which) -> {
                    repo.deleteTrustedContact(contact);
                    Ux.success(this, getString(R.string.safety_contact_removed));
                })
                .show();
    }
}
