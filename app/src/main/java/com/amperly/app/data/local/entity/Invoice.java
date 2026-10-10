package com.amperly.app.data.local.entity;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "invoices")
public class Invoice {
    @PrimaryKey
    @NonNull
    private String id;
    private String sessionId;
    private String consumerId;
    private String hostId;
    private double verifiedKwh;
    private double energyCharge;
    private double serviceFee;
    private double gatewayFee;
    private double finalTotal;
    private long issuedAtMs;

    public Invoice(@NonNull String id, String sessionId, String consumerId, String hostId,
                   double verifiedKwh, double energyCharge, double serviceFee,
                   double gatewayFee, double finalTotal, long issuedAtMs) {
        this.id = id;
        this.sessionId = sessionId;
        this.consumerId = consumerId;
        this.hostId = hostId;
        this.verifiedKwh = verifiedKwh;
        this.energyCharge = energyCharge;
        this.serviceFee = serviceFee;
        this.gatewayFee = gatewayFee;
        this.finalTotal = finalTotal;
        this.issuedAtMs = issuedAtMs;
    }

    @NonNull
    public String getId() { return id; }
    public void setId(@NonNull String id) { this.id = id; }

    public String getSessionId() { return sessionId; }
    public void setSessionId(String sessionId) { this.sessionId = sessionId; }

    public String getConsumerId() { return consumerId; }
    public void setConsumerId(String consumerId) { this.consumerId = consumerId; }

    public String getHostId() { return hostId; }
    public void setHostId(String hostId) { this.hostId = hostId; }

    public double getVerifiedKwh() { return verifiedKwh; }
    public void setVerifiedKwh(double verifiedKwh) { this.verifiedKwh = verifiedKwh; }

    public double getEnergyCharge() { return energyCharge; }
    public void setEnergyCharge(double energyCharge) { this.energyCharge = energyCharge; }

    public double getServiceFee() { return serviceFee; }
    public void setServiceFee(double serviceFee) { this.serviceFee = serviceFee; }

    public double getGatewayFee() { return gatewayFee; }
    public void setGatewayFee(double gatewayFee) { this.gatewayFee = gatewayFee; }

    public double getFinalTotal() { return finalTotal; }
    public void setFinalTotal(double finalTotal) { this.finalTotal = finalTotal; }

    public long getIssuedAtMs() { return issuedAtMs; }
    public void setIssuedAtMs(long issuedAtMs) { this.issuedAtMs = issuedAtMs; }
}
