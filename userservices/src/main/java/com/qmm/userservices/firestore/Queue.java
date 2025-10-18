package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Represents a matchmaking queue document stored in /queues/{variant}
 * Using single queue "DEFAULT" since no mode-based matchmaking yet
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Queue {
    private String variant;                    // "DEFAULT" for now
    private WaitingPlayer waitingPlayer;       // null if no one waiting
    private Timestamp createdAt;
    private Integer schemaVersion;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class WaitingPlayer {
        private String uid;                    // String version of Long userId
        private String username;               // Player's display name
        private Integer rating;                // optional, default 0
        private Timestamp joinedAt;
    }
}
