package com.amperly.app.feature.consumer;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.core.state.AppStateStore;
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.Invoice;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.dialog.ReportDialog;

import java.util.Locale;
import java.util.UUID;

/**
 * The itemized receipt for one charging session.
 *
 * <p>Both roles reach this screen: the consumer after a session, the host from a booking card.
 * The consumer arrives with a session id; the host arrives with a reservation id, because a
 * booking may not have been charged yet — in that case the receipt shows the booking and says the
 * meter readings are still pending instead of inventing a bill.
 */
public class ReceiptFragment extends Fragment {

    public static final String ARG_SESSION_ID = "session_id";
    public static final String ARG_RESERVATION_ID = "reservation_id";

    private AmperlyRepository repo;
    private LinearLayout container;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_receipt, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());
        container = view.findViewById(R.id.receiptContainer);

        String sessionId = getArguments() == null ? null : getArguments().getString(ARG_SESSION_ID);
        String reservationId = getArguments() == null
                ? null : getArguments().getString(ARG_RESERVATION_ID);

        repo.background(() -> {
            Reservation reservation = reservationId == null ? null : repo.getReservationSync(reservationId);
            ChargingSession session = sessionId == null ? null : repo.getSessionSync(sessionId);
            if (session == null && reservation != null) {
                session = repo.getSessionByReservationSync(reservation.getId());
            }
            // The consumer path with no argument: the reservation the app is currently working on.
            if (session == null && reservation == null && sessionId == null) {
                session = repo.getSessionByReservationSync(AppStateStore.get().getActiveReservationId());
            }
            if (reservation == null && session != null && session.getReservationId() != null) {
                reservation = repo.getReservationSync(session.getReservationId());
            }
            Invoice invoice = session == null ? null : repo.getInvoiceBySessionSync(session.getId());
            String consumerId = reservation != null ? reservation.getConsumerId()
                    : (session == null ? null : session.getConsumerId());
            User consumer = consumerId == null ? null : repo.getUserSync(consumerId);
            String portLabel = portLabel(reservation, session);
            return new ReceiptData(session, invoice, reservation, consumer, portLabel);
        }, data -> {
            if (data == null || !isAdded()) {
                return;
            }
            render(view, data);
        });
    }

    private String portLabel(@Nullable Reservation reservation, @Nullable ChargingSession session) {
        if (reservation != null && !TextUtils.isEmpty(reservation.getPortLabel())) {
            return reservation.getPortLabel();
        }
        if (session != null && !TextUtils.isEmpty(session.getPortId())) {
            return session.getPortId();
        }
        return "";
    }

    private void render(View view, ReceiptData data) {
        TextView title = view.findViewById(R.id.receiptTitleText);
        TextView stationText = view.findViewById(R.id.receiptStationText);
        TextView totalText = view.findViewById(R.id.receiptTotalText);
        TextView pendingText = view.findViewById(R.id.receiptPendingText);

        if (data.session == null && data.reservation == null) {
            title.setText(R.string.receipt_none_title);
            stationText.setText(R.string.receipt_none_body);
            totalText.setText("");
            pendingText.setVisibility(View.GONE);
            view.findViewById(R.id.receiptPaidBlock).setVisibility(View.GONE);
            view.findViewById(R.id.reportIssueButton).setVisibility(View.GONE);
            return;
        }

        ChargingSession session = data.session;
        Reservation reservation = data.reservation;
        long startMs = session != null ? session.getStartTimeMs()
                : (reservation == null ? 0 : reservation.getStartTimeMs());
        long endMs = session != null ? session.getEndTimeMs()
                : (reservation == null ? 0 : reservation.getEndTimeMs());
        String stationName = session != null && !TextUtils.isEmpty(session.getStationName())
                ? session.getStationName()
                : (reservation == null || TextUtils.isEmpty(reservation.getStationName())
                ? "" : reservation.getStationName());

        // A booking with no session yet says so in the pending notice below, not here twice.
        stationText.setText(stationName + "\n" + Formatters.dayAndSlot(startMs, endMs)
                + (session == null ? "" : (session.isMeterSimulated()
                ? getString(R.string.receipt_demo_meter_note)
                : getString(R.string.receipt_verified_note))));

        container.removeAllViews();
        addLine(getString(R.string.receipt_consumer),
                data.consumer == null || TextUtils.isEmpty(data.consumer.getName())
                        ? getString(R.string.host_booking_driver_unknown)
                        : data.consumer.getName());
        addLine(getString(R.string.receipt_port),
                TextUtils.isEmpty(data.portLabel) ? "—" : data.portLabel);
        addLine(getString(R.string.receipt_slot), Formatters.dayAndSlot(startMs, endMs));
        // The published rate is known from the booking itself, so it is shown before any reading.
        double tariff = tariffOf(reservation, session);
        if (tariff > 0) {
            addLine(getString(R.string.receipt_tariff), Formatters.money(tariff) + "/kWh");
        }

        boolean hasReadings = session != null
                && (session.getEndingMeterKwh() > 0 || session.getVerifiedKwhConsumed() > 0);
        // A booking that has not been charged has no meter readings to bill; saying so is more
        // honest than printing 0.00 kWh as if it had been measured.
        pendingText.setVisibility(hasReadings ? View.GONE : View.VISIBLE);

        if (hasReadings) {
            addLine(getString(R.string.receipt_start_reading),
                    String.format(Locale.US, "%.2f kWh", session.getStartingMeterKwh()));
            addLine(getString(R.string.receipt_end_reading),
                    String.format(Locale.US, "%.2f kWh", session.getEndingMeterKwh()));
            addLine(getString(R.string.receipt_verified_kwh),
                    Formatters.kwh(session.getVerifiedKwhConsumed()));
            addLine(getString(R.string.receipt_energy_charge), Formatters.money(session.getEnergyCharge()));
            addLine(getString(R.string.receipt_service_fee), Formatters.money(session.getServiceFee()));
            addLine(getString(R.string.receipt_gateway_fee), Formatters.money(session.getGatewayFee()));
            if (data.invoice != null && data.invoice.getAdjustment() > 0) {
                addLine(getString(R.string.receipt_adjustment),
                        "-" + Formatters.money(data.invoice.getAdjustment()));
            }
            totalText.setText(getString(R.string.receipt_final_amount,
                    Formatters.money(session.getTotalPaid())));
        } else {
            totalText.setText("");
        }

        // Payments are not collected in this build. The invoice is ISSUED, not PAID, so the
        // receipt must not claim a payment that never happened. A booking with no session has
        // nothing billed at all, so the block is hidden rather than reading "unpaid".
        boolean paid = data.invoice != null && "PAID".equalsIgnoreCase(data.invoice.getStatus());
        view.findViewById(R.id.receiptPaidBlock).setVisibility(session == null ? View.GONE : View.VISIBLE);
        view.findViewById(R.id.receiptPaidIcon).setVisibility(paid ? View.VISIBLE : View.GONE);
        ((TextView) view.findViewById(R.id.receiptPaidLabel)).setText(paid
                ? R.string.receipt_paid_label : R.string.receipt_unpaid_label);

        // A host reading a consumer's receipt has nothing to report to itself; the report action
        // belongs to the consumer who paid.
        View reportButton = view.findViewById(R.id.reportIssueButton);
        boolean canReport = session != null && AuthManager.getInstance().getCurrentUserId() != null
                && AuthManager.getInstance().getCurrentUserId().equals(session.getConsumerId());
        reportButton.setVisibility(canReport ? View.VISIBLE : View.GONE);
        if (canReport) {
            reportButton.setOnClickListener(v ->
                    ReportDialog.show(this, getString(R.string.report_title), null, (type, details) -> {
                        repo.background(() -> {
                            com.amperly.app.data.local.entity.Report report =
                                    new com.amperly.app.data.local.entity.Report(UUID.randomUUID().toString(),
                                            AuthManager.getInstance().getCurrentUserId(),
                                            AuthManager.getInstance().getCurrentUser().getName(),
                                            session.getStationId(), session.getHostId(),
                                            session.getId(), type,
                                            details == null || details.isEmpty()
                                                    ? getString(R.string.report_no_details) : details,
                                            "OPEN", System.currentTimeMillis());
                            repo.saveReport(report);
                            return Boolean.TRUE;
                        }, ok -> Ux.success(this, getString(R.string.report_submitted)));
                    }));
        }
    }

    /** The published rate for the slot, or the rate the session's energy charge works out to. */
    private double tariffOf(@Nullable Reservation reservation, @Nullable ChargingSession session) {
        if (reservation != null && reservation.getPricePerKwh() > 0) {
            return reservation.getPricePerKwh();
        }
        if (session != null && session.getVerifiedKwhConsumed() > 0) {
            return session.getEnergyCharge() / session.getVerifiedKwhConsumed();
        }
        return 0;
    }

    private void addLine(String label, String value) {
        View row = LayoutInflater.from(requireContext()).inflate(R.layout.item_billing_line, container, false);
        ((TextView) row.findViewById(R.id.lineLabelText)).setText(label);
        ((TextView) row.findViewById(R.id.lineValueText)).setText(value);
        container.addView(row);
    }

    private static class ReceiptData {
        private final ChargingSession session;
        private final Invoice invoice;
        private final Reservation reservation;
        private final User consumer;
        private final String portLabel;

        ReceiptData(ChargingSession session, Invoice invoice, Reservation reservation,
                    User consumer, String portLabel) {
            this.session = session;
            this.invoice = invoice;
            this.reservation = reservation;
            this.consumer = consumer;
            this.portLabel = portLabel;
        }
    }
}
