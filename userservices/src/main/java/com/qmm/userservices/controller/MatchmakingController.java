package com.qmm.userservices.controller;

import com.qmm.userservices.service.MatchmakingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/v1/match")
@RequiredArgsConstructor
public class MatchmakingController {
    private final MatchmakingService matchmakingService;

    /**
     * POST /api/match/join
     * Join matchmaking queue
     */
    @PostMapping("/join")
    public ResponseEntity<?> joinMatch(@RequestBody JoinMatchRequest request) {
        try {
            JoinMatchResponse response = matchmakingService.joinMatch(
                    request.getUserId(),
                    request.getUsername()
            );
            return ResponseEntity.ok(response);

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to join matchmaking: " + e.getMessage());

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Thread interrupted: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body("Service interrupted");

        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Unexpected error: " + e.getMessage());
        }
    }

    /**
     * POST /api/match/leave
     * Leave matchmaking queue
     */
    @PostMapping("/leave")
    public ResponseEntity<?> leaveMatch(@RequestBody LeaveMatchRequest request) {
        try {
            boolean success = matchmakingService.leaveMatchmaking(request.getUserId());
            LeaveMatchResponse response = new LeaveMatchResponse(success);
            return ResponseEntity.ok(response);

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to leave matchmaking: " + e.getMessage());

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Thread interrupted: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body("Service interrupted");

        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Unexpected error: " + e.getMessage());
        }
    }

    /**
     * POST /api/v1/match/playBot
     * Create a game with a bot opponent
     */
    @PostMapping("/playBot")
    public ResponseEntity<?> playBot(@RequestBody PlayBotRequest request) {
        try {
            JoinMatchResponse response = matchmakingService.playBot(
                    request.getUserId(),
                    request.getUsername()
            );
            return ResponseEntity.ok(response);

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to create bot game: " + e.getMessage());

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Thread interrupted: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body("Service interrupted");

        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Unexpected error: " + e.getMessage());
        }
    }
}
