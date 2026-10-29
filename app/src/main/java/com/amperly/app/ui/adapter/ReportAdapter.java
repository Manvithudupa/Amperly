package com.amperly.app.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.entity.Report;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.List;

/**
 * Reports in the administrator's desk, one card each.
 *
 * <p>The names are resolved by the screen (a report only stores ids), so a card can show who
 * filed it and who it is about without a database read during bind. Every card carries exactly
 * three decisions: warn, suspend, or ban the reported account.
 */
public class ReportAdapter extends RecyclerView.Adapter<ReportAdapter.ReportViewHolder> {

    public interface Listener {
        void onWarning(Report report);

        void onSuspend(Report report);

        void onBan(Report report);
    }

    /** A report with the two display names the screen looked up for it. */
    public static class Item {
        private final Report report;
        private final String reporterName;
        private final String targetName;

        public Item(@NonNull Report report, @Nullable String reporterName, @Nullable String targetName) {
            this.report = report;
            this.reporterName = reporterName;
            this.targetName = targetName;
        }

        @NonNull
        public Report getReport() {
            return report;
        }
    }

    private final List<Item> items = new ArrayList<>();
    private final Listener listener;

    public ReportAdapter(@Nullable Listener listener) {
        this.listener = listener;
    }

    public void submit(@Nullable List<Item> reports) {
        items.clear();
        if (reports != null) {
            items.addAll(reports);
        }
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ReportViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_report, parent, false);
        return new ReportViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ReportViewHolder holder, int position) {
        holder.bind(items.get(position));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    class ReportViewHolder extends RecyclerView.ViewHolder {
        private final TextView type;
        private final TextView status;
        private final TextView reporter;
        private final TextView target;
        private final TextView description;
        private final TextView date;
        private final MaterialButton warning;
        private final MaterialButton suspend;
        private final MaterialButton ban;

        ReportViewHolder(@NonNull View itemView) {
            super(itemView);
            type = itemView.findViewById(R.id.reportTypeText);
            status = itemView.findViewById(R.id.reportStatusBadge);
            reporter = itemView.findViewById(R.id.reportReporterText);
            target = itemView.findViewById(R.id.reportTargetText);
            description = itemView.findViewById(R.id.reportDescriptionText);
            date = itemView.findViewById(R.id.reportDateText);
            warning = itemView.findViewById(R.id.reportWarningButton);
            suspend = itemView.findViewById(R.id.reportSuspendButton);
            ban = itemView.findViewById(R.id.reportBanButton);
        }

        void bind(Item item) {
            Report report = item.getReport();
            Context context = itemView.getContext();

            type.setText(report.getReportType());
            status.setText(report.getStatus());
            reporter.setText(context.getString(R.string.admin_report_reporter,
                    TextUtils.isEmpty(item.reporterName)
                            ? report.getReporterId() : item.reporterName));
            target.setText(context.getString(R.string.admin_report_target,
                    TextUtils.isEmpty(item.targetName)
                            ? context.getString(R.string.admin_report_no_target_short)
                            : item.targetName));
            description.setText(report.getDescription());
            date.setText(context.getString(R.string.admin_report_date,
                    Formatters.dateTime(report.getCreatedAtMs())));

            warning.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onWarning(report);
                }
            });
            suspend.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onSuspend(report);
                }
            });
            ban.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onBan(report);
                }
            });

            // A closed report keeps its history but cannot be acted on twice.
            boolean open = report.getStatus() == null || "OPEN".equalsIgnoreCase(report.getStatus());
            warning.setEnabled(open);
            suspend.setEnabled(open);
            ban.setEnabled(open);
        }
    }
}
