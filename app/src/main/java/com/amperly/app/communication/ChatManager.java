package com.amperly.app.communication;

import androidx.annotation.Nullable;

import com.amperly.app.data.local.entity.ChatMessage;
import com.amperly.app.data.local.entity.CommunicationThread;
import com.amperly.app.data.local.entity.Reservation;
import com.amperly.app.data.local.entity.User;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * Phone-only communication between a consumer and a host.
 *
 * <p>There is one conversation per pair of people, not one per booking: a second visit to the
 * same host continues the same chat, so the history is still there and the two of them do not
 * accumulate a new chat box for every reservation. The reservation on a thread is only the
 * latest booking it belongs to, kept for context and audit.
 *
 * <p>Personal phone numbers are masked, the conversation expires automatically after the
 * reservation/dispute window, and off-platform payment requests are flagged. Free-text chat is
 * never offered on the car display.
 */
public class ChatManager {

    /** One week after the reservation ends, the thread closes on its own. */
    public static final long THREAD_LIFETIME_AFTER_SLOT_MS = 7L * 24L * 60L * 60L * 1000L;

    public static final List<String> QUICK_QUESTIONS = Arrays.asList(
            "Where is the charging entrance?",
            "The port looks occupied, can you help?",
            "Can I extend my slot by 15 minutes?",
            "Can you confirm the meter readings?"
    );

    private ChatManager() {
    }

    public static String maskPhoneNumber(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return "••••";
        }
        String digits = phone.replaceAll("[^0-9]", "");
        if (digits.length() < 4) {
            return "••••";
        }
        String last2 = digits.substring(digits.length() - 2);
        return "+91 •••• ••" + last2;
    }

    /** Replaces any real phone number the user typed with the masked form before storing. */
    public static String sanitizeText(String text, String ownPhone, String otherPhone) {
        if (text == null) {
            return "";
        }
        String sanitized = text;
        if (ownPhone != null && !ownPhone.trim().isEmpty()) {
            sanitized = sanitized.replace(ownPhone.trim(), maskPhoneNumber(ownPhone));
        }
        if (otherPhone != null && !otherPhone.trim().isEmpty()) {
            sanitized = sanitized.replace(otherPhone.trim(), maskPhoneNumber(otherPhone));
        }
        // Generic 10+ digit runs are masked too.
        return sanitized.replaceAll("(?<!\\d)(\\d[\\d\\s-]{8,}\\d)(?!\\d)",
                "•••• masked ••••");
    }

    public static boolean containsOffPlatformPaymentRequest(String text) {
        if (text == null) {
            return false;
        }
        String lower = text.toLowerCase();
        return lower.contains("pay cash") || lower.contains("direct gpay") || lower.contains("off platform")
                || lower.contains("transfer account") || lower.contains("paytm me directly")
                || lower.contains("upi to my") || lower.contains("outside the app");
    }

    /**
     * When a conversation opened for this booking should close.
     *
     * <p>A week after the slot ends. Starting from the end rather than from the booking time means
     * a slot booked next month still has a usable chat window when the driver arrives.
     */
    public static long expiryFor(@Nullable Reservation reservation, long nowMs) {
        long slotEnd = reservation != null ? reservation.getEndTimeMs() : nowMs;
        return Math.max(nowMs, slotEnd) + THREAD_LIFETIME_AFTER_SLOT_MS;
    }

    public static CommunicationThread createThread(Reservation reservation, User consumer, User host) {
        long now = System.currentTimeMillis();
        long expiry = expiryFor(reservation, now);
        return new CommunicationThread(UUID.randomUUID().toString(),
                reservation == null ? null : reservation.getId(),
                consumer == null ? null : consumer.getId(),
                consumer == null ? "Consumer" : consumer.getName(),
                host == null ? null : host.getId(),
                host == null ? "Host" : host.getName(),
                maskPhoneNumber(consumer == null ? null : consumer.getPhone()),
                maskPhoneNumber(host == null ? null : host.getPhone()),
                false, false, true, now, expiry);
    }

    /**
     * Folds a new booking into the conversation these two people already have.
     *
     * <p>The thread id is deliberately kept: it is what keeps the messages that are already in the
     * thread together, and it is the key the server syncs on. What changes is the reservation the
     * thread now refers to — the latest booking between the two — plus a fresh expiry, so a new
     * visit reopens the window. Moderation state (reported, blocked) is left alone: one bad
     * thread is not cleared by booking again.
     */
    @Nullable
    public static CommunicationThread reuseForReservation(@Nullable CommunicationThread thread,
                                                          @Nullable Reservation reservation,
                                                          @Nullable User consumer,
                                                          @Nullable User host) {
        if (thread == null) {
            return null;
        }
        long now = System.currentTimeMillis();
        if (reservation != null) {
            thread.setReservationId(reservation.getId());
        }
        if (consumer != null) {
            thread.setConsumerName(consumer.getName());
            thread.setMaskedConsumerNumber(maskPhoneNumber(consumer.getPhone()));
        }
        if (host != null) {
            thread.setHostName(host.getName());
            thread.setMaskedHostNumber(maskPhoneNumber(host.getPhone()));
        }
        thread.setExpiresAtMs(Math.max(thread.getExpiresAtMs(), expiryFor(reservation, now)));
        return thread;
    }

    public static ChatMessage createMessage(String threadId, String reservationId, String senderId,
                                            String receiverId, String rawText, String ownPhone,
                                            String otherPhone) {
        boolean offPlatform = containsOffPlatformPaymentRequest(rawText);
        String body = sanitizeText(rawText, ownPhone, otherPhone);
        if (offPlatform) {
            body = body + "\n[Amperly: off-platform payment requests are flagged. Paying outside the app "
                    + "removes your dispute protection.]";
        }
        long now = System.currentTimeMillis();
        return new ChatMessage(UUID.randomUUID().toString(), threadId, reservationId, senderId,
                receiverId, body, now, false, false, 0);
    }

    public static boolean isThreadOpen(CommunicationThread thread, long nowMs) {
        return thread != null && !thread.isBlocked() && !thread.isExpired(nowMs);
    }

    public static String expiryLabel(long expiresAtMs) {
        return com.amperly.app.core.common.Formatters.dateTime(expiresAtMs);
    }
}
