package com.amperly.app.ui.adapter;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.entity.Vehicle;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.List;

/**
 * One card per saved vehicle.
 *
 * <p>Tapping a card opens that profile in the editor; the button on a card that is not in use
 * makes it the profile every range and reservation check is evaluated against. The card itself
 * carries the numbers a driver recognises the car by, so the garage can be read without opening
 * anything.
 */
public class VehicleCardAdapter extends RecyclerView.Adapter<VehicleCardAdapter.VehicleViewHolder> {

    public interface Listener {
        void onEdit(Vehicle vehicle);

        void onUse(Vehicle vehicle);
    }

    private final List<Vehicle> items = new ArrayList<>();
    private final Listener listener;

    public VehicleCardAdapter(Listener listener) {
        this.listener = listener;
    }

    public void submit(List<Vehicle> vehicles) {
        items.clear();
        if (vehicles != null) {
            items.addAll(vehicles);
        }
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VehicleViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_vehicle_card, parent, false);
        return new VehicleViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull VehicleViewHolder holder, int position) {
        holder.bind(items.get(position));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    class VehicleViewHolder extends RecyclerView.ViewHolder {
        private final TextView name;
        private final TextView activeBadge;
        private final TextView meta;
        private final TextView stats;
        private final MaterialButton use;

        VehicleViewHolder(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.vehicleCardNameText);
            activeBadge = itemView.findViewById(R.id.vehicleCardActiveBadge);
            meta = itemView.findViewById(R.id.vehicleCardMetaText);
            stats = itemView.findViewById(R.id.vehicleCardStatsText);
            use = itemView.findViewById(R.id.vehicleCardUseButton);
        }

        void bind(Vehicle vehicle) {
            String displayName = vehicle.displayName();
            name.setText(displayName);

            activeBadge.setVisibility(vehicle.isActive() ? View.VISIBLE : View.GONE);

            String plate = vehicle.getLicensePlate() == null ? "" : vehicle.getLicensePlate().trim();
            String connector = Formatters.connectorType(vehicle.getConnectorType());
            if (plate.isEmpty() && connector.isEmpty()) {
                meta.setText(R.string.vehicle_no_registration);
            } else if (plate.isEmpty()) {
                meta.setText(connector);
            } else if (connector.isEmpty()) {
                meta.setText(plate);
            } else {
                meta.setText(itemView.getContext().getString(R.string.vehicle_card_meta,
                        plate, connector));
            }

            double capacity = vehicle.effectiveCapacityKwh();
            double efficiency = vehicle.effectiveEfficiencyKmPerKwh();
            int rangeKm = (int) Math.round(capacity * efficiency);
            stats.setText(itemView.getContext().getString(R.string.vehicle_card_stats,
                    capacity, efficiency, rangeKm));

            use.setVisibility(vehicle.isActive() ? View.GONE : View.VISIBLE);
            use.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onUse(vehicle);
                }
            });

            itemView.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onEdit(vehicle);
                }
            });
        }
    }
}
