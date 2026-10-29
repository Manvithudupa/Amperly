package com.amperly.app.feature.admin;

import android.os.Bundle;
import android.text.TextUtils;
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
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.security.RoleGuard;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.Dispute;
import com.amperly.app.data.local.entity.HostEnforcementAction;
import com.amperly.app.data.local.entity.Invoice;
import com.amperly.app.data.local.entity.MeterReading;
import com.amperly.app.data.local.entity.Notification;
import com.amperly.app.data.local.entity.Report;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.admin.EnforcementPolicyEngine;
import com.amperly.app.engine.analytics.HostAnalyticsEngine;
import com.amperly.app.engine.billing.BillingEngine;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.adapter.DisputeAdapter;
import com.amperly.app.ui.adapter.PendingStationAdapter;
import com.amperly.app.ui.adapter.ReportAdapter;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * Administrator desk: verify listings, review meter evidence, resolve disputes with refunds and apply
 * the evidence-based enforcement ladder (warning → fine → suspension → ban).
 */
public class AdminDashboardFragment extends Fragment {

    /** Which queue the bottom navigation opened. */
    public static final String ARG_SECTION = "section";
    public static final String SECTION_QUEUE = "queue";
    public static final String SECTION_REPORTS = "reports";

    private AmperlyRepository repo;
    private PendingStationAdapter pendingAdapter;
    private DisputeAdapter disputeAdapter;
    /** The two report lists share one listener: the same three decisions, two audiences. */
    private ReportAdapter consumerReportAdapter;
    private ReportAdapter hostReportAdapter;
    private TextView analyticsText;

