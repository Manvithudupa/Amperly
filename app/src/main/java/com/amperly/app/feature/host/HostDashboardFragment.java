package com.amperly.app.feature.host;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
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
import com.amperly.app.core.security.RoleGuard;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.analytics.HostAnalyticsEngine;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.adapter.SessionAdapter;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;

import java.util.List;

/**
 * The host's dashboard: what the chargers have earned and how they are used, then the sessions
 * those numbers come from.
 *
 * <p>Bookings have their own tab ({@link HostBookingsFragment}) and the chargers themselves live
 * on the Stations tab ({@link HostStationsFragment}); this page is the numbers. The station delete
 * lives at the bottom, apart from the daily controls, because it cannot be undone. Hosts never see
 * consumer personal data beyond the reservation.
 */
public class HostDashboardFragment extends Fragment {

    private AmperlyRepository repo;
    private LinearLayout analyticsContainer;
    private TextView emptyText;
    private String hostId;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_host_dashboard, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());
        hostId = AuthManager.getInstance().getCurrentUserId();

        analyticsContainer = view.findViewById(R.id.analyticsContainer);
        emptyText = view.findViewById(R.id.hostEmptyText);

        ((TextView) view.findViewById(R.id.hostNameText)).setText(
                getString(R.string.host_greeting_subtitle,
                        AuthManager.getInstance().getCurrentUser().getName()));

        RecyclerView sessions = view.findViewById(R.id.sessionsRecyclerView);
        sessions.setLayoutManager(new LinearLayoutManager(requireContext()));
        sessions.setNestedScrollingEnabled(false);

        final SessionAdapter sessionAdapter = new SessionAdapter(new SessionAdapter.Listener() {
            @Override
            public void onViewReceipt(ChargingSession session) {
                Ux.info(HostDashboardFragment.this, getString(R.string.host_receipt_toast,
                        session.getStationName(), Formatters.money(session.getTotalPaid()),
                        Formatters.kwh(session.getVerifiedKwhConsumed())));
            }

            @Override
            public void onReportSession(ChargingSession session) {
                Ux.info(HostDashboardFragment.this, getString(R.string.host_session_dispute_note));
            }
        });
        sessions.setAdapter(sessionAdapter);

        view.findViewById(R.id.deleteStationButton).setOnClickListener(v -> chooseStationToDelete());

        load(sessionAdapter);
    }

    private void load(SessionAdapter sessionAdapter) {
        repo.background(() -> {
            List<ChargerStation> stations = repo.getStationsForHostSync(hostId);
            List<ChargingSession> sessions = repo.getSessionsForHostSync(hostId);
            HostAnalyticsEngine.HostAnalytics analytics = repo.hostAnalytics(hostId);
            return new HostData(stations, sessions, analytics);
        }, (HostData data) -> {
            if (data == null || !isAdded()) {
                return;
            }
            bindStats(data.analytics);
            emptyText.setVisibility(data.stations.isEmpty() ? View.VISIBLE : View.GONE);
            sessionAdapter.submit(data.sessions);
            bindAnalytics(data.analytics);
        });
    }

    /** Total income, dispute count and reservation count, the three numbers a host acts on. */
    private void bindStats(HostAnalyticsEngine.HostAnalytics analytics) {
        View view = getView();
        if (view == null) {
            return;
        }
        ((TextView) view.findViewById(R.id.statsIncomeText)).setText(
                Formatters.moneyShort(analytics.getRevenue()));
        ((TextView) view.findViewById(R.id.statsDisputesText)).setText(
                String.valueOf(analytics.getDisputes()));
        ((TextView) view.findViewById(R.id.statsReservationsText)).setText(
                String.valueOf(analytics.getReservations()));
        // A bare "0%" under three labelled numbers reads as a broken value; say what it measures.
        ((TextView) view.findViewById(R.id.statsUtilizationText)).setText(
                getString(R.string.analytics_utilization_short,
                        Formatters.percent(analytics.getUtilizationPercent())));
    }

    private void bindAnalytics(HostAnalyticsEngine.HostAnalytics analytics) {
        analyticsContainer.removeAllViews();
        addRow(getString(R.string.analytics_sessions_short),
                String.valueOf(analytics.getSessionsCompleted()));
        addRow(getString(R.string.analytics_energy_short),
                Formatters.kwh(analytics.getEnergyDeliveredKwh()));
        addRow(getString(R.string.host_analytics_repeat), String.valueOf(analytics.getRepeatConsumers()));
        addRow(getString(R.string.host_analytics_cancellation),
                Formatters.percent(analytics.getCancellationRatePercent()));
        addRow(getString(R.string.host_analytics_utilisation),
                Formatters.percent(analytics.getUtilizationPercent()));
        addRow(getString(R.string.host_analytics_average_session),
                Formatters.kwh(analytics.getAverageSessionKwh()));
        addRow(getString(R.string.host_analytics_disputes),
                getString(R.string.host_analytics_disputes_value, analytics.getDisputes(),
                        analytics.getOpenDisputes()));
        addRow(getString(R.string.host_analytics_refunds),
                Formatters.money(analytics.getRefundsAndAdjustments()));
        addRow(getString(R.string.host_analytics_active_reservations),
                String.valueOf(analytics.getActiveReservations()));
        addRow(getString(R.string.host_analytics_ports), String.valueOf(analytics.getPorts()));
        ((TextView) requireView().findViewById(R.id.analyticsNoteText)).setText(analytics.getUtilizationNote());
    }

    private void addRow(String label, String value) {
        View row = LayoutInflater.from(requireContext()).inflate(R.layout.item_billing_line, analyticsContainer, false);
        ((TextView) row.findViewById(R.id.lineLabelText)).setText(label);
        ((TextView) row.findViewById(R.id.lineValueText)).setText(value);
        analyticsContainer.addView(row);
    }

    /** Deleting is host-owned; RLS is the real gate, this fails early with a message. */
    private boolean canManage(ChargerStation station) {
        User user = AuthManager.getInstance().getCurrentUser();
        if (station == null || !RoleGuard.canManageStation(user, station.getHostId())) {
            Ux.error(this, getString(R.string.error_not_allowed));
            return false;
        }
        return true;
    }

    /** Lists the host's stations first; only a chosen station can be confirmed. */
    private void chooseStationToDelete() {
        repo.background(() -> repo.getStationsForHostSync(hostId), (List<ChargerStation> stations) -> {
            if (!isAdded()) {
                return;
            }
            if (stations == null || stations.isEmpty()) {
                Ux.info(this, getString(R.string.host_delete_station_none));
                return;
            }
            String[] labels = new String[stations.size()];
            for (int i = 0; i < stations.size(); i++) {
                ChargerStation station = stations.get(i);
                labels[i] = station.getAddress() == null || station.getAddress().trim().isEmpty()
                        ? station.getName()
                        : getString(R.string.host_station_picker, station.getName(), station.getAddress());
            }
            new MaterialAlertDialogBuilder(requireContext())
                    .setTitle(R.string.host_delete_station_title)
                    .setItems(labels, (dialog, which) -> confirmDelete(stations.get(which)))
                    .setNegativeButton(R.string.action_cancel, null)
                    .show();
        });
    }

    private void confirmDelete(ChargerStation station) {
        if (!canManage(station)) {
            return;
        }
        new MaterialAlertDialogBuilder(requireContext())
                .setTitle(R.string.host_delete_station_title)
                .setMessage(getString(R.string.host_delete_station_confirm, station.getName()))
                .setNegativeButton(R.string.action_cancel, null)
                .setPositiveButton(R.string.action_delete, (dialog, which) -> deleteStation(station))
                .show();
    }

    private void deleteStation(ChargerStation station) {
        repo.background(() -> new DeleteOutcome(repo.deleteStationConfirmed(station)),
                (DeleteOutcome outcome) -> {
                    if (!isAdded()) {
                        return;
                    }
                    // A failed remote delete leaves the stations as they were, so say so.
                    String error = outcome == null
                            ? getString(R.string.host_delete_station_failed) : outcome.error;
                    if (error != null) {
                        Ux.error(this, error);
                        return;
                    }
                    Ux.success(this, getString(R.string.host_delete_station_done, station.getName()));
                    Navigator.openRoot(requireActivity(), new HostDashboardFragment(), "host_dashboard");
                });
    }

    /** The reason a delete was refused, or null when the station is gone. */
    private static class DeleteOutcome {
        private final String error;

        DeleteOutcome(String error) {
            this.error = error;
        }
    }

    /** Everything the host dashboard needs for one render pass, loaded off the main thread. */
    private static class HostData {
        final List<ChargerStation> stations;
        final List<ChargingSession> sessions;
        final HostAnalyticsEngine.HostAnalytics analytics;

        HostData(List<ChargerStation> stations, List<ChargingSession> sessions,
                 HostAnalyticsEngine.HostAnalytics analytics) {
            this.stations = stations;
            this.sessions = sessions;
            this.analytics = analytics;
        }
    }
}
