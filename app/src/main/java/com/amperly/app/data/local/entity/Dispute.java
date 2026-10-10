package com.amperly.app.data.local.entity;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "disputes")
public class Dispute {
    @PrimaryKey
    @NonNull
    private String id;
    private String sessionId;
    private String consumerId;
    private String hostId;
    private String reason;
    private String consumerNotes;
    private String hostNotes;
    private String status;
    private String enforcementAction;
    private long createdAtMs;

    public Dispute(@NonNull String id, String sessionId, String consumerId, String hostId,
                   String reason, String consumerNotes, String hostNotes, String status,
                   String enforcementAction, long createdAtMs) {
        this.id = id;
        this.sessionId = sessionId;
        this.consumerId = consumerId;
        this.hostId = hostId;
        this.reason = reason;
        this.consumerNotes = consumerNotes;
        this.hostNotes = hostNotes;
        this.status = status;
        this.enforcementAction = enforcementAction;
        this.createdAtMs = createdAtMs;
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

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public String getConsumerNotes() { return consumerNotes; }
    public void setConsumerNotes(String consumerNotes) { this.consumerNotes = consumerNotes; }

    public String getHostNotes() { return hostNotes; }
    public void setHostNotes(String hostNotes) { this.hostNotes = hostNotes; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getEnforcementAction() { return enforcementAction; }
    public void setEnforcementAction(String enforcementAction) { this.enforcementAction = enforcementAction; }

    public long getCreatedAtMs() { return createdAtMs; }
    public void setCreatedAtMs(long createdAtMs) { this.createdAtMs = createdAtMs; }
}
