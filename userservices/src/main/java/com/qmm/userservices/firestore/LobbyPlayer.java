package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Represents a player in a lobby.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class LobbyPlayer {
    private String uid;
    private String username;
    private Timestamp joinedAt;
}
