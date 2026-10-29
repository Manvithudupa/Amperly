package com.amperly.app.ui.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.entity.ChargerStation;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.List;

/**
 * One card per charger the host has registered.
 *
 * <p>The card carries what a host recognises a listing by — name, address, connector and power,
 * review state — and the two actions a listing needs day to day: pause it, or record meter
 * evidence for it. Adding a station is the page's button, not a card.
 */
public class StationCardAdapter extends RecyclerView.Adapter<StationCardAdapter.StationViewHolder> {

    public interface Listener {
        void onTogglePause(ChargerStation station);

        void onEvidence(ChargerStation station);
    }

    private final List<ChargerStation> items = new ArrayList<>();
    private final Listener listener;

    public StationCardAdapter(Listener listener) {
        this.listener = listener;
    }

    public void submit(List<ChargerStation> stations) {
        items.clear();
        if (stations != null) {
            items.addAll(stations);
        }
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public StationViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_station_card, parent, false);
        return new StationViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull StationViewHolder holder, int position) {
        holder.bind(items.get(position));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    class StationViewHolder extends RecyclerView.ViewHolder {
        private final TextView name;
        private final TextView statusBadge;
        private final TextView address;
        private final TextView meta;
        private final TextView details;
        private final MaterialButton pause;
        private final MaterialButton evidence;

        StationViewHolder(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.stationCardNameText);
            statusBadge = itemView.findViewById(R.id.stationCardStatusBadge);
            address = itemView.findViewById(R.id.stationCardAddressText);
            meta = itemView.findViewById(R.id.stationCardMetaText);
            details = itemView.findViewById(R.id.stationCardDetailsText);
            pause = itemView.findViewById(R.id.stationCardPauseButton);
            evidence = itemView.findViewById(R.id.stationCardEvidenceButton);
        }

        void bind(ChargerStation station) {
            Context context = itemView.getContext();
            name.setText(station.getName());
            address.setText(station.getAddress());
            meta.setText(context.getString(R.string.host_station_card_meta,
                    Formatters.connectorTypes(station.getConnectorTypes()),
                    (int) station.getMaxPowerKw(), station.getPortCount(),
                    Formatters.money(station.getPricePerKwh())));

            // The review state in the badge, the meter and the last change in words beneath it.
            String review = Formatters.approvalStatus(station.getApprovalStatus());
            statusBadge.setText(station.isPaused()
                    ? context.getString(R.string.host_station_paused_state, review) : review);
            details.setText(context.getString(R.string.host_station_status,
                    Formatters.verificationLevel(station.getVerificationLevel()),
                    Formatters.agoFromNow(station.getLastUpdatedMs())));

            pause.setText(station.isPaused()
                    ? R.string.host_resume_station : R.string.host_pause_station);
            pause.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onTogglePause(station);
                }
            });
            evidence.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onEvidence(station);
                }
            });
        }
    }
}
