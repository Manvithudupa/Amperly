package com.amperly.app.ui.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.entity.Notification;

import java.util.ArrayList;
import java.util.List;

/** Rows of the notification inbox: title, body, relative time and an unread dot. */
public class NotificationAdapter extends RecyclerView.Adapter<NotificationAdapter.RowViewHolder> {

    private final List<Notification> items = new ArrayList<>();

    public void submit(List<Notification> notifications) {
        items.clear();
        if (notifications != null) {
            items.addAll(notifications);
        }
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RowViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_notification, parent, false);
        return new RowViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RowViewHolder holder, int position) {
        holder.bind(items.get(position));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class RowViewHolder extends RecyclerView.ViewHolder {
        private final View unreadDot;
        private final TextView title;
        private final TextView message;
        private final TextView time;

        RowViewHolder(@NonNull View itemView) {
            super(itemView);
            unreadDot = itemView.findViewById(R.id.notificationUnreadDot);
            title = itemView.findViewById(R.id.notificationTitleText);
            message = itemView.findViewById(R.id.notificationMessageText);
            time = itemView.findViewById(R.id.notificationTimeText);
        }

        void bind(Notification notification) {
            title.setText(notification.getTitle());
            message.setText(notification.getMessage());
            time.setText(Formatters.agoFromNow(notification.getCreatedAtMs()));
            unreadDot.setVisibility(notification.isRead() ? View.INVISIBLE : View.VISIBLE);
        }
    }
}
