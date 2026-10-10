package com.amperly.app.engine.billing;

import com.amperly.app.data.local.entity.ChargerStation;
import com.amperly.app.data.local.entity.Invoice;

import java.util.UUID;

public class BillingEngine {

    public static class BillingCalculationResult {
        private final boolean isValid;
        private final String errorMessage;
        private final double verifiedKwh;
        private final double energyCharge;
        private final double serviceFee;
        private final double gatewayFee;
        private final double finalTotal;
        private final Invoice invoice;

        public BillingCalculationResult(boolean isValid, String errorMessage, double verifiedKwh,
                                        double energyCharge, double serviceFee, double gatewayFee,
                                        double finalTotal, Invoice invoice) {
            this.isValid = isValid;
            this.errorMessage = errorMessage;
            this.verifiedKwh = verifiedKwh;
            this.energyCharge = energyCharge;
            this.serviceFee = serviceFee;
            this.gatewayFee = gatewayFee;
            this.finalTotal = finalTotal;
            this.invoice = invoice;
        }

        public boolean isValid() { return isValid; }
        public String getErrorMessage() { return errorMessage; }
        public double getVerifiedKwh() { return verifiedKwh; }
        public double getEnergyCharge() { return energyCharge; }
        public double getServiceFee() { return serviceFee; }
        public double getGatewayFee() { return gatewayFee; }
        public double getFinalTotal() { return finalTotal; }
        public Invoice getInvoice() { return invoice; }
    }

    public static BillingCalculationResult calculateBill(
            String sessionId, String consumerId, String hostId,
            ChargerStation station, double startMeterKwh, double endMeterKwh) {

        if (endMeterKwh < startMeterKwh) {
            return new BillingCalculationResult(
                    false, "Ending meter reading cannot be lower than starting meter reading.",
                    0, 0, 0, 0, 0, null
            );
        }

        double verifiedKwh = Math.round((endMeterKwh - startMeterKwh) * 100.0) / 100.0;
        double tariff = station != null ? station.getPricePerKwh() : 18.0;
        double serviceFee = station != null ? station.getServiceFee() : 5.0;
        double gatewayFee = station != null ? station.getGatewayFee() : 4.0;

        double energyCharge = Math.round((verifiedKwh * tariff) * 100.0) / 100.0;
        double finalTotal = Math.round((energyCharge + serviceFee + gatewayFee) * 100.0) / 100.0;

        Invoice invoice = new Invoice(
                UUID.randomUUID().toString(), sessionId, consumerId, hostId,
                verifiedKwh, energyCharge, serviceFee, gatewayFee, finalTotal,
                System.currentTimeMillis()
        );

        return new BillingCalculationResult(
                true, null, verifiedKwh, energyCharge, serviceFee, gatewayFee, finalTotal, invoice
        );
    }
}
