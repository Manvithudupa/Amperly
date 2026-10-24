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
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.security.RoleGuard;
import com.amperly.app.data.local.entity.ChargerPort;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.MeterReading;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.engine.analytics.HostAnalyticsEngine;
import com.amperly.app.engine.billing.BillingEngine;
import com.amperly.app.engine.meter.MeterSimulator;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.adapter.ReservationAdapter;
import com.amperly.app.ui.adapter.SessionAdapter;
import com.amperly.app.ui.dialog.MeterEvidenceDialog;

import java.util.List;
import java.util.Locale;
import java.util.UUID;

/**
 * The host's operational view: live availability, reservations, sessions with meter evidence, and
 * utilisation/revenue analytics. Hosts never see consumer personal data beyond the reservation.
 */
public class HostDashboardFragment extends Fragment {

    /** Which block the bottom navigation asked for. The page is one screen either way. */
    public static final String ARG_SECTION = "section";
    public static final String SECTION_BOOKINGS = "bookings";

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

        RecyclerView stations = view.findViewById(R.id.stationsRecyclerView);
        stations.setLayoutManager(new LinearLayoutManager(requireContext()));
        stations.setNestedScrollingEnabled(false);

        RecyclerView reservations = view.findViewById(R.id.reservationsRecyclerView);
        reservations.setLayoutManager(new LinearLayoutManager(requireContext()));
        reservations.setNestedScrollingEnabled(false);

        RecyclerView sessions = view.findViewById(R.id.sessionsRecyclerView);
        sessions.setLayoutManager(new LinearLayoutManager(requireContext()));
        sessions.setNestedScrollingEnabled(false);

        final ReservationAdapter reservationAdapter = new ReservationAdapter(new ReservationAdapter.Listener() {
            @Override
            public void onOpenQr(Reservation reservation) {
                hostScanBooking(reservation);
            }

            @Override
            public void onCheckIn(Reservation reservation) {
                hostStartSession(reservation);
            }

            @Override
            public void onMessageHost(Reservation reservation) {
                Navigator.openRoot(requireActivity(), new com.amperly.app.feature.consumer.HostChatFragment(), "chat");
            }

            @Override
            public void onCancel(Reservation reservation) {
                releaseSlot(reservation);
            }
        });
        reservations.setAdapter(reservationAdapter);

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

        view.findViewById(R.id.registerNewStationButton).setOnClickListener(v ->
                Navigator.openRoot(requireActivity(), new RegisterStationFragment(), "register"));

        load(reservationAdapter, sessionAdapter, stations);

