package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.communication.ChatManager;
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.entity.ChatMessage;
import com.amperly.app.data.local.entity.CommunicationThread;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.adapter.ChatMessageAdapter;
import com.google.android.material.chip.Chip;
import com.google.android.material.chip.ChipGroup;

import java.util.ArrayList;
import java.util.List;

/**
 * Reservation-scoped communication. Free-text chat is deliberately phone-only: the car display never
 * offers it. Numbers are masked, threads expire, and off-platform payment requests are flagged.
 */
public class HostChatFragment extends Fragment {

    /** Opens the inbox on the conversation with this consumer, when a booking sent the host here. */
    public static final String ARG_CONSUMER_ID = "consumer_id";

    private AmperlyRepository repo;
    private ChatMessageAdapter messageAdapter;
    private RecyclerView messagesList;
    private EditText input;
    private TextView threadTitle;
    private TextView threadExpiry;
    private TextView emptyText;
    private ChipGroup threadsChipGroup;
    private CommunicationThread activeThread;
    private String userId;
    private boolean hostMode;
    @Nullable
    private String preferredConsumerId;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_host_chat, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());
        userId = AuthManager.getInstance().getCurrentUserId();
        hostMode = AppConstants.ROLE_HOST.equals(AuthManager.getInstance().getCurrentRole());
        preferredConsumerId = getArguments() == null
                ? null : getArguments().getString(ARG_CONSUMER_ID);

        input = view.findViewById(R.id.chatInputEdit);
        threadTitle = view.findViewById(R.id.threadTitleText);
        threadExpiry = view.findViewById(R.id.threadExpiryText);
        emptyText = view.findViewById(R.id.chatEmptyText);
        threadsChipGroup = view.findViewById(R.id.threadsChipGroup);

        messagesList = view.findViewById(R.id.messagesRecyclerView);
        LinearLayoutManager layoutManager = new LinearLayoutManager(requireContext());
        layoutManager.setStackFromEnd(true);
        messagesList.setLayoutManager(layoutManager);
        messageAdapter = new ChatMessageAdapter(userId);
        messagesList.setAdapter(messageAdapter);

        ChipGroup quickQuestions = view.findViewById(R.id.quickQuestionsChipGroup);
        for (String question : ChatManager.QUICK_QUESTIONS) {
            Chip chip = new Chip(requireContext());
            chip.setText(question);
            chip.setCheckable(false);
            chip.setOnClickListener(v -> {
                input.setText(question);
                sendMessage();
            });
            quickQuestions.addView(chip);
        }

        view.findViewById(R.id.sendChatButton).setOnClickListener(v -> sendMessage());
        view.findViewById(R.id.reportThreadButton).setOnClickListener(v -> {
            if (activeThread == null) {
                Ux.error(this, getString(R.string.host_chat_select_first));
                return;
            }
            repo.reportThread(activeThread.getId());
            Ux.success(this, getString(R.string.host_chat_reported));
        });
        view.findViewById(R.id.blockThreadButton).setOnClickListener(v -> {
            if (activeThread == null) {
                Ux.error(this, getString(R.string.host_chat_select_first));
                return;
            }
            repo.blockThread(activeThread.getId());
            Ux.success(this, getString(R.string.host_chat_blocked));
        });

        if (hostMode) {
            repo.observeThreadsForHost(userId).observe(getViewLifecycleOwner(), this::bindThreads);
        } else {
            repo.observeThreadsForConsumer(userId).observe(getViewLifecycleOwner(), this::bindThreads);
        }

        // The shell reserves the keyboard's height, so the composer already sits above it. The
        // shortcuts and the report/block footer step aside while typing, which leaves the
        // composer as the last row on the page, and the transcript scrolls to the newest
        // message as it shrinks.
        Ux.keepFieldsVisible(view);
        final View quickQuestionsRow = view.findViewById(R.id.quickQuestionsRow);
        final View footerDivider = view.findViewById(R.id.chatFooterDivider);
        final View footerActions = view.findViewById(R.id.chatFooterActions);
        ViewCompat.setOnApplyWindowInsetsListener(view, (v, insets) -> {
            boolean typing = insets.isVisible(WindowInsetsCompat.Type.ime());
            int chrome = typing ? View.GONE : View.VISIBLE;
            quickQuestionsRow.setVisibility(chrome);
            footerDivider.setVisibility(chrome);
            footerActions.setVisibility(chrome);
            if (typing) {
                scrollToLatest();
            }
            return insets;
        });
    }

    /** Keeps the conversation at the newest message, where the reply will be read. */
    private void scrollToLatest() {
        if (messagesList == null || messageAdapter == null) {
            return;
        }
        int last = messageAdapter.getItemCount() - 1;
        if (last >= 0) {
            messagesList.scrollToPosition(last);
        }
    }

    private void bindThreads(List<CommunicationThread> threads) {
        threadsChipGroup.removeAllViews();
        if (threads == null || threads.isEmpty()) {
            threadTitle.setText(hostMode ? R.string.host_chat_none_host : R.string.host_chat_none);
            threadExpiry.setText(R.string.host_chat_empty_body);
            emptyText.setVisibility(View.VISIBLE);
            return;
        }
        CommunicationThread initial = preferredThread(threads);
        for (CommunicationThread thread : threads) {
            Chip chip = new Chip(requireContext());
            String label = hostMode ? thread.getConsumerName() : thread.getHostName();
            chip.setText(label == null ? getString(R.string.host_chat_conversation) : label);
            chip.setCheckable(true);
            chip.setChecked(!thread.isBlocked() && thread == initial);
            chip.setOnClickListener(v -> selectThread(thread));
            threadsChipGroup.addView(chip);
        }
        selectThread(initial);
    }

    /**
     * The conversation the caller asked for — one booking's driver — or the most recent one.
     *
     * <p>A host opens chat from a booking card, and the pair's thread is the only one that
     * belongs to that booking; landing on a different driver's chat would be a mix-up.
     */
    private CommunicationThread preferredThread(List<CommunicationThread> threads) {
        if (preferredConsumerId != null) {
            for (CommunicationThread thread : threads) {
                if (preferredConsumerId.equals(thread.getConsumerId())) {
                    return thread;
                }
            }
        }
        return threads.get(0);
    }

    private void selectThread(CommunicationThread thread) {
        activeThread = thread;
        threadTitle.setText(getString(R.string.host_chat_title,
                hostMode ? thread.getConsumerName() : thread.getHostName(),
                thread.getReservationId()));
        boolean open = ChatManager.isThreadOpen(thread, System.currentTimeMillis());
        String expiry = open
                ? getString(R.string.host_chat_closes_on, ChatManager.expiryLabel(thread.getExpiresAtMs()))
                : getString(R.string.host_chat_has_expired);
        threadExpiry.setText(getString(R.string.host_chat_masked,
                thread.getMaskedConsumerNumber(), thread.getMaskedHostNumber(), expiry));
        if (!open) {
            emptyText.setVisibility(View.VISIBLE);
            emptyText.setText(R.string.chat_expired);
        }

        repo.observeMessages(thread.getId()).observe(getViewLifecycleOwner(), messages -> {
            messageAdapter.submit(messages);
            emptyText.setVisibility(messages == null || messages.isEmpty() ? View.VISIBLE : View.GONE);
        });
    }

    private void sendMessage() {
        String text = input.getText().toString().trim();
        if (TextUtils.isEmpty(text)) {
            return;
        }
        if (activeThread == null) {
            Ux.error(this, getString(R.string.host_chat_select_or_reserve));
            return;
        }
        if (!ChatManager.isThreadOpen(activeThread, System.currentTimeMillis())) {
            Ux.toast(this, getString(R.string.chat_expired));
            return;
        }

        User me = AuthManager.getInstance().getCurrentUser();
        String receiver = hostMode ? activeThread.getConsumerId() : activeThread.getHostId();
        String otherPhone = hostMode ? activeThread.getMaskedHostNumber() : activeThread.getMaskedConsumerNumber();

        ChatMessage message = ChatManager.createMessage(activeThread.getId(),
                activeThread.getReservationId(), me.getId(), receiver, text, me.getPhone(), otherPhone);
        repo.saveMessage(message);
        if (ChatManager.containsOffPlatformPaymentRequest(text)) {
            Ux.toast(this, getString(R.string.chat_off_platform_warning));
        }
        input.setText("");

        if (activeThread.getReservationId() != null) {
            repo.background(() -> {
                Reservation reservation = repo.getReservationSync(activeThread.getReservationId());
                return reservation == null ? null : reservation.getStationName();
            }, stationName -> {
                if (stationName != null) {
                    AppStateStore.get().setLastRecalculationSummary("");
                }
            });
        }
    }
}
