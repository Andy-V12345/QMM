package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Embedded in GameSession - result information set when winner is declared
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GameResult {
    private String winnerUid;                  // uid of winner (String version of Long)
}
