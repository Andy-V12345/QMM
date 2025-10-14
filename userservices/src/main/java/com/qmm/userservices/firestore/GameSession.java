package com.qmm.userservices.firestore;

import com.google.cloud.Timestamp;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.*;
import java.util.concurrent.ThreadLocalRandom;


/** Top-level document stored in the "games" collection. */
@Getter
@Setter
@AllArgsConstructor
public class GameSession {
    private final int NUM_QUESTIONS = 20;

    private String id;
    private GameStatus status;
    private HashMap<String, Player> players;
    private List<Question> questions;

    private Timestamp time_created;
    private Timestamp time_last_updated;

    private List<Long> rankings;
    private Integer players_connected;
    private Integer players_found;
    private Integer max_players;

    public GameSession() {} // required

    public GameSession(String id, GameStatus status, int max_players) {
        this.id = id;
        this.status = status;
        this.max_players = max_players;
        this.players = new HashMap<>();
        this.questions = new ArrayList<>();
        this.time_created = Timestamp.now();
        this.time_last_updated = this.time_created;
        this.rankings = new ArrayList<>();
        this.players_connected = 0;
        this.players_found = 0;
        this.generateQuestions();
    }

    @Override public String toString() { return "GameSession{id=" + id + ", status=" + status + "}"; }
    @Override public boolean equals(Object o){ return o instanceof GameSession gs && Objects.equals(id, gs.id); }
    @Override public int hashCode(){ return Objects.hash(id); }

    public void addPlayer(Player player) {
        this.players.put(player.getId().toString(), player);
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
