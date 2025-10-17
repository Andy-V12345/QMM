package com.qmm.userservices.service;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.DocumentSnapshot;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.SetOptions;
import com.qmm.userservices.controller.SubmitAnswerResponse;
import com.qmm.userservices.firestore.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import static com.qmm.userservices.firestore.DecidedBy.*;
import static com.qmm.userservices.firestore.GameStatus.*;
import static com.qmm.userservices.firestore.ProgressStatus.*;

import java.util.concurrent.ExecutionException;

@Service
public class GameService {
    private static final String GAMES_COLLECTION = "games";

    @Autowired
    private Firestore db;

    @Autowired
    private QuestionSetService questionSetService;

    /**
     * Submit an answer with server-authoritative validation.
     * Handles winner determination and postgame submissions.
     */
    public SubmitAnswerResponse submitAnswer(String gameId, String uid, Integer qIndex, Integer answer, Long clientSentAt)
            throws ExecutionException, InterruptedException {

        // 1. Read game session
        DocumentReference gameRef = db.collection(GAMES_COLLECTION).document(gameId);
        DocumentSnapshot gameDoc = gameRef.get().get();

        if (!gameDoc.exists()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Game not found");
        }

        GameSession game = gameDoc.toObject(GameSession.class);

        if (game == null) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Game object couldn't be created");
        }

        // 2. Validate player is in this game
        boolean isPlayer = game.getPlayers().stream().anyMatch(p -> p.getUid().equals(uid));
        if (!isPlayer) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not a player in this game");
        }

        // 3. Read user's progress
        DocumentReference myProgressRef = gameRef.collection("progress").document(uid);
        DocumentSnapshot myProgressDoc = myProgressRef.get().get();
        PlayerProgress myProgress = myProgressDoc.toObject(PlayerProgress.class);

        if (myProgress == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Player progress not found");
        }

        // 5. Validate sequence (qIndex must equal completed)
        if (!qIndex.equals(myProgress.getCompleted())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT,
                    "Out of order submission. Expected qIndex=" + myProgress.getCompleted());
        }

        // 6. Validate answer correctness
        boolean correct = questionSetService.validateAnswer(game.getQuestionSet(), qIndex, answer);
        if (!correct) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Incorrect answer");
        }

        Timestamp now = Timestamp.now();

        // 7. Determine if this submission finishes the player
        boolean finishing = (myProgress.getCompleted() + 1) == game.getTargetCount();

        if (!finishing) {
            // Not finishing - just update progress
            myProgress.setCompleted(myProgress.getCompleted() + 1);
            myProgress.setLastAnswerAt(now);
            myProgressRef.set(myProgress);

            // Return response
            SubmitAnswerResponse response = new SubmitAnswerResponse();
            response.setCompleted(myProgress.getCompleted());
            return response;
        }
        else {
            // This player is finishing
            long myElapsedMs = (now.toSqlTimestamp().getTime() - game.getStartAt().toSqlTimestamp().getTime());

            myProgress.setCompleted(game.getTargetCount());
            myProgress.setStatus(ProgressStatus.FINISHED);
            myProgress.setElapsedMs(myElapsedMs);
            myProgress.setFinishedAt(now);
            myProgressRef.set(myProgress);

            ApiFuture<Integer> future = db.runTransaction((transaction -> {
                // Re-read game to check current state
                DocumentSnapshot reReadGameDoc = transaction.get(gameRef).get();
                GameSession reReadGame = reReadGameDoc.toObject(GameSession.class);

                if (reReadGame == null) {
                    throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Game object couldn't be created");
                }

                if (reReadGame.getState() == ACTIVE) {
                    // Case A: Game is still active - this player wins

                    GameResult result = new GameResult(uid);

                    reReadGame.setState(GameStatus.FINISHED);
                    reReadGame.setResult(result);
                    transaction.set(gameRef, reReadGame, SetOptions.merge());
                }

                return 0;
            }));

            future.get();

            // Return response
            SubmitAnswerResponse response = new SubmitAnswerResponse();
            response.setCompleted(myProgress.getCompleted());
            return response;
        }
    }

    /**
     * Update player presence (online/offline).
     */
    public boolean updatePresence(String gameId, Long userId, String connection)
            throws ExecutionException, InterruptedException {

        String uid = userId.toString();

        ApiFuture<Boolean> future = db.runTransaction(transaction -> {
            DocumentReference progressRef = db.collection(GAMES_COLLECTION)
                    .document(gameId)
                    .collection("progress")
                    .document(uid);

            // You could add a "presence" field to PlayerProgress if needed
            // For now, just acknowledge
            return true;
        });

        return future.get();
    }

    /**
     * Forfeit the game.
     * The forfeiting player's progress is marked as FORFEIT.
     * The opponent can continue playing normally and will be declared winner when they finish all 25 questions.
     */
    public boolean forfeit(String gameId, Long userId) throws ExecutionException, InterruptedException {
        String uid = userId.toString();

        DocumentReference gameRef = db.collection(GAMES_COLLECTION).document(gameId);
        DocumentSnapshot gameDoc = gameRef.get().get();

        if (!gameDoc.exists()) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Game not found");
        }

        GameSession game = gameDoc.toObject(GameSession.class);

        if (game == null) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Game object couldn't be created");
        }

        // Validate player is in this game
        boolean isPlayer = game.getPlayers().stream()
                .anyMatch(p -> p.getUid().equals(uid));
        if (!isPlayer) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not a player in this game");
        }

        // Mark player as forfeit - opponent continues playing normally
        DocumentReference myProgressRef = gameRef.collection("progress").document(uid);
        DocumentSnapshot myProgressDoc = myProgressRef.get().get();
        PlayerProgress myProgress = myProgressDoc.toObject(PlayerProgress.class);

        if (myProgress != null) {
            myProgress.setStatus(ProgressStatus.FORFEIT);
            myProgressRef.set(myProgress).get();
        }

        return true;
    }
}
