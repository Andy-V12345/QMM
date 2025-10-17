package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Represents a user's match status document stored in /users/{uid}/matchStatus
 * Used to notify players when a match is found
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserMatchStatus {
    private String gameId;
    private Boolean matched;        // true when matched
    private Timestamp timestamp;
}
