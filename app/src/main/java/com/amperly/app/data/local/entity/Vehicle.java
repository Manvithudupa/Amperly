package com.amperly.app.data.local.entity;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "vehicles")
public class Vehicle {
    @PrimaryKey
    @NonNull
    private String id;
    private String userId;
    private String make;
    private String model;
    private String variant;
    private int purchaseYear;
    private double batteryCapacityKwh;
    private String connectorType;
    private double maxAcKw;
    private double maxDcKw;
    private double typicalEfficiencyKmPerKwh;
    private double degradationFactorPercent;
    private int minArrivalSocPercent;
    private int maxChargeSocPercent;
    private String licensePlate;

    public Vehicle(@NonNull String id, String userId, String make, String model, String variant,
                   int purchaseYear, double batteryCapacityKwh, String connectorType,
                   double maxAcKw, double maxDcKw, double typicalEfficiencyKmPerKwh,
                   double degradationFactorPercent, int minArrivalSocPercent,
                   int maxChargeSocPercent, String licensePlate) {
        this.id = id;
        this.userId = userId;
        this.make = make;
        this.model = model;
        this.variant = variant;
        this.purchaseYear = purchaseYear;
        this.batteryCapacityKwh = batteryCapacityKwh;
        this.connectorType = connectorType;
        this.maxAcKw = maxAcKw;
        this.maxDcKw = maxDcKw;
        this.typicalEfficiencyKmPerKwh = typicalEfficiencyKmPerKwh;
        this.degradationFactorPercent = degradationFactorPercent;
        this.minArrivalSocPercent = minArrivalSocPercent;
        this.maxChargeSocPercent = maxChargeSocPercent;
        this.licensePlate = licensePlate;
    }

    @NonNull
    public String getId() { return id; }
    public void setId(@NonNull String id) { this.id = id; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getMake() { return make; }
    public void setMake(String make) { this.make = make; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getVariant() { return variant; }
    public void setVariant(String variant) { this.variant = variant; }

    public int getPurchaseYear() { return purchaseYear; }
    public void setPurchaseYear(int purchaseYear) { this.purchaseYear = purchaseYear; }

    public double getBatteryCapacityKwh() { return batteryCapacityKwh; }
    public void setBatteryCapacityKwh(double batteryCapacityKwh) { this.batteryCapacityKwh = batteryCapacityKwh; }

    public String getConnectorType() { return connectorType; }
    public void setConnectorType(String connectorType) { this.connectorType = connectorType; }

    public double getMaxAcKw() { return maxAcKw; }
    public void setMaxAcKw(double maxAcKw) { this.maxAcKw = maxAcKw; }

    public double getMaxDcKw() { return maxDcKw; }
    public void setMaxDcKw(double maxDcKw) { this.maxDcKw = maxDcKw; }

    public double getTypicalEfficiencyKmPerKwh() { return typicalEfficiencyKmPerKwh; }
    public void setTypicalEfficiencyKmPerKwh(double typicalEfficiencyKmPerKwh) { this.typicalEfficiencyKmPerKwh = typicalEfficiencyKmPerKwh; }

    public double getDegradationFactorPercent() { return degradationFactorPercent; }
    public void setDegradationFactorPercent(double degradationFactorPercent) { this.degradationFactorPercent = degradationFactorPercent; }

    public int getMinArrivalSocPercent() { return minArrivalSocPercent; }
    public void setMinArrivalSocPercent(int minArrivalSocPercent) { this.minArrivalSocPercent = minArrivalSocPercent; }

    public int getMaxChargeSocPercent() { return maxChargeSocPercent; }
    public void setMaxChargeSocPercent(int maxChargeSocPercent) { this.maxChargeSocPercent = maxChargeSocPercent; }

    public String getLicensePlate() { return licensePlate; }
    public void setLicensePlate(String licensePlate) { this.licensePlate = licensePlate; }
}
