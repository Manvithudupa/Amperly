package com.amperly.app.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.entity.Dispute;
import com.amperly.app.data.local.entity.MeterReading;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class DisputeAdapter extends RecyclerView.Adapter<DisputeAdapter.DisputeViewHolder> {

    public interface Listener {
        void onRefund(Dispute dispute);
        void onFreezePayout(Dispute dispute);
        void onWarning(Dispute dispute);
        void onFine(Dispute dispute);
        void onSuspend(Dispute dispute);
        void onBan(Dispute dispute);
    }

    public static class DisputeRow {
        private final Dispute dispute;
        private final List<MeterReading> evidence;

        public DisputeRow(Dispute dispute, List<MeterReading> evidence) {
            this.dispute = dispute;
            this.evidence = evidence;
        }

        public Dispute getDispute() { return dispute; }
    }

    private final List<DisputeRow> items = new ArrayList<>();
    private final Listener listener;

    public DisputeAdapter(Listener listener) {
        this.listener = listener;
    }

    public void submit(List<DisputeRow> rows) {
        items.clear();
        if (rows != null) {
            items.addAll(rows);
        }
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public DisputeViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_dispute, parent, false);
        return new DisputeViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull DisputeViewHolder holder, int position) {
        holder.bind(items.get(position));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    class DisputeViewHolder extends RecyclerView.ViewHolder {
        private final TextView reason;
        private final TextView meta;
        private final TextView notes;
        private final TextView hostResponse;
        private final TextView evidence;
        private final TextView enforcement;
        private final MaterialButton refund;
        private final MaterialButton freeze;
        private final MaterialButton warning;
        private final MaterialButton fine;
        private final MaterialButton suspend;
        private final MaterialButton ban;

        DisputeViewHolder(@NonNull View itemView) {
            super(itemView);
            reason = itemView.findViewById(R.id.disputeReasonText);
            meta = itemView.findViewById(R.id.disputeMetaText);
            notes = itemView.findViewById(R.id.disputeNotesText);
            hostResponse = itemView.findViewById(R.id.hostResponseText);
            evidence = itemView.findViewById(R.id.evidenceText);
            enforcement = itemView.findViewById(R.id.enforcementText);
            refund = itemView.findViewById(R.id.refundButton);
            freeze = itemView.findViewById(R.id.freezeButton);
            warning = itemView.findViewById(R.id.warningButton);
            fine = itemView.findViewById(R.id.fineButton);
            suspend = itemView.findViewById(R.id.suspendButton);
            ban = itemView.findViewById(R.id.banButton);
        }

        void bind(DisputeRow row) {
            Context context = itemView.getContext();
            Dispute dispute = row.getDispute();
            reason.setText(dispute.getReason() + " · " + dispute.getStatus());
            meta.setText(context.getString(R.string.dispute_meta,
                    dispute.getConsumerName() == null ? dispute.getConsumerId() : dispute.getConsumerName(),
                    dispute.getStationName() == null ? dispute.getStationId() : dispute.getStationName(),
                    Formatters.agoFromNow(dispute.getCreatedAtMs()))
                    + (dispute.isPayoutFrozen() ? context.getString(R.string.dispute_payout_held) : ""));
            notes.setText(context.getString(R.string.dispute_consumer_line,
                    dispute.getConsumerNotes() == null ? "\u2014" : dispute.getConsumerNotes()));
            hostResponse.setText(context.getString(R.string.dispute_host_line,
                    dispute.getHostNotes() == null
                            ? context.getString(R.string.dispute_host_none) : dispute.getHostNotes()));

            StringBuilder evidenceText = new StringBuilder(
                    context.getString(R.string.dispute_evidence_header));
            if (row.evidence == null || row.evidence.isEmpty()) {
                evidenceText.append(context.getString(R.string.dispute_evidence_none));
            } else {
                for (MeterReading reading : row.evidence) {
                    evidenceText.append("\n").append(context.getString(R.string.dispute_evidence_line,
                            fmt(reading.getStartMeterKwh()), fmt(reading.getEndMeterKwh()),
                            reading.getEndMeterKwh() - reading.getStartMeterKwh(),
                            reading.isSimulated()
                                    ? context.getString(R.string.dispute_simulated_suffix) : ""));
                    if (reading.getPhotoEvidenceUri() != null) {
                        evidenceText.append(context.getString(R.string.dispute_photo_suffix,
                                reading.getPhotoEvidenceUri()));
                    }
                }
            }
            evidence.setText(evidenceText.toString());

            String action = dispute.getEnforcementAction() == null
                    ? AppConstants.ENFORCEMENT_NONE : dispute.getEnforcementAction();
            enforcement.setText(context.getString(R.string.dispute_enforcement_line, action)
                    + (dispute.getRefundAmount() > 0
                    ? context.getString(R.string.dispute_refund_suffix,
                    Formatters.money(dispute.getRefundAmount())) : "")
                    + (dispute.getResolutionNote() == null || dispute.getResolutionNote().isEmpty()
                    ? "" : "\n" + dispute.getResolutionNote())
                    + "\n" + context.getString(R.string.dispute_policy_note));

            boolean open = dispute.isOpen();
            setEnabledIfOpen(refund, open);
            setEnabledIfOpen(warning, open);
            setEnabledIfOpen(fine, open);
            setEnabledIfOpen(suspend, open);
            setEnabledIfOpen(ban, open);
            freeze.setEnabled(true);

            refund.setOnClickListener(v -> notifyListener(0, dispute));
            freeze.setOnClickListener(v -> notifyListener(1, dispute));
            warning.setOnClickListener(v -> notifyListener(2, dispute));
            fine.setOnClickListener(v -> notifyListener(3, dispute));
            suspend.setOnClickListener(v -> notifyListener(4, dispute));
            ban.setOnClickListener(v -> notifyListener(5, dispute));
        }

        private void setEnabledIfOpen(MaterialButton button, boolean open) {
            button.setEnabled(open);
            button.setAlpha(open ? 1f : 0.6f);
        }

        private void notifyListener(int which, Dispute dispute) {
            if (listener == null) {
                return;
            }
            switch (which) {
                case 0: listener.onRefund(dispute); break;
                case 1: listener.onFreezePayout(dispute); break;
                case 2: listener.onWarning(dispute); break;
                case 3: listener.onFine(dispute); break;
                case 4: listener.onSuspend(dispute); break;
                default: listener.onBan(dispute); break;
            }
        }

        private String fmt(double value) {
            return String.format(Locale.US, "%.2f kWh", value);
        }
    }
}
