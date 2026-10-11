package com.amperly.app;

import com.amperly.app.communication.ChatManager;
import com.amperly.app.data.local.entity.ChatMessage;

import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

public class ChatManagerTest {

    @Test
    public void testOffPlatformPaymentDetection() {
        assertTrue(ChatManager.containsOffPlatformPaymentRequest("Please pay cash directly at charger"));
        assertTrue(ChatManager.containsOffPlatformPaymentRequest("Direct GPay me the money"));
        assertFalse(ChatManager.containsOffPlatformPaymentRequest("Where is the charging port?"));
    }

    @Test
    public void testMaskedMessageCreation() {
        ChatMessage message = ChatManager.createMaskedMessage("th_1", "res_1", "cons_1", "host_1", "Direct GPay me ₹200");
        assertNotNull(message);
        assertTrue(message.getMessageText().contains("[System Warning:"));
        assertTrue(message.getExpiresAtMs() > message.getCreatedAtMs());
    }
}
