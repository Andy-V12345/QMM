package com.qmm.userservices.controller;

import com.qmm.userservices.domain.AppUser;
import com.qmm.userservices.domain.UserStats;
import com.qmm.userservices.service.UserStatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Objects;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class UserStatsController {

    private final UserStatsService userStatsService;

    @GetMapping("/stats/{user_id}")
    public ResponseEntity<?> getStats(@PathVariable("user_id") Long user_id, @AuthenticationPrincipal AppUser user) {
        if (!userStatsService.isCorrectUser(user_id, user)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        UserStats userStats = userStatsService.findByUserId(user_id);
        return ResponseEntity.ok(userStats);
    }

    @GetMapping("/leaderboard/{top_n}")
    public ResponseEntity<List<LeaderboardEntry>> getLeaderboard(@PathVariable("top_n") Integer topN) {
        List<LeaderboardEntry> leaderboard = userStatsService.getLeaderboard(topN);

        return ResponseEntity.ok(leaderboard);
    }

    @PostMapping("/stats/{user_id}")
    public ResponseEntity<?> createStats(@RequestBody UserStatsRequest request, @PathVariable("user_id") Long user_id, @AuthenticationPrincipal AppUser user) {

        if (!userStatsService.isCorrectUser(user_id, user)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        HttpStatus result = userStatsService.addStatsToUser(request, user_id);

        return new ResponseEntity<>(result);
    }

    @PutMapping("/stats/{user_id}/{stat_id}")
    public ResponseEntity<?> updateStats(@RequestBody UserStatsRequest request, @PathVariable("stat_id") Long stat_id, @PathVariable("user_id") Long user_id, @AuthenticationPrincipal AppUser user) {

        if (!userStatsService.isCorrectUser(user_id, user)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        boolean result = userStatsService.updateUserStats(request, stat_id);

        if (result) {
            return new ResponseEntity<>(HttpStatus.CREATED);
        }
        else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }


    @DeleteMapping("/stats/{user_id}/{stat_id}")
    public ResponseEntity<?> deleteStats(@PathVariable("stat_id") Long stat_id, @PathVariable("user_id") Long user_id, @AuthenticationPrincipal AppUser user) {

        if (!userStatsService.isCorrectUser(user_id, user)) {
            return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        }

        boolean result = userStatsService.deleteUserStats(stat_id);

        if (result) {
            return new ResponseEntity<>(HttpStatus.OK);
        }
        else {
            return new ResponseEntity<>(HttpStatus.GONE);
        }
    }
}
