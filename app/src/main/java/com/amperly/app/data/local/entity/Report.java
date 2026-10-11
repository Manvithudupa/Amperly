package com.amperly.app.data.local.entity;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "reports")
public class Report {
    @PrimaryKey
    @NonNull
    private String id;
    private String reporterId;
    private String targetStationId;
    private String targetHostId;
    private String reportType;
    private String description;
    private long createdAtMs;

    public Report(@NonNull String id, String reporterId, String targetStationId,
                  String targetHostId, String reportType, String description, long createdAtMs) {
        this.id = id;
        this.reporterId = reporterId;
        this.targetStationId = targetStationId;
        this.targetHostId = targetHostId;
        this.reportType = reportType;
        this.description = description;
        this.createdAtMs = createdAtMs;
    }

    @NonNull
    public String getId() { return id; }
    public void setId(@NonNull String id) { this.id = id; }

    public String getReporterId() { return reporterId; }
    public void setReporterId(String reporterId) { this.reporterId = reporterId; }

    public String getTargetStationId() { return targetStationId; }
    public void setTargetStationId(String targetStationId) { this.targetStationId = targetStationId; }

    public String getTargetHostId() { return targetHostId; }
    public void setTargetHostId(String targetHostId) { this.targetHostId = targetHostId; }

    public String getReportType() { return reportType; }
    public void setReportType(String reportType) { this.reportType = reportType; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public long getCreatedAtMs() { return createdAtMs; }
    public void setCreatedAtMs(long createdAtMs) { this.createdAtMs = createdAtMs; }
}
