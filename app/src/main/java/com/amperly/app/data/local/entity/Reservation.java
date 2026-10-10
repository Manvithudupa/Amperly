package com.amperly.app.data.local.entity;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "reservations")
public class Reservation {
    @PrimaryKey
    @NonNull
    private String id;
    private String consumerId;
    private String stationId;
    private String portId;
    private String bookingCode;
    private long startTimeMs;
    private long endTimeMs;
    private String status;
    private double pricePerKwh;
    private double serviceFee;
    private double gatewayFee;
    private long createdAtMs;

    public Reservation(@NonNull String id, String consumerId, String stationId, String portId,
                       String bookingCode, long startTimeMs, long endTimeMs, String status,
                       double pricePerKwh, double serviceFee, double gatewayFee, long createdAtMs) {
        this.id = id;
        this.consumerId = consumerId;
        this.stationId = stationId;
        this.portId = portId;
        this.bookingCode = bookingCode;
        this.startTimeMs = startTimeMs;
        this.endTimeMs = endTimeMs;
        this.status = status;
        this.pricePerKwh = pricePerKwh;
        this.serviceFee = serviceFee;
        this.gatewayFee = gatewayFee;
        this.createdAtMs = createdAtMs;
    }

    @NonNull
    public String getId() { return id; }
    public void setId(@NonNull String id) { this.id = id; }

    public String getConsumerId() { return consumerId; }
    public void setConsumerId(String consumerId) { this.consumerId = consumerId; }

    public String getStationId() { return stationId; }
    public void setStationId(String stationId) { this.stationId = stationId; }

    public String getPortId() { return portId; }
    public void setPortId(String portId) { this.portId = portId; }

    public String getBookingCode() { return bookingCode; }
    public void setBookingCode(String bookingCode) { this.bookingCode = bookingCode; }

    public long getStartTimeMs() { return startTimeMs; }
    public void setStartTimeMs(long startTimeMs) { this.startTimeMs = startTimeMs; }

    public long getEndTimeMs() { return endTimeMs; }
    public void setEndTimeMs(long endTimeMs) { this.endTimeMs = endTimeMs; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public double getPricePerKwh() { return pricePerKwh; }
    public void setPricePerKwh(double pricePerKwh) { this.pricePerKwh = pricePerKwh; }

    public double getServiceFee() { return serviceFee; }
    public void setServiceFee(double serviceFee) { this.serviceFee = serviceFee; }

    public double getGatewayFee() { return gatewayFee; }
    public void setGatewayFee(double gatewayFee) { this.gatewayFee = gatewayFee; }

    public long getCreatedAtMs() { return createdAtMs; }
    public void setCreatedAtMs(long createdAtMs) { this.createdAtMs = createdAtMs; }
}
