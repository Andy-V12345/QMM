package com.qmm.userservices.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import com.qmm.userservices.firestore.GameSession;
import com.qmm.userservices.firestore.GameStatus;
import com.qmm.userservices.firestore.Player;
import com.qmm.userservices.firestore.PlayerStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Service
public class FirestoreService {
    final private String GAMES_COLLECTION = "games";
    final private String MATCHMAKING_COLLECTION = "matchmaking";

    @Autowired
    private Firestore db;

    public String findGame(Long user_id, String username) throws ExecutionException, InterruptedException {
        Timestamp curTime = Timestamp.now();
        ApiFuture<String> future = db.runTransaction(transaction -> {
            // 1) Read wait list doc
            DocumentReference waitListRef = db.collection(MATCHMAKING_COLLECTION).document("2_players");
            DocumentSnapshot waitListDoc = transaction.get(waitListRef).get();

            if (waitListDoc.exists()) {
                String sessionId = waitListDoc.getString("open_game_session");

                if (sessionId == null) {
                    // 2a) Create a new game
                    DocumentReference newGameRef = db.collection(GAMES_COLLECTION).document();

                    // Build the initial game data
                    GameSession newGame = createNewGameSession(user_id, newGameRef.getId(), username, curTime);

                    // WRITE via transaction
                    transaction.set(newGameRef, newGame);

                    // Update wait list with the new game id
                    transaction.update(waitListRef, "open_game_session", newGameRef.getId());

                    return newGameRef.getId();

                } else {
                    // 2b) Add player to the existing game
                    DocumentReference gameRef = db.collection(GAMES_COLLECTION).document(sessionId);

                    Player player = new Player(user_id, username, PlayerStatus.WAITING);
                    player.setTime_joined(curTime);
                    player.setTime_last_updated(curTime);

                    HashMap<String, Object> updates = new HashMap<>();
                    updates.put("players." + player.getId(), player);
                    updates.put("players_found", FieldValue.increment(1));
                    updates.put("time_last_updated", curTime);

                    transaction.update(gameRef, updates);

                    // Clear wait list (game now taken)
                    transaction.update(waitListRef, "open_game_session", null);

                    return gameRef.getId();
                }

            } else {
                // 3) Waitlist doc doesn't exist: create game + wait list atomically
                DocumentReference newGameRef = db.collection(GAMES_COLLECTION).document();
                GameSession newGame = createNewGameSession(user_id, newGameRef.getId(), username, curTime);

                transaction.set(newGameRef, newGame);

                HashMap<String, Object> waitListData = new HashMap<>();
                waitListData.put("open_game_session", newGameRef.getId());
                transaction.set(waitListRef, waitListData);  // creates the wait list doc

                return newGameRef.getId();
            }
        });

        return future.get();
    }

    public HttpStatus joinGame(String session_id, Long user_id) throws ExecutionException, InterruptedException, IllegalStateException {
        if (session_id == null) {
            throw new IllegalStateException("session_id can't be null");
        }

        if (user_id == null) {
            throw new IllegalStateException("user_id can't be null");
        }

        Timestamp curTime = Timestamp.now();
        ApiFuture<HttpStatus> future = db.runTransaction(tx -> {
            DocumentReference gameRef = db.collection(GAMES_COLLECTION).document(session_id);
            DocumentSnapshot gameDoc = tx.get(gameRef).get();

            if (!gameDoc.exists()) {
                throw new IllegalStateException("Game with id " + session_id + " doesn't exist");
            }

            GameSession gameSessionObj = gameDoc.toObject(GameSession.class);
            if (gameSessionObj == null) {
                throw new IllegalStateException("gameSessionObj is null");
            }

            // Validate that user_id is a player in this session
            if (!gameSessionObj.getPlayers().containsKey(user_id.toString())) {
                throw new IllegalStateException("user_id " + user_id + " is not part of session " + session_id);
            }

            // Return early if player has already joined
            if (gameSessionObj.getPlayers().get(user_id.toString()).getStatus() == PlayerStatus.JOINED) {
                return HttpStatus.OK;
            }

            Integer players_connected = gameSessionObj.getPlayers_connected();

            if (players_connected == 2) {
                throw new IllegalStateException("2 players already connected");
            }

            // Update player status to JOINED
            tx.update(gameRef, "players." + user_id + ".status", PlayerStatus.JOINED);

            // Update game session
            Map<String, Object> updatedMap = new HashMap<>();
            updatedMap.put("players_connected", players_connected + 1);

            if (players_connected == 1) {
                updatedMap.put("status", GameStatus.IN_PROGRESS);
            }

            updatedMap.put("time_last_updated", curTime);

            // Update session
            tx.update(gameRef, updatedMap);
            return HttpStatus.OK;
        });

        return future.get();
    }