        // The Bookings tab opens this same page at its reservations block.
        String section = getArguments() == null ? null : getArguments().getString(ARG_SECTION);
        if (SECTION_BOOKINGS.equals(section)) {
            view.postDelayed(() -> scrollTo(R.id.hostBookingsSection), 250);
        }
    }

    private void scrollTo(int viewId) {
        View root = getView();
        if (root == null) {
            return;
        }
        View scroll = root.findViewById(R.id.hostScrollView);
        View target = root.findViewById(viewId);
        if (scroll instanceof android.widget.ScrollView && target != null) {
            ((android.widget.ScrollView) scroll).smoothScrollTo(0, target.getTop());
        }
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    private void load(ReservationAdapter reservationAdapter, SessionAdapter sessionAdapter,
                      RecyclerView stationsView) {
        repo.background(() -> {
            List<ChargerStation> stations = repo.getStationsForHostSync(hostId);
            List<Reservation> reservations = repo.getReservationsForHostSync(hostId);
            List<ChargingSession> sessions = repo.getSessionsForHostSync(hostId);
            HostAnalyticsEngine.HostAnalytics analytics = repo.hostAnalytics(hostId);
            return new HostData(stations, reservations, sessions, analytics);
        }, (HostData data) -> {
            if (data == null || !isAdded()) {
                return;
            }
            bindStats(data.analytics);
            bindStations(stationsView, data.stations);
            reservationAdapter.submit(data.reservations);
            sessionAdapter.submit(data.sessions);
            bindAnalytics(data.analytics);
        });
    }

    private void bindStats(HostAnalyticsEngine.HostAnalytics analytics) {
        View view = getView();
        if (view == null) {
            return;
        }
        ((TextView) view.findViewById(R.id.statsSessionsText)).setText(String.valueOf(analytics.getSessionsCompleted()));
        ((TextView) view.findViewById(R.id.statsEnergyText)).setText(
                String.format(Locale.US, "%.1f", analytics.getEnergyDeliveredKwh()));
        // A bare "0%" under three labelled numbers reads as a broken value; say what it measures.
        ((TextView) view.findViewById(R.id.statsUtilizationText)).setText(
                getString(R.string.analytics_utilization_short,
                        Formatters.percent(analytics.getUtilizationPercent())));
        ((TextView) view.findViewById(R.id.statsRevenueText)).setText(
                Formatters.moneyShort(analytics.getRevenue()));
    }

    private void bindAnalytics(HostAnalyticsEngine.HostAnalytics analytics) {
        analyticsContainer.removeAllViews();
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

    private void bindStations(RecyclerView recyclerView, List<ChargerStation> stations) {
        emptyText.setVisibility(stations.isEmpty() ? View.VISIBLE : View.GONE);
        recyclerView.setAdapter(new androidx.recyclerview.widget.RecyclerView.Adapter<StationHolder>() {
            @NonNull
            @Override
            public StationHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
                View view = LayoutInflater.from(parent.getContext())
                        .inflate(R.layout.item_host_station, parent, false);
                return new StationHolder(view);
            }

            @Override
            public void onBindViewHolder(@NonNull StationHolder holder, int position) {
                holder.bind(stations.get(position));
            }

            @Override
            public int getItemCount() {
                return stations.size();
            }
        });
    }

    class StationHolder extends RecyclerView.ViewHolder {
        private final TextView name;
        private final TextView meta;
        private final TextView status;
        private final com.google.android.material.button.MaterialButton pause;
        private final com.google.android.material.button.MaterialButton evidence;

        StationHolder(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.hostStationNameText);
            meta = itemView.findViewById(R.id.hostStationMetaText);
            status = itemView.findViewById(R.id.hostStationStatusText);
            pause = itemView.findViewById(R.id.pauseStationButton);
            evidence = itemView.findViewById(R.id.meterEvidenceButton);
        }

        void bind(ChargerStation station) {
            name.setText(station.getName());
            meta.setText(itemView.getContext().getString(R.string.host_station_meta,
                    station.getAddress(), Formatters.connectorTypes(station.getConnectorTypes()),
                    (int) station.getMaxPowerKw(), station.getPortCount(),
                    Formatters.money(station.getPricePerKwh())));
            // The review state, the meter and the paused flag all in words, never the stored codes.
            String review = Formatters.approvalStatus(station.getApprovalStatus())
                    + " · " + Formatters.verificationLevel(station.getVerificationLevel());
            if (station.isPaused()) {
                review = getString(R.string.host_station_paused_state, review);
            }
            status.setText(itemView.getContext().getString(R.string.host_station_status, review,
                    Formatters.agoFromNow(station.getLastUpdatedMs())));
            pause.setText(station.isPaused() ? R.string.host_resume_station : R.string.host_pause_station);
            pause.setOnClickListener(v -> togglePause(station));
            evidence.setOnClickListener(v -> captureEvidence(station));
        }
    }

    /** The station actions are host-owned; RLS is the real gate, this fails early with a message. */
    private boolean canManage(ChargerStation station) {
        User user = AuthManager.getInstance().getCurrentUser();
        if (station == null || !RoleGuard.canManageStation(user, station.getHostId())) {
            Ux.error(this, getString(R.string.error_not_allowed));
            return false;
        }
        return true;
    }

    private void togglePause(ChargerStation station) {
        if (!canManage(station)) {
            return;
        }
        boolean newState = !station.isPaused();
        station.setPaused(newState);
        station.setLastUpdatedMs(System.currentTimeMillis());
        repo.updateStation(station);
        repo.blockStation(station.getId(), newState, newState ? "Paused by the host" : null);
        Ux.success(this, getString(newState
                ? R.string.host_station_paused : R.string.host_station_reopened));
        Navigator.openRoot(requireActivity(), new HostDashboardFragment(), "host_dashboard");
    }

    private void captureEvidence(ChargerStation station) {
        if (!canManage(station)) {
            return;
        }
        MeterEvidenceDialog.show(this, station.getName(), station.getId(),
                MeterSimulator.currentReading(station.getId()), (start, end, note) -> {
                    if (!MeterSimulator.isValidReading(start, end)) {
                        Ux.error(this, getString(R.string.session_invalid_reading));
                        return;
                    }
                    if (MeterSimulator.isOffline(station.getId())) {
                        Ux.info(this, getString(R.string.session_meter_offline));
                    }
                    MeterSimulator.setReading(station.getId(), end);
                    repo.background(() -> {
                        MeterReading reading = new MeterReading(UUID.randomUUID().toString(),
                                null, station.getId(), start, end, null,
                                station.getVerificationLevel(), System.currentTimeMillis(), true);
                        repo.saveMeterReading(reading);
                        return Boolean.TRUE;
                    }, ok -> Ux.success(this, getString(R.string.host_meter_evidence_saved,
                            String.format(Locale.US, "%.2f kWh", end - start))));
                });
    }

    private void hostScanBooking(Reservation reservation) {
        Ux.info(this, getString(R.string.host_booking_verified, reservation.getBookingCode(),
                reservation.getStationName(), reservation.getConsumerId()));
    }

    private void hostStartSession(Reservation reservation) {
        repo.background(() -> {
            double start = MeterSimulator.beginSession(reservation.getStationId());
            reservation.setStatus(AppConstants.STATUS_CHECKED_IN);
            reservation.setCheckedInAtMs(System.currentTimeMillis());
            repo.updateReservation(reservation);

            ChargerStation station = repo.getStationSync(reservation.getStationId());
            ChargingSession session = new ChargingSession(UUID.randomUUID().toString(), reservation.getId(),
                    reservation.getConsumerId(), hostId, reservation.getStationId(),
                    reservation.getStationName(), reservation.getPortId(), System.currentTimeMillis(),
                    0, start, 0, 0, 0, 0, 0, 0, AppConstants.STATUS_CHARGING, null, null, true,
                    station == null ? AppConstants.LEVEL_1_VERIFIED_MANUAL : station.getVerificationLevel());
            repo.saveSession(session);
            return start;
        }, start -> {
            if (start != null) {
                Ux.success(this, getString(R.string.host_session_started,
                        String.format(Locale.US, "%.2f kWh", start)));
                Navigator.openRoot(requireActivity(), new HostDashboardFragment(), "host_dashboard");
            }
        });
    }

    private void releaseSlot(Reservation reservation) {
        repo.background(() -> {
            BillingEngine.CancellationResult result = BillingEngine.calculateCancellation(reservation,
                    System.currentTimeMillis());
            // cancel_reservation is the only writer allowed to change the cancellation fee, and
            // it also releases the port. The local row is updated only after it succeeds.
            String error = repo.cancelReservationConfirmed(reservation, result.getFee());
            if (error != null) {
                return new ReleaseOutcome(false, error);
            }
            List<ChargerPort> ports = repo.getPortsSync(reservation.getStationId());
            for (ChargerPort port : ports) {
                if (port.getId().equals(reservation.getPortId())) {
                    // The host owns this station, so the status is pushed as well as cached.
                    repo.setPortStatus(port, AppConstants.PORT_AVAILABLE);
                }
            }
            return new ReleaseOutcome(true, result.getMessage());
        }, outcome -> {
            if (outcome == null) {
                return;
            }
            if (!outcome.success) {
                Ux.error(this, outcome.message);
                return;
            }
            Ux.info(this, outcome.message);
            Navigator.openRoot(requireActivity(), new HostDashboardFragment(), "host_dashboard");
        });
    }

    private static class ReleaseOutcome {
        private final boolean success;
        private final String message;

        ReleaseOutcome(boolean success, String message) {
            this.success = success;
            this.message = message;
        }
    }

    /** Everything the host dashboard needs for one render pass, loaded off the main thread. */
    private static class HostData {
        final List<ChargerStation> stations;
        final List<Reservation> reservations;
        final List<ChargingSession> sessions;
        final HostAnalyticsEngine.HostAnalytics analytics;

        HostData(List<ChargerStation> stations, List<Reservation> reservations,
                 List<ChargingSession> sessions, HostAnalyticsEngine.HostAnalytics analytics) {
            this.stations = stations;
            this.reservations = reservations;
            this.sessions = sessions;
            this.analytics = analytics;
        }
    }
}
