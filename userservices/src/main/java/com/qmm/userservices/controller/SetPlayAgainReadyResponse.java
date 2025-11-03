package com.qmm.userservices.controller;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Map;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SetPlayAgainReadyResponse {
    private String gameId;
    private Map<String, Boolean> playAgainReady;  // Map of player uid -> ready status
    private Boolean gameReset;  // true if all players were ready and game was reset
}
