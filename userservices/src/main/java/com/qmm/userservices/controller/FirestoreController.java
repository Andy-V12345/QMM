package com.qmm.userservices.controller;

import com.qmm.userservices.service.FirestoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeoutException;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class FirestoreController {
    private final FirestoreService firestoreService;

    @PostMapping("/games")
    public ResponseEntity<String> findGame(@RequestBody FindGameRequest findGameRequest) {
        try {
            String game_id = firestoreService.findGame(findGameRequest.getUser_id(), findGameRequest.getUsername());
            return ResponseEntity.ok(game_id);
        }
        catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
        catch (InterruptedException e) {
            // Preserve interrupt flag and return 503 Service Unavailable
            Thread.currentThread().interrupt();
            System.err.println("Thread interrupted: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @PutMapping("/games")
    public ResponseEntity<?> joinGame(@RequestBody JoinGameRequest joinGameRequest) {
        try {
            HttpStatus response = firestoreService.joinGame(joinGameRequest.getSession_id(), joinGameRequest.getUser_id());
            return new ResponseEntity<>(response);
        }
        catch (IllegalStateException e) {
            System.err.println("Bad request: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
        catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
        catch (InterruptedException e) {
            // Preserve interrupt flag and return 503 Service Unavailable
            Thread.currentThread().interrupt();
            System.err.println("Thread interrupted: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @PutMapping("/games/players")
    public ResponseEntity<?> updatePlayer(@RequestBody UpdatePlayerRequest updatePlayerRequest) {
        try {
            HttpStatus response = firestoreService.updatePlayer(
                    updatePlayerRequest.getUpdated_status(),
                    updatePlayerRequest.getNum_completed(),
                    updatePlayerRequest.getUser_id(),
                    updatePlayerRequest.getSession_id()
            );

            return new ResponseEntity<>(response);
        }
        catch (IllegalStateException e) {
            System.err.println("Bad request: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
        catch (ExecutionException e) {
            System.err.println("Firestore error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
        catch (InterruptedException e) {
            // Preserve interrupt flag and return 503 Service Unavailable
            Thread.currentThread().interrupt();
            System.err.println("Thread interrupted: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
}
