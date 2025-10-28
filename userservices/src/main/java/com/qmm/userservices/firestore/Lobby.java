package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

/**
 * Represents a private lobby for multiplayer matches.
 * Stored in the "lobbies" Firestore collection.
 * Supports 2+ players for future extensibility.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Lobby {
    private String id;                  // Firestore document ID
    private String code;                // 6-character invite code (e.g., "A3X7K9")
    private List<LobbyPlayer> players;  // List of players in the lobby
    private String hostUid;             // Host user ID (who can start the game)
    private Integer minPlayers;         // Minimum players required to start (default: 2)
    private Integer maxPlayers;         // Maximum players allowed (default: 2)
    private LobbyState state;           // Current lobby state
    private String gameId;              // Created game ID (null until started)
    private Timestamp createdAt;        // Lobby creation timestamp
}