    public HttpStatus updatePlayer(PlayerStatus updated_status, Integer num_completed, Long user_id, String session_id) throws ExecutionException, InterruptedException, IllegalStateException {
        if (user_id == null) {
            throw new IllegalStateException("user_id can't be null");
        }

        if (session_id == null) {
            throw new IllegalStateException("session_id can't be null");
        }

        Timestamp curTime = Timestamp.now();
        ApiFuture<HttpStatus> future = db.runTransaction(tx -> {
            DocumentReference gameRef = db.collection(GAMES_COLLECTION).document(session_id);

            // Get  game session itself
            DocumentSnapshot gameDoc = tx.get(gameRef).get();

            if (!gameDoc.exists()) {
                throw new IllegalStateException("Game with id " + session_id + " doesn't exist");
            }

            GameSession gameSessionObj = gameDoc.toObject(GameSession.class);
            if (gameSessionObj == null) {
                throw new IllegalStateException("gameSessionObj is null");
            }

            // Validate that user_id is a player in this session
            if (!gameSessionObj.getPlayers().containsKey(user_id.toString())) {
                throw new IllegalStateException("user_id " + user_id + " is not part of session " + session_id);
            }

            // Validate if updated_status is actually DONE
            if (updated_status == PlayerStatus.DONE && num_completed < gameSessionObj.getNUM_QUESTIONS()) {
                throw new IllegalStateException("num_completed is < " + gameSessionObj.getNUM_QUESTIONS());
            }

            // Update the player info in the game session
            Map<String, Object> gameUpdates = new HashMap<>();
            if (updated_status != null) {
                gameUpdates.put("players." + user_id + ".status", updated_status);
            }

            if (num_completed != null) {
                gameUpdates.put("players." + user_id + ".num_completed", num_completed);
            }

            gameUpdates.put("players." + user_id + ".time_last_updated", curTime);
            tx.update(gameRef, gameUpdates);

            Integer players_connected = gameSessionObj.getPlayers_connected();
            List<Long> rankings = gameSessionObj.getRankings();

            if (updated_status == PlayerStatus.EXITED) {
                players_connected -= 1;

                HashMap<String, Object> updatedGameData = new HashMap<>();
                updatedGameData.put("players_connected", players_connected);
                updatedGameData.put("time_last_updated", curTime);

                if (players_connected == 0) {
                    updatedGameData.put("status", GameStatus.DONE);
                }

                tx.update(gameRef, updatedGameData);
            }
            else if (updated_status == PlayerStatus.DONE) {
                rankings.add(user_id);

                HashMap<String, Object> updatedGameData = new HashMap<>();
                updatedGameData.put("rankings", rankings);
                updatedGameData.put("time_last_updated", curTime);

                if (rankings.size() >= players_connected) {
                    updatedGameData.put("status", GameStatus.DONE);
                }

                tx.update(gameRef, updatedGameData);
            }

            return HttpStatus.OK;
        });

        return future.get();
    }

    private GameSession createNewGameSession(Long user_id, String session_id, String username, Timestamp curTime) {
        int MAX_PLAYERS = 2;
        GameSession newSession = new GameSession(session_id, GameStatus.WAITING, MAX_PLAYERS);
        Player player = new Player(user_id, username, PlayerStatus.WAITING);
        player.setTime_joined(curTime);
        player.setTime_last_updated(curTime);
        newSession.addPlayer(player);

        return newSession;
    }
}
