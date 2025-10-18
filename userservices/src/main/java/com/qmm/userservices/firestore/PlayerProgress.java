package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Represents a player's progress document stored in /games/{gameId}/progress/{uid}
 * Tracks individual player completion and timing
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PlayerProgress {
    private Integer completed;                 // 0..25
    private ProgressStatus status;             // PLAYING, FINISHED, FORFEIT, POSTGAME
    private Timestamp lastAnswerAt;
    private Timestamp finishedAt;
    private Long elapsedMs;                    // (serverNow - startAt) when finished
}
