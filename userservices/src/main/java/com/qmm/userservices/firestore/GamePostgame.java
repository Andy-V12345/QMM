package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Embedded in GameSession - postgame policy
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GamePostgame {
    private Boolean acceptingSubmissions;      // true = loser can continue submitting
    private Timestamp lockedAt;                // null = no time limit for now
}
