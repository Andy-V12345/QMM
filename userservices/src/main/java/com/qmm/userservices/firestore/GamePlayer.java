package com.qmm.userservices.firestore;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Embedded in GameSession.players array
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GamePlayer {
    private String uid;                        // String version of Long userId
    private String displayName;                // username from client
}
