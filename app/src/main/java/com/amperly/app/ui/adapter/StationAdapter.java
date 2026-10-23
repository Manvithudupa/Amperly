package com.amperly.app.ui.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.AppConstants;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.engine.availability.AvailabilityEngine;
import com.amperly.app.engine.routing.RoutePlannerEngine;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class StationAdapter extends RecyclerView.Adapter<StationAdapter.StationViewHolder> {

    public interface Listener {
        void onOpenStation(ChargerStation station);
        void onNavigateToStation(ChargerStation station);
    }

    public static class StationRow {
        private final ChargerStation station;
        private final AvailabilityEngine.AvailabilitySummary availability;
        private final String extraLine;

        public StationRow(ChargerStation station, AvailabilityEngine.AvailabilitySummary availability,
                          String extraLine) {
            this.station = station;
            this.availability = availability;
            this.extraLine = extraLine;
        }

        public ChargerStation getStation() { return station; }
        public AvailabilityEngine.AvailabilitySummary getAvailability() { return availability; }
        public String getExtraLine() { return extraLine; }
    }

    private final List<StationRow> rows = new ArrayList<>();
    private final Listener listener;
    private final com.amperly.app.data.local.entity.Vehicle vehicle;

    public StationAdapter(Listener listener, com.amperly.app.data.local.entity.Vehicle vehicle) {
        this.listener = listener;
        this.vehicle = vehicle;
    }

    public void submit(List<StationRow> newRows) {
        rows.clear();
        if (newRows != null) {
            rows.addAll(newRows);
        }
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public StationViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_station, parent, false);
        return new StationViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull StationViewHolder holder, int position) {
        holder.bind(rows.get(position));
    }

    @Override
    public int getItemCount() {
        return rows.size();
    }

    class StationViewHolder extends RecyclerView.ViewHolder {
        private final TextView name;
        private final TextView address;
        private final TextView type;
        private final TextView badge;
        private final TextView availability;
        private final TextView freshness;
        private final TextView price;
        private final TextView compatibility;
        private final TextView distance;
        private final LinearLayout connectorRow;
        private final MaterialButton details;
        private final MaterialButton navigate;

        StationViewHolder(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.stationNameText);
            address = itemView.findViewById(R.id.stationAddressText);
            type = itemView.findViewById(R.id.stationTypeText);
            badge = itemView.findViewById(R.id.verificationBadgeText);
            availability = itemView.findViewById(R.id.availabilityText);
            freshness = itemView.findViewById(R.id.freshnessText);
            price = itemView.findViewById(R.id.priceText);
            compatibility = itemView.findViewById(R.id.compatibilityText);
            distance = itemView.findViewById(R.id.distanceText);
            connectorRow = itemView.findViewById(R.id.connectorRow);
            details = itemView.findViewById(R.id.viewDetailsButton);
            navigate = itemView.findViewById(R.id.navigateButton);
        }

        void bind(StationRow row) {
            ChargerStation station = row.getStation();
            name.setText(station.getName());
            address.setText(station.getAddress());
            type.setText(locationTypeLabel(station.getLocationType()) + " · "
                    + (int) station.getMaxPowerKw() + " kW "
                    + (station.isDcCapable() ? "DC" : "AC"));
            bindConnectors(station);

            String extras = row.getExtraLine();
            if (extras != null && extras.contains("·")) {
                distance.setText(extras.substring(0, extras.indexOf('·')).trim());
            } else {
                distance.setText("");
            }

            // Words carry the state; the tint only reinforces it.
            if (station.supportsPaidEnergyBilling()) {
                badge.setText(R.string.label_meter_verified_short);
                badge.setBackgroundResource(R.drawable.bg_badge_success);
                badge.setTextColor(ContextCompat.getColor(
                        badge.getContext(), R.color.amp_available));
            } else {
                badge.setText(R.string.label_no_meter_short);
                badge.setBackgroundResource(R.drawable.bg_badge_warning);
                badge.setTextColor(ContextCompat.getColor(
                        badge.getContext(), R.color.amp_busy_ink));
            }

            AvailabilityEngine.AvailabilitySummary summary = row.getAvailability();
            long updatedAt = station.getLastUpdatedMs();
            if (summary != null) {
                availability.setText(summary.getLabel());
                updatedAt = summary.getLastUpdatedMs();
                boolean open = !summary.isPaused() && summary.getFreePorts() > 0;
                availability.setBackgroundResource(open
                        ? R.drawable.bg_badge_success : R.drawable.bg_badge_warning);
                availability.setTextColor(ContextCompat.getColor(availability.getContext(),
                        open ? R.color.amp_available : R.color.amp_busy_ink));
            } else {
                availability.setText(station.isPaused()
                        ? R.string.station_paused_by_host : R.string.station_availability_unknown);
                availability.setBackgroundResource(R.drawable.bg_badge_warning);
                availability.setTextColor(ContextCompat.getColor(
                        availability.getContext(), R.color.amp_busy_ink));
            }
            freshness.setText(itemView.getContext().getString(
                    R.string.label_availability_freshness, Formatters.agoFromNow(updatedAt)));

            price.setText(Formatters.money(station.getPricePerKwh()) + " "
                    + itemView.getContext().getString(R.string.unit_per_kwh));

            boolean compatible = RoutePlannerEngine.isConnectorCompatible(station, vehicle);
            StringBuilder compatibilityText = new StringBuilder();
            compatibilityText.append(itemView.getContext().getString(compatible
                    ? R.string.label_compatible : R.string.label_incompatible));
            if (station.getIncidentCount() > 0) {
                compatibilityText.append(" · ")
                        .append(itemView.getContext().getString(R.string.station_incidents,
                                station.getIncidentCount()));
            }
            compatibility.setText(compatibilityText.toString());

            itemView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onOpenStation(station);
                }
            });
            details.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onOpenStation(station);
                }
            });
            navigate.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onNavigateToStation(station);
                }
            });
        }

        /** One small glyph per connector, with the connector name as its content description. */
        private void bindConnectors(ChargerStation station) {
            connectorRow.removeAllViews();
            String types = station.getConnectorTypes();
            if (types == null) {
                return;
            }
            String upper = types.toUpperCase(Locale.US);
            addConnectorGlyph(R.drawable.ic_connector_ccs2, "CCS2", upper.contains("CCS"));
            addConnectorGlyph(R.drawable.ic_connector_chademo, "CHAdeMO", upper.contains("CHADEMO"));
            addConnectorGlyph(R.drawable.ic_connector_type2, "Type 2",
                    upper.contains("TYPE 2") || upper.contains("TYPE2"));
        }

        private void addConnectorGlyph(int drawable, String label, boolean present) {
            if (!present) {
                return;
            }
            ImageView glyph = new ImageView(connectorRow.getContext());
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(dp(18), dp(18));
            params.setMarginEnd(dp(4));
            glyph.setLayoutParams(params);
            glyph.setImageResource(drawable);
            glyph.setContentDescription(label);
            glyph.setColorFilter(ContextCompat.getColor(glyph.getContext(), R.color.amp_ink_secondary));
            connectorRow.addView(glyph);
        }

        private int dp(int value) {
            return Math.round(value * itemView.getResources().getDisplayMetrics().density);
        }

        private String locationTypeLabel(String type) {
            android.content.Context context = itemView.getContext();
            if (type == null) {
                return context.getString(R.string.location_type_charger);
            }
            switch (type) {
                case AppConstants.LOCATION_TYPE_CAMPUS:
                    return context.getString(R.string.location_type_campus);
                case AppConstants.LOCATION_TYPE_APARTMENT:
                    return context.getString(R.string.location_type_apartment);
                case AppConstants.LOCATION_TYPE_OFFICE:
                    return context.getString(R.string.location_type_office);
                case AppConstants.LOCATION_TYPE_CAFE:
                    return context.getString(R.string.location_type_cafe);
                case AppConstants.LOCATION_TYPE_HOTEL:
                    return context.getString(R.string.location_type_hotel);
                case AppConstants.LOCATION_TYPE_PARKING:
                    return context.getString(R.string.location_type_parking);
                case AppConstants.LOCATION_TYPE_PETROL_PUMP:
                    return context.getString(R.string.location_type_petrol_pump);
                default: return String.format(Locale.US, "%s",
                        type.substring(0, 1) + type.substring(1).toLowerCase(Locale.US));
            }
        }
    }
}
