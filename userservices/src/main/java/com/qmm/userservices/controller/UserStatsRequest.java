package com.qmm.userservices.controller;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UserStatsRequest {
    private Long additionScore;

    private Long additionTot;

    private Long subtractionScore;

    private Long subtractionTot;

    private Long multiplicationScore;

    private Long multiplicationTot;

    private Long divisionScore;

    private Long divisionTot;

    private Long highScore;

    private Long ttHighScore;
}
