package com.qmm.userservices.controller;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class JoinMatchResponse {
    private MatchStatus status;         // WAITING or MATCHED
    private String variant;             // "DEFAULT" (for waiting response)
    private Integer queuePosition;      // 1 (for waiting response)
    private String gameId;              // present when matched
    private Timestamp startAt;          // present when matched
}
