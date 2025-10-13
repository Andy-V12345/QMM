package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Random;
import java.util.concurrent.ThreadLocalRandom;


/** Top-level document stored in the "games" collection. */
@Getter
@Setter
@AllArgsConstructor
public class GameSession {
    private final int NUM_QUESTIONS = 20;

    private String id;                         // UUID string
    private GameStatus status;                 // WAITING, IN_PROGRESS, DONE
    private List<Player> players = new ArrayList<>();
    private List<Question> questions = new ArrayList<>();

    private Timestamp time_created;
    private Timestamp time_last_updated;

    private List<String> rankings = new ArrayList<>(); // player IDs in order
    private Integer players_connected;
    private Integer players_found;
    private Integer max_players;

    public GameSession() {} // required

    public GameSession(String id, GameStatus status, int max_players) {
        this.id = id;
        this.status = status;
        this.max_players = max_players;
        this.touchCreatedIfNull();
        this.touchUpdated();
        this.generateQuestions();
    }

    @Override public String toString() { return "GameSession{id=" + id + ", status=" + status + "}"; }
    @Override public boolean equals(Object o){ return o instanceof GameSession gs && Objects.equals(id, gs.id); }
    @Override public int hashCode(){ return Objects.hash(id); }

    public void touchCreatedIfNull() { if (time_created == null) time_created = Timestamp.now(); }
    public void touchUpdated() { time_last_updated = Timestamp.now(); }
    public void addPlayer(Player player) {
        this.players.add(player);
        this.players_found += 1;

    }

    private void generateQuestions() {
        for (int i = 0; i < this.NUM_QUESTIONS; i++) {
            // choose random operation
            Operation[] operations = Operation.values();
            Operation randomOp = operations[new Random().nextInt(operations.length)];

            int num1;
            int num2;
            int answer;

            // choose numbers based on operation
            if (randomOp == Operation.ADD) {
                num1 = ThreadLocalRandom.current().nextInt(5, 51);
                num2 = ThreadLocalRandom.current().nextInt(5, 51);
                answer = num1 + num2;
            }
            else if (randomOp == Operation.SUBTRACT) {
                num1 = ThreadLocalRandom.current().nextInt(10, 31);
                num2 = ThreadLocalRandom.current().nextInt(5, num1+1);
                answer = num1 - num2;
            }
            else if (randomOp == Operation.MULTIPLY) {
                num1 = ThreadLocalRandom.current().nextInt(1, 13);
                num2 = ThreadLocalRandom.current().nextInt(0, 13);
                answer = num1 * num2;
            }
            else {
                int[] prodNum = {ThreadLocalRandom.current().nextInt(1, 13), ThreadLocalRandom.current().nextInt(1, 13)};
                num1 = prodNum[0] * prodNum[1];
                num2 = prodNum[new Random().nextInt(prodNum.length)];
                answer = num1 / num2;
            }

            // create Question object
            this.questions.add(new Question(num1, randomOp, num2, answer));
        }
    }
}
