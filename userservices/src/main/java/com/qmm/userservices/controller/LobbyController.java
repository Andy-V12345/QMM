package com.qmm.userservices.controller;

import com.qmm.userservices.service.LobbyService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/v1/lobbies")
@RequiredArgsConstructor
public class LobbyController {
    private final LobbyService lobbyService;

    /**
     * POST /api/v1/lobbies/create
     * Create a new private lobby with invite code
     */
    @PostMapping("/create")
    public ResponseEntity<?> createLobby(@RequestBody CreateLobbyRequest request) {
        try {
            LobbyResponse response = lobbyService.createLobby(
                    request.getUserId(),
                    request.getUsername()
            );
            return ResponseEntity.ok(response);

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to create lobby: " + e.getMessage());

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
     * POST /api/v1/lobbies/{code}/join
     * Join a lobby by invite code
     */
    @PostMapping("/{code}/join")
    public ResponseEntity<?> joinLobby(@PathVariable String code, @RequestBody JoinLobbyRequest request) {
        try {
            LobbyResponse response = lobbyService.joinLobby(
                    code,
                    request.getUserId(),
                    request.getUsername()
            );
            return ResponseEntity.ok(response);

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to join lobby: " + e.getMessage());

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
     * POST /api/v1/lobbies/{lobbyId}/start
     * Start the game (host only)
     */
    @PostMapping("/{lobbyId}/start")
    public ResponseEntity<?> startGame(@PathVariable String lobbyId, @RequestBody StartGameRequest request) {
        try {
            StartGameResponse response = lobbyService.startGame(
                    lobbyId,
                    request.getHostUid()
            );
            return ResponseEntity.ok(response);

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to start game: " + e.getMessage());

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
     * DELETE /api/v1/lobbies/{lobbyId}
     * Cancel the lobby (host or guest)
     */
    @DeleteMapping("/{lobbyId}")
    public ResponseEntity<?> cancelLobby(@PathVariable String lobbyId, @RequestBody CancelLobbyRequest request) {
        try {
            lobbyService.cancelLobby(lobbyId, request.getUserId());
            return ResponseEntity.ok().build();

        } catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Failed to cancel lobby: " + e.getMessage());

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
