package com.amperly.app.payment;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

public class PaymentManager {

    public static class PaymentAuthResult {
        private final boolean isSuccess;
        private final String paymentId;
        private final String idempotencyKey;
        private final double authorizedAmount;
        private final String message;

        public PaymentAuthResult(boolean isSuccess, String paymentId, String idempotencyKey,
                                 double authorizedAmount, String message) {
            this.isSuccess = isSuccess;
            this.paymentId = paymentId;
            this.idempotencyKey = idempotencyKey;
            this.authorizedAmount = authorizedAmount;
            this.message = message;
        }

        public boolean isSuccess() { return isSuccess; }
        public String getPaymentId() { return paymentId; }
        public String getIdempotencyKey() { return idempotencyKey; }
        public double getAuthorizedAmount() { return authorizedAmount; }
        public String getMessage() { return message; }
    }

    private static final Set<String> processedKeys = new HashSet<>();

    public static PaymentAuthResult authorizePayment(String consumerId, double amount, String idempotencyKey) {
        if (idempotencyKey != null && processedKeys.contains(idempotencyKey)) {
            return new PaymentAuthResult(true, "PAY_IDEMPOTENT_" + idempotencyKey, idempotencyKey, amount, "Idempotent payment already authorized.");
        }

        if (idempotencyKey != null) {
            processedKeys.add(idempotencyKey);
        }

        String paymentId = "PAY_SBX_" + UUID.randomUUID().toString().substring(0, 8);
        return new PaymentAuthResult(true, paymentId, idempotencyKey, amount, "Sandbox Payment Authorized Successfully.");
    }
}
