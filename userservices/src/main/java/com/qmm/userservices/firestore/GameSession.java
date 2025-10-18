package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentReference;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

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

    public Integer getTargetCount() {
        return this.questionSet.getTargetCount();
    }

    // State
    private GameStatus state;                  // WAITING, READY, ACTIVE, FINISHED, CANCELLED

    // Result (set when winner is declared)
    private GameResult result;

    // Postgame policy
    private GamePostgame postgame;
}
