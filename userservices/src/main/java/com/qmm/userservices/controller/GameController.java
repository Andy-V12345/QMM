package com.qmm.userservices.controller;

import com.qmm.userservices.service.GameService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/v1/games")
@RequiredArgsConstructor
public class GameController {
    private final GameService gameService;

    /**
     * POST /api/v1/games/{gameId}/submit
     * Submit an answer for validation
     */
    @PostMapping("/{gameId}/submit")
    public ResponseEntity<?> submitAnswer(
            @PathVariable String gameId,
            @RequestBody SubmitAnswerRequest request) {
        try {
            SubmitAnswerResponse response = gameService.submitAnswer(
                    gameId,
                    request.getUserId(),
                    request.getQIndex(),
                    request.getAnswer(),
                    request.getClientSentAt()
            );
            return ResponseEntity.ok(response);

        } catch (ResponseStatusException e) {
            // Pass through HTTP status exceptions from service
            return ResponseEntity.status(e.getStatusCode()).body(e.getReason());

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to submit answer: " + e.getMessage());

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            System.err.println("Thread interrupted: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body("Service interrupted");

        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Unexpected error: " + e.getMessage());
        }
    }

    /**
     * POST /api/v1/games/{gameId}/presence
     * Update player presence
     */
    @PostMapping("/{gameId}/presence")
    public ResponseEntity<?> updatePresence(
            @PathVariable String gameId,
            @RequestBody PresenceRequest request) {
        try {
            boolean success = gameService.updatePresence(
                    gameId,
                    request.getUserId(),
                    request.getConnection().toString()
            );
            PresenceResponse response = new PresenceResponse(success);
            return ResponseEntity.ok(response);

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to update presence: " + e.getMessage());

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
     * POST /api/v1/games/{gameId}/forfeit
     * Forfeit the game
     */
    @PostMapping("/{gameId}/forfeit")
    public ResponseEntity<?> forfeit(
            @PathVariable String gameId,
            @RequestBody ForfeitRequest request) {
        try {
            boolean success = gameService.forfeit(gameId, request.getUserId());
            ForfeitResponse response = new ForfeitResponse(success);
            return ResponseEntity.ok(response);

        } catch (ResponseStatusException e) {
            return ResponseEntity.status(e.getStatusCode()).body(e.getReason());

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to forfeit: " + e.getMessage());

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
