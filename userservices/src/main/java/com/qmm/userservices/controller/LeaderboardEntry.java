package com.qmm.userservices.controller;

import com.qmm.userservices.domain.AppUser;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class LeaderboardEntry {
    private Long ttHighScore;
    private String username;
}
