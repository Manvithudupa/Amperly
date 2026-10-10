package com.amperly.app.data.local.entity;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "charger_stations")
public class ChargerStation {
    @PrimaryKey
    @NonNull
    private String id;
    private String hostId;
    private String name;
    private String address;
    private double latitude;
    private double longitude;
    private String locationType;
    private String operatingHours;
    private double pricePerKwh;
    private double serviceFee;
    private double gatewayFee;
    private String verificationLevel;
    private boolean isVerified;
    private boolean isPaused;
    private double rating;
    private long lastUpdatedMs;

    public ChargerStation(@NonNull String id, String hostId, String name, String address,
                          double latitude, double longitude, String locationType,
                          String operatingHours, double pricePerKwh, double serviceFee,
                          double gatewayFee, String verificationLevel, boolean isVerified,
                          boolean isPaused, double rating, long lastUpdatedMs) {
        this.id = id;
        this.hostId = hostId;
        this.name = name;
        this.address = address;
        this.latitude = latitude;
        this.longitude = longitude;
        this.locationType = locationType;
        this.operatingHours = operatingHours;
        this.pricePerKwh = pricePerKwh;
        this.serviceFee = serviceFee;
        this.gatewayFee = gatewayFee;
        this.verificationLevel = verificationLevel;
        this.isVerified = isVerified;
        this.isPaused = isPaused;
        this.rating = rating;
        this.lastUpdatedMs = lastUpdatedMs;
    }

    @NonNull
    public String getId() { return id; }
    public void setId(@NonNull String id) { this.id = id; }

    public String getHostId() { return hostId; }
    public void setHostId(String hostId) { this.hostId = hostId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public String getLocationType() { return locationType; }
    public void setLocationType(String locationType) { this.locationType = locationType; }

    public String getOperatingHours() { return operatingHours; }
    public void setOperatingHours(String operatingHours) { this.operatingHours = operatingHours; }

    public double getPricePerKwh() { return pricePerKwh; }
    public void setPricePerKwh(double pricePerKwh) { this.pricePerKwh = pricePerKwh; }

    public double getServiceFee() { return serviceFee; }
    public void setServiceFee(double serviceFee) { this.serviceFee = serviceFee; }

    public double getGatewayFee() { return gatewayFee; }
    public void setGatewayFee(double gatewayFee) { this.gatewayFee = gatewayFee; }

    public String getVerificationLevel() { return verificationLevel; }
    public void setVerificationLevel(String verificationLevel) { this.verificationLevel = verificationLevel; }

    public boolean isVerified() { return isVerified; }
    public void setVerified(boolean verified) { isVerified = verified; }

    public boolean isPaused() { return isPaused; }
    public void setPaused(boolean paused) { isPaused = paused; }

    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }

    public long getLastUpdatedMs() { return lastUpdatedMs; }
    public void setLastUpdatedMs(long lastUpdatedMs) { this.lastUpdatedMs = lastUpdatedMs; }
}
