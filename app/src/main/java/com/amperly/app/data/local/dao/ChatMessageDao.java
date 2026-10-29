package com.amperly.app.data.local.dao;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import androidx.room.Update;

import com.amperly.app.data.local.entity.ChatMessage;

import java.util.List;

@Dao
public interface ChatMessageDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insert(ChatMessage message);

    @Update
    void update(ChatMessage message);

    @Query("SELECT * FROM chat_messages WHERE threadId = :threadId ORDER BY createdAtMs")
    LiveData<List<ChatMessage>> getMessagesForThread(String threadId);

    @Query("SELECT * FROM chat_messages WHERE threadId = :threadId ORDER BY createdAtMs")
    List<ChatMessage> getMessagesForThreadSync(String threadId);

    @Query("SELECT * FROM chat_messages WHERE reservationId = :reservationId ORDER BY createdAtMs")
    List<ChatMessage> getMessagesForReservationSync(String reservationId);

    @Query("SELECT * FROM chat_messages ORDER BY createdAtMs DESC")
    List<ChatMessage> getAllMessagesSync();

    /** Used by sync to re-read a message after the reported flag changes. */
    @Query("SELECT * FROM chat_messages WHERE id = :id")
    ChatMessage getMessageByIdSync(String id);

    @Query("UPDATE chat_messages SET isReported = 1 WHERE id = :messageId")
    void markReported(String messageId);

    /**
     * Moves the messages of one thread into another.
     *
     * <p>Used once, when threads created per reservation are folded into the single thread a
     * consumer and host share, so the history stays readable and in order.
     */
    @Query("UPDATE chat_messages SET threadId = :threadId WHERE threadId = :oldThreadId")
    void reassignThread(String oldThreadId, String threadId);

    @Query("DELETE FROM chat_messages WHERE expiresAtMs > 0 AND expiresAtMs < :nowMs")
    int purgeExpired(long nowMs);
}
