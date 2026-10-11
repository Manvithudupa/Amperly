package com.amperly.app.communication;

import com.amperly.app.data.local.entity.ChatMessage;

import java.util.UUID;

public class ChatManager {

    public static boolean containsOffPlatformPaymentRequest(String text) {
        if (text == null) return false;
        String lower = text.toLowerCase();
        return lower.contains("pay cash") || lower.contains("direct gpay") || lower.contains("off platform") || lower.contains("transfer account");
    }

    public static ChatMessage createMaskedMessage(String threadId, String reservationId, String senderId, String receiverId, String text) {
        boolean warning = containsOffPlatformPaymentRequest(text);
        String textToStore = warning ? text + "\n[System Warning: Avoid off-platform payments to remain covered by dispute guarantees]" : text;

        long now = System.currentTimeMillis();
        long expiry = now + (24 * 60 * 60 * 1000L); // Expires in 24 hours post-session

        return new ChatMessage(
                UUID.randomUUID().toString(), threadId, reservationId,
                senderId, receiverId, textToStore, now, false, false, expiry
        );
    }
}
