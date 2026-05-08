package com.qmm.userservices.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.qmm.userservices.controller.LobbyResponse;
import com.qmm.userservices.controller.StartGameResponse;
import com.qmm.userservices.firestore.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ExecutionException;

import static com.qmm.userservices.firestore.GameStatus.ACTIVE;
import static com.qmm.userservices.firestore.LobbyState.*;
import static com.qmm.userservices.firestore.ProgressStatus.PLAYING;

@Service
public class LobbyService {
    private static final String LOBBIES_COLLECTION = "lobbies";
    private static final String GAMES_COLLECTION = "games";
    private static final int SCHEMA_VERSION = 1;
    private static final int CODE_LENGTH = 6;
    private static final int MAX_CODE_GENERATION_ATTEMPTS = 5;
    private static final String CODE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    @Value("${game.countdown.seconds:3}")
    private int countdownSeconds;

    @Autowired
    private Firestore db;

    @Autowired
    private QuestionSetService questionSetService;

    @Autowired
    Environment env;

    /**
     * Create a new private lobby with a unique 6-character code.
     */
    public LobbyResponse createLobby(Long userId, String username) throws ExecutionException, InterruptedException {
        String uid = userId.toString();

        // Generate unique code
        String code = generateUniqueCode();

        ApiFuture<LobbyResponse> future = db.runTransaction(transaction -> {
            Timestamp now = Timestamp.now();

            // Create lobby document
            DocumentReference lobbyRef = db.collection(LOBBIES_COLLECTION).document();
            Lobby lobby = new Lobby();
            lobby.setId(lobbyRef.getId());
            lobby.setCode(code);

            // Initialize players list with host
            List<LobbyPlayer> players = new ArrayList<>();
            players.add(new LobbyPlayer(uid, username, now));
            lobby.setPlayers(players);

            lobby.setHostUid(uid);
            lobby.setMinPlayers(2);  // Minimum 2 players to start
            lobby.setMaxPlayers(2);  // Maximum 2 players (1v1)
            lobby.setState(WAITING);
            lobby.setGameId(null);
            lobby.setCreatedAt(now);

            transaction.set(lobbyRef, lobby);

            // Return response
            return toLobbyResponse(lobby);
        });

        return future.get();
    }

    /**
     * Join a lobby by invite code.
     */
    public LobbyResponse joinLobby(String code, Long userId, String username) throws ExecutionException, InterruptedException {
        String uid = userId.toString();

        ApiFuture<LobbyResponse> future = db.runTransaction(transaction -> {
            // Find lobby by code (allow joining WAITING or READY lobbies)
            Query query = db.collection(LOBBIES_COLLECTION)
                    .whereEqualTo("code", code.toUpperCase())
                    .whereIn("state", Arrays.asList("WAITING", "READY"));

            ApiFuture<QuerySnapshot> queryFuture = query.get();
            QuerySnapshot querySnapshot = queryFuture.get();

            if (querySnapshot.isEmpty()) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Lobby not found or already started");
            }

            DocumentSnapshot lobbyDoc = querySnapshot.getDocuments().get(0);
            Lobby lobby = lobbyDoc.toObject(Lobby.class);

            if (lobby == null || lobby.getPlayers() == null) {
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to load lobby");
            }

            // Check if player is already in the lobby
            boolean alreadyInLobby = lobby.getPlayers().stream()
                    .anyMatch(player -> player.getUid().equals(uid));

            if (alreadyInLobby) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Already in this lobby");
            }

            // Check if lobby is full
            if (lobby.getPlayers().size() >= lobby.getMaxPlayers()) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Lobby is already full");
            }

            // Add new player to lobby
            Timestamp now = Timestamp.now();
            lobby.getPlayers().add(new LobbyPlayer(uid, username, now));

            // Update state to READY if minimum players reached
            if (lobby.getPlayers().size() >= lobby.getMinPlayers()) {
                lobby.setState(READY);
            }

            DocumentReference lobbyRef = db.collection(LOBBIES_COLLECTION).document(lobby.getId());
            transaction.set(lobbyRef, lobby);

