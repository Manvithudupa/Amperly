package com.amperly.app.feature.common;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.Notification;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.ui.adapter.NotificationAdapter;

import java.util.List;

/**
 * Read-only inbox for the notifications that reservations and host/admin events already store.
 * Consumer, host and admin accounts all get their own rows, scoped server-side by RLS.
 */
public class NotificationsFragment extends Fragment {

    private NotificationAdapter adapter;
    private View emptyState;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_notifications, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        String userId = AuthManager.getInstance().getCurrentUserId();
        AmperlyRepository repository = AmperlyRepository.getInstance(requireContext());

        emptyState = view.findViewById(R.id.notificationsEmptyText);
        adapter = new NotificationAdapter();
        RecyclerView list = view.findViewById(R.id.notificationsRecyclerView);
        list.setLayoutManager(new LinearLayoutManager(requireContext()));
        list.setAdapter(adapter);

        repository.observeNotifications(userId).observe(getViewLifecycleOwner(), this::render);
        // Opening the inbox is reading it; the observer repaints the rows without the unread dot.
        repository.markNotificationsRead(userId);
    }

    private void render(List<Notification> notifications) {
        adapter.submit(notifications);
        if (emptyState != null) {
            emptyState.setVisibility(notifications == null || notifications.isEmpty()
                    ? View.VISIBLE : View.GONE);
        }
    }
}
