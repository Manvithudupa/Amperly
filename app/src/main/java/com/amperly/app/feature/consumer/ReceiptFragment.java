package com.amperly.app.feature.consumer;

import android.os.Bundle;
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
import com.amperly.app.data.local.entity.ChargingSession;
import com.amperly.app.data.local.entity.Invoice;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.ui.Ux;
import com.amperly.app.ui.dialog.ReportDialog;

import java.util.Locale;
import java.util.UUID;

public class ReceiptFragment extends Fragment {

    public static final String ARG_SESSION_ID = "session_id";

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

        repo.background(() -> {
            ChargingSession session = sessionId == null ? null : repo.getSessionSync(sessionId);
            if (session == null) {
                session = repo.getSessionByReservationSync(com.amperly.app.core.state.AppStateStore
                        .get().getActiveReservationId());
            }
            Invoice invoice = session == null ? null : repo.getInvoiceBySessionSync(session.getId());
            return new ReceiptData(session, invoice);
        }, data -> {
            if (data == null || !isAdded()) {
                return;
            }
            render(view, data);
        });
    }

    private void render(View view, ReceiptData data) {
        TextView title = view.findViewById(R.id.receiptTitleText);
        TextView stationText = view.findViewById(R.id.receiptStationText);
        TextView totalText = view.findViewById(R.id.receiptTotalText);

        if (data.session == null) {
            title.setText(R.string.receipt_none_title);
            stationText.setText(R.string.receipt_none_body);
            totalText.setText("");
            view.findViewById(R.id.receiptPaidBlock).setVisibility(View.GONE);
            view.findViewById(R.id.reportIssueButton).setVisibility(View.GONE);
            return;
        }

        stationText.setText((data.session.getStationName() == null ? data.session.getStationId()
                : data.session.getStationName())
                + "\n" + Formatters.dateTime(data.session.getStartTimeMs())
                + (data.session.isMeterSimulated()
                ? getString(R.string.receipt_demo_meter_note)
                : getString(R.string.receipt_verified_note)));

        container.removeAllViews();
        addLine(getString(R.string.receipt_start_reading),
                String.format(Locale.US, "%.2f kWh", data.session.getStartingMeterKwh()));
        addLine(getString(R.string.receipt_end_reading),
                String.format(Locale.US, "%.2f kWh", data.session.getEndingMeterKwh()));
        addLine(getString(R.string.receipt_verified_kwh), Formatters.kwh(data.session.getVerifiedKwhConsumed()));
        addLine(getString(R.string.receipt_energy_charge), Formatters.money(data.session.getEnergyCharge()));
        addLine(getString(R.string.receipt_service_fee), Formatters.money(data.session.getServiceFee()));
        addLine(getString(R.string.receipt_gateway_fee), Formatters.money(data.session.getGatewayFee()));
        if (data.invoice != null && data.invoice.getAdjustment() > 0) {
            addLine(getString(R.string.receipt_adjustment),
                    "-" + Formatters.money(data.invoice.getAdjustment()));
        }
        totalText.setText(getString(R.string.receipt_final_amount,
                Formatters.money(data.session.getTotalPaid())));

        // Payments are not collected in this build. The invoice is ISSUED, not PAID, so the
        // receipt must not claim a payment that never happened.
        boolean paid = data.invoice != null && "PAID".equalsIgnoreCase(data.invoice.getStatus());
        view.findViewById(R.id.receiptPaidBlock).setVisibility(View.VISIBLE);
        view.findViewById(R.id.receiptPaidIcon).setVisibility(paid ? View.VISIBLE : View.GONE);
        ((TextView) view.findViewById(R.id.receiptPaidLabel)).setText(paid
                ? R.string.receipt_paid_label : R.string.receipt_unpaid_label);

        view.findViewById(R.id.reportIssueButton).setOnClickListener(v ->
                ReportDialog.show(this, getString(R.string.report_title), null, (type, details) -> {
                    repo.background(() -> {
                        com.amperly.app.data.local.entity.Report report =
                                new com.amperly.app.data.local.entity.Report(UUID.randomUUID().toString(),
                                        AuthManager.getInstance().getCurrentUserId(),
                                        AuthManager.getInstance().getCurrentUser().getName(),
                                        data.session.getStationId(), data.session.getHostId(),
                                        data.session.getId(), type,
                                        details == null || details.isEmpty()
                                                ? getString(R.string.report_no_details) : details,
                                        "OPEN", System.currentTimeMillis());
                        repo.saveReport(report);
                        return Boolean.TRUE;
                    }, ok -> Ux.success(this, getString(R.string.report_submitted)));
                }));
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

        ReceiptData(ChargingSession session, Invoice invoice) {
            this.session = session;
            this.invoice = invoice;
        }
    }
}
