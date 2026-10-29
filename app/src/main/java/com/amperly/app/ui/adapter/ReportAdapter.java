package com.amperly.app.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.transition.TransitionManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.entity.Report;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Reports in the administrator's desk, one card each.
 *
 * <p>The names are resolved by the screen (a report only stores ids), so a card can show who
 * filed it and who it is about without a database read during bind. Every card carries exactly
 * three decisions: warn, suspend, or ban the reported account.
 *
 * <p>A card is closed until it is tapped: the summary is all a list of reports needs, and three
 * permanent buttons per row would bury it. Which card is open is remembered here rather than in
 * the view holders, so it survives scrolling and a re-bind, and only one card per list is open at
 * a time.
 */
public class ReportAdapter extends RecyclerView.Adapter<ReportAdapter.ReportViewHolder> {

    /** Long enough to read as a movement, short enough not to wait for it. */
    private static final long EXPAND_DURATION_MS = 180L;

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

    /** The reports whose cards are open. A list shows at most one. */
    private final Set<String> expandedIds = new LinkedHashSet<>();

    /** The list this adapter draws into, needed to animate a card opening. */
    @Nullable
    private RecyclerView recyclerView;

    public ReportAdapter(@Nullable Listener listener) {
        this.listener = listener;
    }

    @Override
    public void onAttachedToRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        this.recyclerView = recyclerView;
    }

    @Override
    public void onDetachedFromRecyclerView(@NonNull RecyclerView recyclerView) {
        super.onDetachedFromRecyclerView(recyclerView);
        if (this.recyclerView == recyclerView) {
            this.recyclerView = null;
        }
    }

    public void submit(@Nullable List<Item> reports) {
        items.clear();
        if (reports != null) {
            items.addAll(reports);
        }
        // A new set of rows follows an action on a card, and that action has already been
        // answered: nothing stays open over rows that have just changed underneath it.
        expandedIds.clear();
        notifyDataSetChanged();
    }

    /**
     * Opens this report's card, closing whichever one was open.
     *
     * <p>The list is asked to animate before the rows change, so the card grows while the one that
     * was open shrinks, instead of both jumping to their new size.
     */
    private void toggle(@NonNull String reportId) {
        boolean opening = !expandedIds.contains(reportId);
        expandedIds.clear();
        if (opening) {
            expandedIds.add(reportId);
        }
        if (recyclerView != null) {
            TransitionManager.beginDelayedTransition(recyclerView);
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
        private final ImageView chevron;
        private final View actions;
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
            chevron = itemView.findViewById(R.id.reportChevron);
            actions = itemView.findViewById(R.id.reportActionsContainer);
            warning = itemView.findViewById(R.id.reportWarningButton);
            suspend = itemView.findViewById(R.id.reportSuspendButton);
            ban = itemView.findViewById(R.id.reportBanButton);
        }

        void bind(Item item) {
            Report report = item.getReport();
            Context context = itemView.getContext();

            String reportedName = TextUtils.isEmpty(item.targetName)
                    ? context.getString(R.string.admin_report_no_target_short)
                    : item.targetName;
            String reporterName = TextUtils.isEmpty(item.reporterName)
                    ? report.getReporterId() : item.reporterName;
            String statusLabel = report.getStatus() == null ? "" : report.getStatus();

            type.setText(report.getReportType());
            status.setText(statusLabel);
            reporter.setText(context.getString(R.string.admin_report_reporter, reporterName));
            target.setText(context.getString(R.string.admin_report_target, reportedName));
            description.setText(report.getDescription());
            date.setText(context.getString(R.string.admin_report_date,
                    Formatters.dateTime(report.getCreatedAtMs())));

            boolean open = expandedIds.contains(report.getId());
            actions.setVisibility(open ? View.VISIBLE : View.GONE);
            chevron.animate().rotation(open ? 180f : 0f).setDuration(EXPAND_DURATION_MS).start();
            itemView.setOnClickListener(v -> toggle(report.getId()));
            // While the card is closed it reads as one item: the summary and what tapping does.
            // Once it is open its own text and its three buttons are what a screen reader should
            // reach, so the summary steps aside rather than swallowing them.
            itemView.setContentDescription(open ? null : context.getString(
                    R.string.admin_report_card_description,
                    report.getReportType(), statusLabel, reporterName, reportedName,
                    context.getString(R.string.admin_report_show_actions)));

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
            boolean openReport = report.getStatus() == null
                    || "OPEN".equalsIgnoreCase(report.getStatus());
            warning.setEnabled(openReport);
            suspend.setEnabled(openReport);
            ban.setEnabled(openReport);
        }
    }
}
