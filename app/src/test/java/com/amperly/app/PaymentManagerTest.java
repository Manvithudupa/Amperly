package com.amperly.app;

import com.amperly.app.payment.PaymentManager;

import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

public class PaymentManagerTest {

    @Test
    public void testPaymentAuthorizationAndIdempotency() {
        String idempotencyKey = "idempotent_key_8899";

        PaymentManager.PaymentAuthResult firstAttempt = PaymentManager.authorizePayment("cons_101", 189.0, idempotencyKey);
        assertTrue(firstAttempt.isSuccess());
        assertNotNull(firstAttempt.getPaymentId());

        PaymentManager.PaymentAuthResult secondAttempt = PaymentManager.authorizePayment("cons_101", 189.0, idempotencyKey);
        assertTrue(secondAttempt.isSuccess());
        assertEquals("PAY_IDEMPOTENT_" + idempotencyKey, secondAttempt.getPaymentId());
    }
}
