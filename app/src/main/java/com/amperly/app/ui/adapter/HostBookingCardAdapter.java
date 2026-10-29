package com.amperly.app.ui.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;

import com.amperly.app.R;
import com.amperly.app.core.common.Formatters;
import com.amperly.app.data.local.entity.Reservation;
import com.google.android.material.button.MaterialButton;

import java.util.ArrayList;
import java.util.List;

/**
 * One card per booking at the host's chargers.
 *
 * <p>The booking code is the card's leading control, not a label: tapping it opens the same QR
 * screen the consumer shows at the station. Chat and the receipt are the booking's two other
 * actions, so a host never has to hunt for them.
 */
public class HostBookingCardAdapter extends RecyclerView.Adapter<HostBookingCardAdapter.BookingViewHolder> {

    public interface Listener {
        void onShowCode(Reservation reservation);

        void onChat(Reservation reservation);

        void onReceipt(Reservation reservation);
    }

    /** A booking plus the driver name, already looked up off the main thread. */
    public static class Item {
        private final Reservation reservation;
        private final String consumerName;

        public Item(@NonNull Reservation reservation, @Nullable String consumerName) {
            this.reservation = reservation;
            this.consumerName = consumerName;
        }

        @NonNull
        public Reservation getReservation() {
            return reservation;
        }

        @Nullable
        public String getConsumerName() {
            return consumerName;
        }
    }

    private final List<Item> items = new ArrayList<>();
    private final Listener listener;

    public HostBookingCardAdapter(Listener listener) {
        this.listener = listener;
    }

    public void submit(@Nullable List<Item> bookings) {
        items.clear();
        if (bookings != null) {
            items.addAll(bookings);
        }
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public BookingViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_host_booking, parent, false);
        return new BookingViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull BookingViewHolder holder, int position) {
        holder.bind(items.get(position));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    class BookingViewHolder extends RecyclerView.ViewHolder {
        private final MaterialButton code;
        private final TextView status;
        private final TextView station;
        private final TextView driver;
        private final TextView slot;
        private final MaterialButton chat;
        private final MaterialButton receipt;

        BookingViewHolder(@NonNull View itemView) {
            super(itemView);
            code = itemView.findViewById(R.id.hostBookingCodeButton);
            status = itemView.findViewById(R.id.hostBookingStatusText);
            station = itemView.findViewById(R.id.hostBookingStationText);
            driver = itemView.findViewById(R.id.hostBookingDriverText);
            slot = itemView.findViewById(R.id.hostBookingSlotText);
            chat = itemView.findViewById(R.id.hostBookingChatButton);
            receipt = itemView.findViewById(R.id.hostBookingReceiptButton);
        }

        void bind(Item item) {
            Reservation reservation = item.getReservation();
            Context context = itemView.getContext();

            code.setText(reservation.getBookingCode());
            code.setContentDescription(context.getString(R.string.reservation_show_code,
                    reservation.getBookingCode()));
            status.setText(reservation.getStatus());

            station.setText(TextUtils.isEmpty(reservation.getStationName())
                    ? reservation.getStationId() : reservation.getStationName());

            String name = item.getConsumerName();
            driver.setText(TextUtils.isEmpty(name)
                    ? context.getString(R.string.host_booking_driver_unknown)
                    : context.getString(R.string.host_booking_driver, name));

            slot.setText(Formatters.dayAndSlot(reservation.getStartTimeMs(), reservation.getEndTimeMs())
                    + (TextUtils.isEmpty(reservation.getPortLabel())
                    ? "" : " · " + reservation.getPortLabel()));

            code.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onShowCode(reservation);
                }
            });
            chat.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onChat(reservation);
                }
            });
            receipt.setOnClickListener(v -> {
                if (listener != null) {
                    listener.onReceipt(reservation);
                }
            });
        }
    }
}