    /** The section this desk was opened on; the queue when no section was asked for. */
    @NonNull
    private String section = SECTION_QUEUE;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_admin_dashboard, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());
        analyticsText = view.findViewById(R.id.platformAnalyticsText);

        RecyclerView pending = view.findViewById(R.id.pendingStationsRecyclerView);
        pending.setLayoutManager(new LinearLayoutManager(requireContext()));
        pending.setNestedScrollingEnabled(false);
        pendingAdapter = new PendingStationAdapter(new PendingStationAdapter.Listener() {
            @Override
            public void onApprove(ChargerStation station) {
                decideStation(station, true);
            }

            @Override
            public void onReject(ChargerStation station) {
                decideStation(station, false);
            }
        });
        pending.setAdapter(pendingAdapter);

        RecyclerView disputes = view.findViewById(R.id.disputesRecyclerView);
        disputes.setLayoutManager(new LinearLayoutManager(requireContext()));
        disputes.setNestedScrollingEnabled(false);
        disputeAdapter = new DisputeAdapter(new DisputeAdapter.Listener() {
            @Override
            public void onRefund(Dispute dispute) {
                resolveWithRefund(dispute);
            }

            @Override
            public void onFreezePayout(Dispute dispute) {
                if (!canActAsAdmin()) {
                    return;
                }
                dispute.setPayoutFrozen(true);
                repo.freezeDisputePayoutOnServer(dispute);
                Ux.info(AdminDashboardFragment.this, getString(R.string.admin_payout_held));
                load();
            }

            @Override
            public void onWarning(Dispute dispute) {
                confirmEnforcement(dispute, AppConstants.ENFORCEMENT_WARNING, 0.0);
            }

            @Override
            public void onFine(Dispute dispute) {
                confirmEnforcement(dispute, AppConstants.ENFORCEMENT_FINE,
                        EnforcementPolicyEngine.DEFAULT_FINE_INR);
            }

            @Override
            public void onSuspend(Dispute dispute) {
                confirmEnforcement(dispute, AppConstants.ENFORCEMENT_SUSPENSION, 0.0);
            }

            @Override
            public void onBan(Dispute dispute) {
                confirmEnforcement(dispute, AppConstants.ENFORCEMENT_BAN, 0.0);
            }
        });
        disputes.setAdapter(disputeAdapter);

        ReportAdapter.Listener reportActions = new ReportAdapter.Listener() {
            @Override
            public void onWarning(Report report) {
                applyReportAction(report, AppConstants.ENFORCEMENT_WARNING, 0L);
            }

            @Override
            public void onSuspend(Report report) {
                chooseSuspension(report);
            }

            @Override
            public void onBan(Report report) {
                confirmReportBan(report);
            }
        };
        consumerReportAdapter = new ReportAdapter(reportActions);
        hostReportAdapter = new ReportAdapter(reportActions);
        RecyclerView consumerReports = view.findViewById(R.id.consumerReportsRecyclerView);
        consumerReports.setLayoutManager(new LinearLayoutManager(requireContext()));
        consumerReports.setNestedScrollingEnabled(false);
        consumerReports.setAdapter(consumerReportAdapter);
        RecyclerView hostReports = view.findViewById(R.id.hostReportsRecyclerView);
        hostReports.setLayoutManager(new LinearLayoutManager(requireContext()));
        hostReports.setNestedScrollingEnabled(false);
        hostReports.setAdapter(hostReportAdapter);

        // Each bottom-navigation destination is one section of the desk, so the section that was
        // not opened is not drawn at all instead of sitting further down a shared scroll.
        String requested = getArguments() == null ? null : getArguments().getString(ARG_SECTION);
        section = requested == null ? SECTION_QUEUE : requested;
        applySection(section);

        load();
    }

    /** True when this desk was opened on the approval queue. */
    private boolean isQueueSection() {
        return !SECTION_REPORTS.equals(section);
    }

    /**
     * Shows only the section this desk was opened on.
     *
     * <p>Queue is the approval work; Reports is the disputes and the reports users filed. The
     * other section is hidden with its headings and its empty state, and the list on show keeps
     * whichever of the list or the empty line {@link #load()} decided for it.
     */
    private void applySection(@NonNull String section) {
        boolean queue = !SECTION_REPORTS.equals(section);
        show(R.id.adminQueueSection, queue);
        show(R.id.adminReportsSection, !queue);
        show(R.id.adminConsumerReportsHeading, !queue);
        show(R.id.adminHostReportsHeading, !queue);
        show(R.id.adminDisputesSection, !queue);
        if (queue) {
            // The reports and disputes belong to the other tab, so their lists start hidden and
            // only that tab's own load brings them back.
            show(R.id.consumerReportsRecyclerView, false);
            show(R.id.adminConsumerReportsEmptyText, false);
            show(R.id.hostReportsRecyclerView, false);
            show(R.id.adminHostReportsEmptyText, false);
            show(R.id.disputesRecyclerView, false);
            show(R.id.adminDisputesEmptyText, false);
        } else {
            show(R.id.pendingStationsRecyclerView, false);
            show(R.id.adminQueueEmptyText, false);
        }
    }

    /** Shows or hides one view of the page, tolerating a view the page has already dropped. */
    private void show(int viewId, boolean visible) {
        View root = getView();
        View view = root == null ? null : root.findViewById(viewId);
        if (view != null) {
            view.setVisibility(visible ? View.VISIBLE : View.GONE);
        }
    }

    private void load() {
        repo.background(() -> {
            List<ChargerStation> pendingStations = repo.getPendingStationsSync();
            List<Dispute> disputes = repo.getDisputesSync();
            List<Report> reports = repo.getAllReportsSync();
            HostAnalyticsEngine.HostAnalytics analytics = repo.platformAnalytics();
            List<DisputeAdapter.DisputeRow> disputeRows = new ArrayList<>();
            for (Dispute dispute : disputes) {
                List<MeterReading> evidence = dispute.getSessionId() == null
                        ? new ArrayList<>()
                        : repo.getMeterReadingsSync(dispute.getSessionId());
                disputeRows.add(new DisputeAdapter.DisputeRow(dispute, evidence));
            }
            // The names on the card come from the entities the report only references by id, and
            // which list a report belongs in is decided here rather than in bind: both need reads,
            // and this is the thread allowed to make them.
            List<ReportAdapter.Item> consumerReports = new ArrayList<>();
            List<ReportAdapter.Item> hostReports = new ArrayList<>();
            for (Report report : reports) {
                ReportAdapter.Item row = new ReportAdapter.Item(report,
                        reporterName(report), reportedName(report));
                if (isHostReport(report)) {
                    hostReports.add(row);
                } else {
                    consumerReports.add(row);
                }
            }
            return new AdminData(pendingStations, disputeRows, consumerReports, hostReports,
                    analytics);
        }, data -> {
            if (data == null || !isAdded()) {
                return;
            }
            pendingAdapter.submit(data.pending);
            disputeAdapter.submit(data.disputes);
            consumerReportAdapter.submit(data.consumerReports);
            hostReportAdapter.submit(data.hostReports);
            // An empty section says so instead of looking like a screen that failed to load. Only
            // the section on show is filled in: the other tab's lists stay hidden with it.
            boolean queue = isQueueSection();
            show(R.id.pendingStationsRecyclerView, queue && !data.pending.isEmpty());
            show(R.id.adminQueueEmptyText, queue && data.pending.isEmpty());
            show(R.id.consumerReportsRecyclerView, !queue && !data.consumerReports.isEmpty());
            show(R.id.adminConsumerReportsEmptyText, !queue && data.consumerReports.isEmpty());
            show(R.id.hostReportsRecyclerView, !queue && !data.hostReports.isEmpty());
            show(R.id.adminHostReportsEmptyText, !queue && data.hostReports.isEmpty());
            show(R.id.disputesRecyclerView, !queue && !data.disputes.isEmpty());
            show(R.id.adminDisputesEmptyText, !queue && data.disputes.isEmpty());
            analyticsText.setText(getString(R.string.admin_platform_summary,
                    data.pending.size(), data.disputes.size(),
                    data.consumerReports.size() + data.hostReports.size(),
                    data.analytics.getSessionsCompleted(),
                    String.format(Locale.US, "%.1f kWh", data.analytics.getEnergyDeliveredKwh()),
                    Formatters.money(data.analytics.getRevenue()),
                    Formatters.money(data.analytics.getRefundsAndAdjustments()),
                    String.format(Locale.US, "%.0f%%", data.analytics.getUtilizationPercent())));
        });
    }

    /** The admin desk is platform operations; RLS is the real gate, this fails early. */
    private boolean canActAsAdmin() {
        if (!RoleGuard.canPerformAdminAction(AuthManager.getInstance().getCurrentUser())) {
            Ux.error(this, getString(R.string.error_not_allowed));
            return false;
        }
        return true;
    }

    private void decideStation(ChargerStation station, boolean approve) {
        if (!canActAsAdmin()) {
            return;
        }
        repo.background(() -> {
            station.setApprovalStatus(approve ? AppConstants.APPROVAL_APPROVED
                    : AppConstants.APPROVAL_REJECTED);
            station.setVerified(approve && station.supportsPaidEnergyBilling());
            station.setReviewNote(approve
                    ? "Approved: " + Formatters.verificationLevel(station.getVerificationLevel())
                    + " confirmed by an administrator."
                    : "Rejected: documentation did not match the submitted details.");
            station.setLastUpdatedMs(System.currentTimeMillis());
            // The server makes the approval decision and notifies the host; the local
            // row above is the immediate view.
            repo.decideStationApprovalOnServer(station, approve);
            return station.getName();
        }, name -> {
            if (name != null) {
                Ux.success(this, getString(approve
                        ? R.string.admin_approved : R.string.admin_declined, name));
                load();
            }
        });
    }

    /**
     * Refunds are irreversible, so the button asks before it moves money.
     *
     * <p>The refund is computed from the invoice server-side; this dialog only decides whether
     * to start it, and names the consequence in the same terms the result will use.
     */
    private void resolveWithRefund(Dispute dispute) {
        if (!canActAsAdmin()) {
            return;
        }
        new com.google.android.material.dialog.MaterialAlertDialogBuilder(requireContext())
                .setTitle(R.string.admin_confirm_refund_title)
                .setMessage(R.string.admin_confirm_refund_body)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.admin_refund,
                        (dialog, which) -> performRefund(dispute))
                .show();
    }

    private void performRefund(Dispute dispute) {
        repo.background(() -> {
            Invoice invoice = dispute.getSessionId() == null ? null
                    : repo.getInvoiceBySessionSync(dispute.getSessionId());
            double refundAmount = invoice == null ? 0 : invoice.getEnergyCharge();
            if (invoice != null && refundAmount > 0) {
                BillingEngine.applyRefund(invoice, refundAmount,
                        "Refunded after reviewing the meter evidence for dispute " + dispute.getId());
            }
            dispute.setStatus("RESOLVED_CONSUMER");
            dispute.setRefundAmount(refundAmount);
            dispute.setPayoutFrozen(true);
            dispute.setResolvedAtMs(System.currentTimeMillis());
            dispute.setResolutionNote("Consumer refunded " + Formatters.money(refundAmount)
                    + " based on the uploaded meter evidence.");
            // The server recomputes the refund from the invoice, applies it to the payment
            // and notifies the consumer; the rows above are the immediate view.
            repo.resolveDisputeRefundOnServer(dispute, invoice);
            return refundAmount;
        }, amount -> {
            if (amount != null) {
                Ux.success(this, getString(R.string.admin_refunded, Formatters.money(amount)));
                load();
            }
        });
    }

    /**
     * Enforcement changes the host's standing and can pause a live station, so each action is
     * confirmed first. The dialog names the action and its immediate effect; the policy ladder
     * is still attached to the recorded note by {@link #applyEnforcement}.
     */
    private void confirmEnforcement(Dispute dispute, String action, double fineAmount) {
        if (!canActAsAdmin()) {
            return;
        }
        int title;
        String message;
        int positive;
        if (AppConstants.ENFORCEMENT_WARNING.equals(action)) {
            title = R.string.admin_confirm_warning_title;
            message = getString(R.string.admin_confirm_warning_body);
            positive = R.string.admin_warning;
        } else if (AppConstants.ENFORCEMENT_FINE.equals(action)) {
            title = R.string.admin_confirm_fine_title;
            message = getString(R.string.admin_confirm_fine_body, Formatters.money(fineAmount));
            positive = R.string.admin_fine;
        } else if (AppConstants.ENFORCEMENT_SUSPENSION.equals(action)) {
            title = R.string.admin_confirm_suspend_title;
            message = getString(R.string.admin_confirm_suspend_body);
            positive = R.string.admin_suspend;
        } else {
            title = R.string.admin_confirm_ban_title;
            message = getString(R.string.admin_confirm_ban_body);
            positive = R.string.admin_ban;
        }
        new com.google.android.material.dialog.MaterialAlertDialogBuilder(requireContext())
                .setTitle(title)
                .setMessage(message)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(positive,
                        (dialog, which) -> applyEnforcement(dispute, action, fineAmount))
                .show();
    }

    private void applyEnforcement(Dispute dispute, String action, double fineAmount) {
        if (!canActAsAdmin()) {
            return;
        }
        repo.background(() -> {
            int proven = repo.countProvenIncidents(dispute.getHostId()) + 1;
            boolean severe = AppConstants.ENFORCEMENT_BAN.equals(action);
            EnforcementPolicyEngine.EnforcementDecision decision =
                    EnforcementPolicyEngine.decide(proven, true, severe);

            // An explicit admin choice is recorded as given, with the policy ladder attached.
            dispute.setEnforcementAction(action);
            dispute.setStatus("RESOLVED_HOST");
            dispute.setResolvedAtMs(System.currentTimeMillis());
            dispute.setResolutionNote("Enforcement: " + action
                    + (fineAmount > 0 ? " · fine " + Formatters.money(fineAmount) : "")
                    + "\nPolicy step: " + decision.getReason() + " → " + decision.getAction());
            // The server records the dispute outcome, files the enforcement row, pauses the
            // station when the policy calls for it, and notifies the host.
            repo.applyHostEnforcementOnServer(dispute, action, fineAmount,
                    dispute.getResolutionNote());

            if (decision.isSuspendStation() || AppConstants.ENFORCEMENT_SUSPENSION.equals(action)
                    || AppConstants.ENFORCEMENT_BAN.equals(action)) {
                ChargerStation station = repo.getStationSync(dispute.getStationId());
                if (station != null) {
                    station.setPaused(true);
                    station.setIncidentCount(station.getIncidentCount() + 1);
                    station.setReliabilityScore(Math.max(0, station.getReliabilityScore() - 10));
                    // Local only: the function already applied this server-side, and pushing
                    // it as well would count the incident twice.
                    repo.updateStationLocally(station);
                }
            }

            return action;
        }, applied -> {
            if (applied != null) {
                Ux.success(this, getString(R.string.admin_enforcement_recorded, applied));
                load();
            }
        });
    }

    // ------------------------------------------------------------- reports

    /**
     * True when a report belongs under "Reports from hosts".
     *
     * <p>A report is filed by the side of the incident the reporter was on, so the session it
     * names is what decides: the account that owns the session is its host, and the reporter is
     * either that host or the driver. A report with no session names the host or the station it
     * is about when a driver filed it, which is what a consumer's report does. Anything left is
     * settled by the reporter's own standing, and a customer is the default because that is who
     * most reports come from.
     *
     * <p>Reads the database, so it runs on the loading thread with the rows it classifies.
     */
    private boolean isHostReport(@NonNull Report report) {
        String reporterId = report.getReporterId();
        String sessionId = report.getSessionId();
        if (!TextUtils.isEmpty(sessionId)) {
            ChargingSession session = repo.getSessionSync(sessionId);
            if (session != null) {
                return reporterId != null && reporterId.equals(session.getHostId());
            }
        }
        if (!TextUtils.isEmpty(report.getTargetHostId())
                || !TextUtils.isEmpty(report.getTargetStationId())) {
            // Naming a host or a station is what a driver's report does.
            return false;
        }
        User reporter = TextUtils.isEmpty(reporterId) ? null : repo.getUserSync(reporterId);
        return reporter != null && AppConstants.ROLE_HOST.equalsIgnoreCase(reporter.getRole());
    }

    /** The display name of the person who filed the report. */
    @Nullable
    private String reporterName(Report report) {
        if (report.getReporterName() != null && !report.getReporterName().trim().isEmpty()) {
            return report.getReporterName();
        }
        return displayName(report.getReporterId());
    }

    /** The account the report is about, or the station when no account can be resolved. */
    @Nullable
    private String reportedName(Report report) {
        String name = displayName(repo.reportTargetUserIdSync(report));
        if (name != null) {
            return name;
        }
        if (report.getTargetStationId() != null) {
            ChargerStation station = repo.getStationSync(report.getTargetStationId());
            if (station != null) {
                return station.getName();
            }
        }
        return null;
    }

    @Nullable
    private String displayName(@Nullable String userId) {
        if (userId == null) {
            return null;
        }
        User user = repo.getUserSync(userId);
        return user == null ? null : user.getName();
    }

    /**
     * Asks how long a suspension should last, with the length this account's history suggests
     * already selected. The administrator can always pick another of the three.
     */
    private void chooseSuspension(Report report) {
        if (!canActAsAdmin()) {
            return;
        }
        repo.background(() -> repo.countEnforcementForUserSync(repo.reportTargetUserIdSync(report)),
                (Integer prior) -> {
                    if (!isAdded()) {
                        return;
                    }
                    int incidents = (prior == null ? 0 : prior) + 1;
                    int suggested = EnforcementPolicyEngine.suggestedSuspensionDays(incidents);
                    final String[] options = new String[EnforcementPolicyEngine.SUSPENSION_DAYS.length];
                    int checked = 0;
                    for (int i = 0; i < options.length; i++) {
                        options[i] = suspensionLabel(EnforcementPolicyEngine.SUSPENSION_DAYS[i]);
                        if (EnforcementPolicyEngine.SUSPENSION_DAYS[i] == suggested) {
                            checked = i;
                        }
                    }
                    final int[] choice = {checked};
                    new com.google.android.material.dialog.MaterialAlertDialogBuilder(requireContext())
                            .setTitle(R.string.admin_suspend_account_title)
                            .setMessage(getString(R.string.admin_suspend_account_body) + "\n\n"
                                    + getString(R.string.admin_suspend_suggested, options[checked]))
                            .setSingleChoiceItems(options, checked,
                                    (dialog, which) -> choice[0] = which)
                            .setNegativeButton(R.string.action_cancel, null)
                            .setPositiveButton(R.string.admin_report_action_suspend,
                                    (dialog, which) -> applyReportAction(report,
                                            AppConstants.ENFORCEMENT_SUSPENSION,
                                            EnforcementPolicyEngine.SUSPENSION_DAYS[choice[0]]
                                                    * EnforcementPolicyEngine.DAY_MS))
                            .show();
                });
    }

    private String suspensionLabel(int days) {
        if (days == 1) {
            return getString(R.string.admin_suspend_option_1d);
        }
        if (days == 7) {
            return getString(R.string.admin_suspend_option_7d);
        }
        return getString(R.string.admin_suspend_option_30d);
    }

    /** A ban is permanent, so it is the one action that always asks first. */
    private void confirmReportBan(Report report) {
        if (!canActAsAdmin()) {
            return;
        }
        new com.google.android.material.dialog.MaterialAlertDialogBuilder(requireContext())
                .setTitle(R.string.admin_confirm_account_ban_title)
                .setMessage(R.string.admin_confirm_account_ban_body)
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.admin_report_action_ban,
                        (dialog, which) -> applyReportAction(report,
                                AppConstants.ENFORCEMENT_BAN, 0L))
                .show();
    }

    /**
     * Records one decision against the reported account, notifies them and closes the report.
     *
     * <p>A thrown write becomes a message rather than a silent success: {@code background} reports
     * null both for "done" and for "threw", and this action must not claim it recorded anything
     * it did not.
     */
    private void applyReportAction(Report report, String action, long expiresAtMs) {
        if (!canActAsAdmin()) {
            return;
        }
        repo.background(() -> {
            try {
                return repo.applyReportAction(report, action, expiresAtMs);
            } catch (RuntimeException e) {
                return getString(R.string.admin_report_action_failed);
            }
        }, (String error) -> {
            if (!isAdded()) {
                return;
            }
            if (error != null) {
                Ux.error(this, error);
                return;
            }
            Ux.success(this, getString(R.string.admin_action_recorded, actionLabel(action)));
            load();
        });
    }

    private String actionLabel(String action) {
        if (AppConstants.ENFORCEMENT_SUSPENSION.equals(action)) {
            return getString(R.string.admin_report_action_suspend);
        }
        if (AppConstants.ENFORCEMENT_BAN.equals(action)) {
            return getString(R.string.admin_report_action_ban);
        }
        return getString(R.string.admin_report_action_warning);
    }

    private static class AdminData {
        private final List<ChargerStation> pending;
        private final List<DisputeAdapter.DisputeRow> disputes;
        private final List<ReportAdapter.Item> consumerReports;
        private final List<ReportAdapter.Item> hostReports;
        private final HostAnalyticsEngine.HostAnalytics analytics;

        AdminData(List<ChargerStation> pending, List<DisputeAdapter.DisputeRow> disputes,
                  List<ReportAdapter.Item> consumerReports,
                  List<ReportAdapter.Item> hostReports,
                  HostAnalyticsEngine.HostAnalytics analytics) {
            this.pending = pending;
            this.disputes = disputes;
            this.consumerReports = consumerReports;
            this.hostReports = hostReports;
            this.analytics = analytics;
        }
    }
}
