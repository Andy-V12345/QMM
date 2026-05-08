package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentReference;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;
import java.util.Map;

/**
 * Top-level document stored in the "games" collection.
 * New spec: stores meta info and references questionSet, with result/postgame fields
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GameSession {
    // Meta
    private String id;
    private String mode;                       // "MIXED" for random operations
    private String difficulty;                 // "MEDIUM" by default
    private List<GamePlayer> players;          // array of 2 players
    private QuestionSet questionSet;           // question set
    private Timestamp startAt;                 // countdown time (now + 3 seconds)
    private Timestamp createdAt;
    private Integer schemaVersion;
    private String lobbyId;                    // Lobby ID if game was created from custom lobby (null for matchmaking)

    public Integer getTargetCount() {
        return this.questionSet.getTargetCount();
    }

    // State
    private GameStatus state;                  // WAITING, READY, ACTIVE, FINISHED, CANCELLED

    // Result (set when winner is declared)
    private GameResult result;

    // Play again tracking for custom lobby games
    // Map of player uid -> ready status (true = wants to play again)
    private Map<String, Boolean> playAgainReady;

    // Postgame policy
    private GamePostgame postgame;
}