            return toLobbyResponse(lobby);
        });

        return future.get();
    }

    /**
     * Start the game (host only).
     */
    public StartGameResponse startGame(String lobbyId, String hostUid) throws ExecutionException, InterruptedException {
        ApiFuture<StartGameResponse> future = db.runTransaction(transaction -> {
            // Load lobby
            DocumentReference lobbyRef = db.collection(LOBBIES_COLLECTION).document(lobbyId);
            DocumentSnapshot lobbyDoc = transaction.get(lobbyRef).get();

            if (!lobbyDoc.exists()) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Lobby not found");
            }

            Lobby lobby = lobbyDoc.toObject(Lobby.class);

            if (lobby == null || lobby.getPlayers() == null) {
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to load lobby");
            }

            // Validate host
            if (!lobby.getHostUid().equals(hostUid)) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the host can start the game");
            }

            // Validate state
            if (lobby.getState() != READY) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Lobby is not ready to start");
            }

            // Validate player count
            if (lobby.getPlayers().size() < lobby.getMinPlayers()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Not enough players. Need at least " + lobby.getMinPlayers());
            }

            if (lobby.getPlayers().size() > lobby.getMaxPlayers()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Too many players in lobby");
            }

            // Get NUM_QUESTIONS from environment
            String num_questions = env.getProperty("NUM_QUESTIONS");
            int TARGET_COUNT = num_questions == null ? 25 : Integer.parseInt(num_questions);

            // Create game session
            DocumentReference gameRef = db.collection(GAMES_COLLECTION).document();
            Timestamp now = Timestamp.now();
            Timestamp startAt = Timestamp.ofTimeSecondsAndNanos(
                now.getSeconds() + countdownSeconds,
                now.getNanos()
            );

            GameSession gameSession = new GameSession();
            gameSession.setId(gameRef.getId());
            gameSession.setQuestionSet(questionSetService.generateQuestionSet());
            gameSession.setMode("MIXED");
            gameSession.setDifficulty("MEDIUM");

            // Build players array from lobby players
            List<GamePlayer> players = new ArrayList<>();
            for (LobbyPlayer lobbyPlayer : lobby.getPlayers()) {
                players.add(new GamePlayer(lobbyPlayer.getUid(), lobbyPlayer.getUsername()));
            }
            gameSession.setPlayers(players);

            gameSession.setStartAt(startAt);
            gameSession.setCreatedAt(now);
            gameSession.setSchemaVersion(SCHEMA_VERSION);
            gameSession.setState(ACTIVE);
            gameSession.setLobbyId(lobbyId);  // Link to lobby for custom lobby games

            // Initialize postgame
            GamePostgame postgame = new GamePostgame(true, null);
            gameSession.setPostgame(postgame);

            transaction.set(gameRef, gameSession);

            // Create progress documents for all players
            for (LobbyPlayer lobbyPlayer : lobby.getPlayers()) {
                DocumentReference progressRef = gameRef.collection("progress").document(lobbyPlayer.getUid());
                PlayerProgress progress = new PlayerProgress(0, PLAYING, null, null, null);
                transaction.set(progressRef, progress);
            }

            // Update lobby
            lobby.setState(STARTED);
            lobby.setGameId(gameRef.getId());
            transaction.set(lobbyRef, lobby);

            // Return response
            StartGameResponse response = new StartGameResponse();
            response.setGameId(gameRef.getId());
            response.setStartAt(startAt);
            return response;
        });

        return future.get();
    }

    /**
     * Leave the lobby. If host leaves or all players leave, lobby is cancelled.
     */
    public LobbyResponse leaveLobby(String lobbyId, Long userId) throws ExecutionException, InterruptedException {
        String uid = userId.toString();

        ApiFuture<LobbyResponse> future = db.runTransaction(transaction -> {
            DocumentReference lobbyRef = db.collection(LOBBIES_COLLECTION).document(lobbyId);
            DocumentSnapshot lobbyDoc = transaction.get(lobbyRef).get();

            if (!lobbyDoc.exists()) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Lobby not found");
            }

            Lobby lobby = lobbyDoc.toObject(Lobby.class);

            if (lobby == null || lobby.getPlayers() == null) {
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to load lobby");
            }

            // Validate lobby state - cannot leave after game has started
            if (lobby.getState() == STARTED) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    "Cannot leave lobby after game has started");
            }

            // Validate user is in the lobby
            boolean isInLobby = lobby.getPlayers().stream()
                    .anyMatch(player -> player.getUid().equals(uid));

            if (!isInLobby) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found in this lobby");
            }

            // Check if leaving player is host
            boolean isHost = lobby.getHostUid().equals(uid);

            // Remove player from lobby
            lobby.getPlayers().removeIf(player -> player.getUid().equals(uid));

            // If host leaves or no players remain, cancel the lobby
            if (isHost || lobby.getPlayers().isEmpty()) {
                lobby.setState(CANCELLED);
            } else {
                // If players count falls below minimum, set state back to WAITING
                if (lobby.getPlayers().size() < lobby.getMinPlayers()) {
                    lobby.setState(WAITING);
                }
            }

            transaction.set(lobbyRef, lobby);

            return toLobbyResponse(lobby);
        });

        return future.get();
    }

    /**
     * Cancel the lobby (any player can cancel).
     */
    public void cancelLobby(String lobbyId, Long userId) throws ExecutionException, InterruptedException {
        String uid = userId.toString();

        ApiFuture<Void> future = db.runTransaction(transaction -> {
            DocumentReference lobbyRef = db.collection(LOBBIES_COLLECTION).document(lobbyId);
            DocumentSnapshot lobbyDoc = transaction.get(lobbyRef).get();

            if (!lobbyDoc.exists()) {
                throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Lobby not found");
            }

            Lobby lobby = lobbyDoc.toObject(Lobby.class);

            if (lobby == null || lobby.getPlayers() == null) {
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to load lobby");
            }

            // Validate user is in the lobby
            boolean isInLobby = lobby.getPlayers().stream()
                    .anyMatch(player -> player.getUid().equals(uid));

            if (!isInLobby) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized to cancel this lobby");
            }

            // Update state to cancelled
            lobby.setState(CANCELLED);
            transaction.set(lobbyRef, lobby);

            return null;
        });

        future.get();
    }

    /**
     * Generate a unique 6-character alphanumeric code.
     */
    private String generateUniqueCode() throws ExecutionException, InterruptedException {
        Random random = new Random();

        for (int attempt = 0; attempt < MAX_CODE_GENERATION_ATTEMPTS; attempt++) {
            StringBuilder code = new StringBuilder(CODE_LENGTH);
            for (int i = 0; i < CODE_LENGTH; i++) {
                code.append(CODE_CHARACTERS.charAt(random.nextInt(CODE_CHARACTERS.length())));
            }

            String generatedCode = code.toString();

            // Check if code is unique (not in use by active lobbies)
            Query query = db.collection(LOBBIES_COLLECTION)
                    .whereEqualTo("code", generatedCode)
                    .whereNotEqualTo("state", "CANCELLED");

            QuerySnapshot snapshot = query.get().get();

            if (snapshot.isEmpty()) {
                return generatedCode;
            }
        }

        throw new ResponseStatusException(
            HttpStatus.INTERNAL_SERVER_ERROR,
            "Failed to generate unique lobby code after " + MAX_CODE_GENERATION_ATTEMPTS + " attempts"
        );
    }

    /**
     * Convert Lobby to LobbyResponse.
     */
    private LobbyResponse toLobbyResponse(Lobby lobby) {
        LobbyResponse response = new LobbyResponse();
        response.setLobbyId(lobby.getId());
        response.setCode(lobby.getCode());
        response.setPlayers(lobby.getPlayers());
        response.setHostUid(lobby.getHostUid());
        response.setMinPlayers(lobby.getMinPlayers());
        response.setMaxPlayers(lobby.getMaxPlayers());
        response.setState(lobby.getState());
        response.setGameId(lobby.getGameId());
        response.setCreatedAt(lobby.getCreatedAt());
        return response;
    }
}
