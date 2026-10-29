package com.amperly.app.feature.host;

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
import com.amperly.app.core.nav.Navigator;
import com.amperly.app.core.security.AuthManager;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.User;
import com.amperly.app.data.repository.AmperlyRepository;
import com.amperly.app.feature.consumer.BookingQrFragment;
import com.amperly.app.feature.consumer.HostChatFragment;
import com.amperly.app.feature.consumer.ReceiptFragment;
import com.amperly.app.ui.adapter.HostBookingCardAdapter;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * The Host → Bookings tab: every booking made at the host's chargers, newest first.
 *
 * <p>Each booking is a card. The booking code is a chip that opens the QR the consumer shows at
 * the station, chat opens the one conversation this host has with that driver, and the receipt
 * opens the itemized bill for the session behind the booking.
 */
public class HostBookingsFragment extends Fragment {

    private AmperlyRepository repo;
    private HostBookingCardAdapter adapter;
    private TextView emptyText;
    private String hostId;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_host_bookings, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        repo = AmperlyRepository.getInstance(requireContext());
        hostId = AuthManager.getInstance().getCurrentUserId();
        emptyText = view.findViewById(R.id.hostBookingsEmptyText);

        adapter = new HostBookingCardAdapter(new HostBookingCardAdapter.Listener() {
            @Override
            public void onShowCode(Reservation reservation) {
                BookingQrFragment fragment = new BookingQrFragment();
                Bundle args = new Bundle();
                args.putString(BookingQrFragment.ARG_RESERVATION_ID, reservation.getId());
                fragment.setArguments(args);
                Navigator.open(HostBookingsFragment.this, fragment, "booking_qr");
            }

            @Override
            public void onChat(Reservation reservation) {
                // One thread per host/consumer pair: the chat opens on that driver's conversation
                // rather than on whichever thread happens to be first in the list.
                HostChatFragment fragment = new HostChatFragment();
                Bundle args = new Bundle();
                args.putString(HostChatFragment.ARG_CONSUMER_ID, reservation.getConsumerId());
                fragment.setArguments(args);
                Navigator.open(HostBookingsFragment.this, fragment, "chat");
            }

            @Override
            public void onReceipt(Reservation reservation) {
                ReceiptFragment fragment = new ReceiptFragment();
                Bundle args = new Bundle();
                args.putString(ReceiptFragment.ARG_RESERVATION_ID, reservation.getId());
                fragment.setArguments(args);
                Navigator.open(HostBookingsFragment.this, fragment, "receipt");
            }
        });

        RecyclerView list = view.findViewById(R.id.hostBookingsRecyclerView);
        list.setLayoutManager(new LinearLayoutManager(requireContext()));
        list.setAdapter(adapter);

        load();
    }

    @Override
    public void onResume() {
        super.onResume();
        // Coming back from a pull or from the QR screen: the rows may have moved on since the
        // last bind.
        load();
    }

    private void load() {
        repo.background(() -> {
            List<Reservation> reservations = repo.getReservationsForHostSync(hostId);
            List<HostBookingCardAdapter.Item> items = new ArrayList<>();
            if (reservations != null) {
                // Newest booking first, whatever the slot dates are.
                reservations.sort(Comparator.comparingLong(Reservation::getCreatedAtMs).reversed());
                for (Reservation reservation : reservations) {
                    User consumer = reservation.getConsumerId() == null
                            ? null : repo.getUserSync(reservation.getConsumerId());
                    items.add(new HostBookingCardAdapter.Item(reservation,
                            consumer == null ? null : consumer.getName()));
                }
            }
            return items;
        }, (List<HostBookingCardAdapter.Item> items) -> {
            if (!isAdded() || items == null || adapter == null) {
                return;
            }
            adapter.submit(items);
            emptyText.setVisibility(items.isEmpty() ? View.VISIBLE : View.GONE);
        });
    }
}
