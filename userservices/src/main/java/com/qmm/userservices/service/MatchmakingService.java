package com.qmm.userservices.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.qmm.userservices.controller.JoinMatchResponse;
import com.qmm.userservices.controller.MatchStatus;
import com.qmm.userservices.firestore.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import static com.qmm.userservices.firestore.GameStatus.ACTIVE;
import static com.qmm.userservices.firestore.ProgressStatus.PLAYING;
import static com.qmm.userservices.controller.MatchStatus.*;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class MatchmakingService {
    private static final String QUEUES_COLLECTION = "queues";
    private static final String GAMES_COLLECTION = "games";
    private static final String USERS_COLLECTION = "users";
    private static final String DEFAULT_VARIANT = "DEFAULT";
    private static final int SCHEMA_VERSION = 1;

    @Value("${game.countdown.seconds:3}")
    private int countdownSeconds;

    @Autowired
    private Firestore db;

    @Autowired
    private QuestionSetService questionSetService;

    /**
     * Join matchmaking queue. Either enqueues player or matches with waiting player.
     */
    public JoinMatchResponse joinMatch(Long userId, String username) throws ExecutionException, InterruptedException {
        String uid = userId.toString();

        ApiFuture<JoinMatchResponse> future = db.runTransaction(transaction -> {
            Timestamp now = Timestamp.now();

            // Read queue document
            DocumentReference queueRef = db.collection(QUEUES_COLLECTION).document(DEFAULT_VARIANT);
            DocumentSnapshot queueDoc = transaction.get(queueRef).get();

            Queue queue;
            if (!queueDoc.exists()) {
                // Create new queue document
                queue = new Queue(DEFAULT_VARIANT, null, Timestamp.now(), SCHEMA_VERSION);
            } else {
                queue = queueDoc.toObject(Queue.class);
            }

            if (queue == null) {
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Queue object couldn't be created");
            }

            // Check if someone is waiting
            if (queue.getWaitingPlayer() == null) {
                // No one waiting - enqueue this player
                Queue.WaitingPlayer waitingPlayer = new Queue.WaitingPlayer(uid, username, 0, Timestamp.now());
                queue.setWaitingPlayer(waitingPlayer);

                transaction.set(queueRef, queue);

                // Write waiting status for this player
                DocumentReference matchStatusRef = db.collection(USERS_COLLECTION)
                        .document(uid)
                        .collection("matchStatus")
                        .document("current");
                UserMatchStatus waitingStatus = new UserMatchStatus(null, false, now);
                transaction.set(matchStatusRef, waitingStatus);

                // Return waiting response
                JoinMatchResponse response = new JoinMatchResponse();
                response.setStatus(WAITING);
                response.setVariant(DEFAULT_VARIANT);
                response.setQueuePosition(1);
                return response;

            } else {
                // Someone is waiting - match them
                String opponentUid = queue.getWaitingPlayer().getUid();
                String opponentUsername = queue.getWaitingPlayer().getUsername();

                // Don't match with yourself
                if (opponentUid.equals(uid)) {
                    JoinMatchResponse response = new JoinMatchResponse();
                    response.setStatus(WAITING);
                    response.setVariant(DEFAULT_VARIANT);
                    response.setQueuePosition(1);
                    return response;
                }

                // Create game session
                DocumentReference gameRef = db.collection(GAMES_COLLECTION).document();
                Timestamp startAt = Timestamp.ofTimeSecondsAndNanos(
                    now.getSeconds() + countdownSeconds,
                    now.getNanos()
                );
                GameSession gameSession = new GameSession();
                gameSession.setId(gameRef.getId());
                gameSession.setQuestionSet(questionSetService.generateQuestionSet());
                gameSession.setMode("MIXED");
                gameSession.setDifficulty("MEDIUM");

                // Players array - opponent first (index 0), current player second (index 1)
                List<GamePlayer> players = new ArrayList<>();
                players.add(new GamePlayer(opponentUid, opponentUsername));  // p1
                players.add(new GamePlayer(uid, username));                  // p2
                gameSession.setPlayers(players);
                gameSession.setStartAt(startAt);
                gameSession.setCreatedAt(now);
                gameSession.setSchemaVersion(SCHEMA_VERSION);
                gameSession.setState(ACTIVE);

                // Initialize postgame
                GamePostgame postgame = new GamePostgame(true, null);
                gameSession.setPostgame(postgame);

                transaction.set(gameRef, gameSession);

                // Create progress documents for both players
                DocumentReference p1ProgressRef = gameRef.collection("progress").document(opponentUid);
                PlayerProgress p1Progress = new PlayerProgress(0, PLAYING, null, null, null);
                transaction.set(p1ProgressRef, p1Progress);

                DocumentReference p2ProgressRef = gameRef.collection("progress").document(uid);
                PlayerProgress p2Progress = new PlayerProgress(0, PLAYING, null, null, null);
                transaction.set(p2ProgressRef, p2Progress);

                // Clear queue
                queue.setWaitingPlayer(null);
                transaction.set(queueRef, queue);

                // Write match notifications for both players
                DocumentReference player1MatchStatusRef = db.collection(USERS_COLLECTION)
                        .document(opponentUid)
                        .collection("matchStatus")
                        .document("current");
                UserMatchStatus player1MatchStatus = new UserMatchStatus(gameRef.getId(), true, now);
                transaction.set(player1MatchStatusRef, player1MatchStatus);

                DocumentReference player2MatchStatusRef = db.collection(USERS_COLLECTION)
                        .document(uid)
                        .collection("matchStatus")
                        .document("current");
                UserMatchStatus player2MatchStatus = new UserMatchStatus(gameRef.getId(), true, now);
                transaction.set(player2MatchStatusRef, player2MatchStatus);

                // Return matched response
                JoinMatchResponse response = new JoinMatchResponse();
                response.setStatus(MATCHED);
                response.setGameId(gameRef.getId());
                response.setStartAt(startAt);
                return response;
            }
        });

        return future.get();
    }

    /**
     * Leave matchmaking queue.
     */
    public boolean leaveMatchmaking(Long userId) throws ExecutionException, InterruptedException {
        String uid = userId.toString();

        ApiFuture<Boolean> future = db.runTransaction(transaction -> {
            DocumentReference queueRef = db.collection(QUEUES_COLLECTION).document(DEFAULT_VARIANT);
            DocumentSnapshot queueDoc = transaction.get(queueRef).get();

            if (!queueDoc.exists()) {
                return true;  // No queue, nothing to leave
            }

            Queue queue = queueDoc.toObject(Queue.class);

            if (queue == null) {
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Queue object couldn't be created");
            }

            // Clear waitingPlayer if it matches this user
            if (queue.getWaitingPlayer() != null &&
                queue.getWaitingPlayer().getUid().equals(uid)) {
                queue.setWaitingPlayer(null);
                transaction.set(queueRef, queue);
            }

            // Clear user's match status
            DocumentReference matchStatusRef = db.collection(USERS_COLLECTION)
                    .document(uid)
                    .collection("matchStatus")
                    .document("current");
            transaction.delete(matchStatusRef);

            return true;
        });

        return future.get();
    }

    /**
     * Create a game with a bot opponent.
     * Used when matchmaking times out after 20 seconds.
     */
    public JoinMatchResponse playBot(Long userId, String username) throws ExecutionException, InterruptedException {
        String uid = userId.toString();
        String botUid = "bot_" + java.util.UUID.randomUUID().toString();
        String botName = generateBotName();

        ApiFuture<JoinMatchResponse> future = db.runTransaction(transaction -> {
            // Remove from queue if still waiting
            DocumentReference queueRef = db.collection(QUEUES_COLLECTION).document(DEFAULT_VARIANT);
            DocumentSnapshot queueDoc = transaction.get(queueRef).get();
            if (queueDoc.exists()) {
                Queue queue = queueDoc.toObject(Queue.class);
                if (queue != null && queue.getWaitingPlayer() != null &&
                    queue.getWaitingPlayer().getUid().equals(uid)) {
                    queue.setWaitingPlayer(null);
                    transaction.set(queueRef, queue);
                }
            }

            // Create game with bot
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

            // Players array - player first (index 0), bot second (index 1)
            List<GamePlayer> players = new ArrayList<>();
            players.add(new GamePlayer(uid, username));
            players.add(new GamePlayer(botUid, botName));
            gameSession.setPlayers(players);

            gameSession.setStartAt(startAt);
            gameSession.setCreatedAt(now);
            gameSession.setSchemaVersion(SCHEMA_VERSION);
            gameSession.setState(ACTIVE);

            // Initialize postgame
            GamePostgame postgame = new GamePostgame(true, null);
            gameSession.setPostgame(postgame);

            transaction.set(gameRef, gameSession);

            // Create progress documents for both player and bot
            DocumentReference playerProgressRef = gameRef.collection("progress").document(uid);
            PlayerProgress playerProgress = new PlayerProgress(0, PLAYING, null, null, null);
            transaction.set(playerProgressRef, playerProgress);

            DocumentReference botProgressRef = gameRef.collection("progress").document(botUid);
            PlayerProgress botProgress = new PlayerProgress(0, PLAYING, null, null, null);
            transaction.set(botProgressRef, botProgress);

            // Write match notification for player
            DocumentReference matchStatusRef = db.collection(USERS_COLLECTION)
                    .document(uid)
                    .collection("matchStatus")
                    .document("current");
            UserMatchStatus matchStatus = new UserMatchStatus(gameRef.getId(), true, now);
            transaction.set(matchStatusRef, matchStatus);

            // Return matched response
            JoinMatchResponse response = new JoinMatchResponse();
            response.setStatus(MATCHED);
            response.setGameId(gameRef.getId());
            response.setStartAt(startAt);
            return response;
        });

        return future.get();
    }

    /**
     * Generate a random bot name.
     */
    private String generateBotName() {
        String[] prefixes = {"Math", "Quick", "Speed", "Brain", "Clever", "Smart", "Number", "Calc"};
        String[] suffixes = {"Whiz", "Master", "Ninja", "Wizard", "Pro", "Genius", "Expert", "Champion"};

        String prefix = prefixes[new java.util.Random().nextInt(prefixes.length)];
        String suffix = suffixes[new java.util.Random().nextInt(suffixes.length)];
        int number = new java.util.Random().nextInt(100);

        return prefix + suffix + number;
    }
}
