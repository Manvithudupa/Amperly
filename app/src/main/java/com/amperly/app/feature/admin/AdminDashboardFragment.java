package com.amperly.app.feature.admin;

import android.os.Bundle;
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
import com.amperly.app.data.local.entity.Dispute;
import com.amperly.app.data.local.entity.HostEnforcementAction;
import com.amperly.app.data.local.entity.Invoice;
import com.amperly.app.data.local.entity.MeterReading;
import com.amperly.app.data.local.entity.Notification;
import com.amperly.app.data.local.entity.Report;
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
    public static final String SECTION_DISPUTES = "disputes";
    public static final String SECTION_REPORTS = "reports";

    private AmperlyRepository repo;
    private PendingStationAdapter pendingAdapter;
    private DisputeAdapter disputeAdapter;
    private ReportAdapter reportAdapter;
    private TextView analyticsText;

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

        RecyclerView reports = view.findViewById(R.id.reportsRecyclerView);
        reports.setLayoutManager(new LinearLayoutManager(requireContext()));
        reports.setNestedScrollingEnabled(false);
        reportAdapter = new ReportAdapter();
        reports.setAdapter(reportAdapter);

        load();

        // The three bottom-navigation destinations are one desk; each opens at its own queue.
        String section = getArguments() == null ? null : getArguments().getString(ARG_SECTION);
        if (section != null) {
            view.postDelayed(() -> scrollToSection(section), 250);
        }
    }

    private void scrollToSection(String section) {
        View root = getView();
        if (root == null) {
            return;
        }
        int targetId = SECTION_DISPUTES.equals(section) ? R.id.adminDisputesSection
                : SECTION_REPORTS.equals(section) ? R.id.adminReportsSection
                : R.id.adminQueueSection;
        View scroll = root.findViewById(R.id.adminScrollView);
        View target = root.findViewById(targetId);
        if (scroll instanceof android.widget.ScrollView && target != null) {
            ((android.widget.ScrollView) scroll).smoothScrollTo(0, target.getTop());
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
            return new AdminData(pendingStations, disputeRows, reports, analytics,
                    repo.getInvoicesForHostSync(""));
        }, data -> {
            if (data == null || !isAdded()) {
                return;
            }
            pendingAdapter.submit(data.pending);
            disputeAdapter.submit(data.disputes);
            reportAdapter.submit(data.reports);
            // An empty section says so instead of looking like a screen that failed to load.
            View root = getView();
            if (root != null) {
                root.findViewById(R.id.adminQueueEmptyText).setVisibility(
                        data.pending.isEmpty() ? View.VISIBLE : View.GONE);
                root.findViewById(R.id.adminDisputesEmptyText).setVisibility(
                        data.disputes.isEmpty() ? View.VISIBLE : View.GONE);
                root.findViewById(R.id.adminReportsEmptyText).setVisibility(
                        data.reports.isEmpty() ? View.VISIBLE : View.GONE);
            }
            analyticsText.setText(getString(R.string.admin_platform_summary,
                    data.pending.size(), data.disputes.size(), data.reports.size(),
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
                        ? R.string.admin_approved : R.string.admin_rejected, name));
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

    private static class AdminData {
        private final List<ChargerStation> pending;
        private final List<DisputeAdapter.DisputeRow> disputes;
        private final List<Report> reports;
        private final HostAnalyticsEngine.HostAnalytics analytics;
        private final List<Invoice> invoices;

        AdminData(List<ChargerStation> pending, List<DisputeAdapter.DisputeRow> disputes,
                  List<Report> reports, HostAnalyticsEngine.HostAnalytics analytics,
                  List<Invoice> invoices) {
            this.pending = pending;
            this.disputes = disputes;
            this.reports = reports;
            this.analytics = analytics;
            this.invoices = invoices;
        }
    }
}
