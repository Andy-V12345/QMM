package com.qmm.userservices.service;

import com.google.cloud.firestore.DocumentReference;
import com.google.cloud.firestore.Firestore;
import com.qmm.userservices.firestore.Operation;
import com.qmm.userservices.firestore.QuestionSet;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ThreadLocalRandom;

@Service
public class QuestionSetService {
    private static final String MODE = "MIXED";
    private static final String DIFFICULTY = "MEDIUM";
    private static final int SCHEMA_VERSION = 1;

    @Autowired
    Environment env;

    /**
     * Generates a new question set with 25 random questions .
     * @return QuestionSet
     */
    public QuestionSet generateQuestionSet() throws ExecutionException, InterruptedException {
        List<QuestionSet.QuestionItem> questions = new ArrayList<>();

        String num_questions = env.getProperty("NUM_QUESTIONS");
        int TARGET_COUNT = num_questions == null ? 25 : Integer.parseInt(num_questions);

        for (int i = 0; i < TARGET_COUNT; i++) {
            // Choose random operation
            Operation[] operations = Operation.values();
            Operation randomOp = operations[new Random().nextInt(operations.length)];

            int a;
            int b;
            int correct;
            String op;

            // Generate numbers based on operation (same logic as your existing code)
            switch (randomOp) {
                case ADD -> {
                    a = ThreadLocalRandom.current().nextInt(5, 51);
                    b = ThreadLocalRandom.current().nextInt(5, 51);
                    correct = a + b;
                    op = "+";
                }
                case SUBTRACT -> {
                    a = ThreadLocalRandom.current().nextInt(10, 31);
                    b = ThreadLocalRandom.current().nextInt(5, a + 1);
                    correct = a - b;
                    op = "-";
                }
                case MULTIPLY -> {
                    a = ThreadLocalRandom.current().nextInt(1, 13);
                    b = ThreadLocalRandom.current().nextInt(0, 13);
                    correct = a * b;
                    op = "×";
                }
                case DIVIDE -> {
                    int[] prodNum = {
                            ThreadLocalRandom.current().nextInt(1, 13),
                            ThreadLocalRandom.current().nextInt(1, 13)
                    };
                    a = prodNum[0] * prodNum[1];
                    b = prodNum[new Random().nextInt(prodNum.length)];
                    correct = a / b;
                    op = "÷";
                }
                default -> throw new IllegalStateException("Unknown operation: " + randomOp);
            }

            questions.add(new QuestionSet.QuestionItem(a, b, op, correct));
        }

        // Return question set (no hash needed)
        return new QuestionSet(
            MODE,
            DIFFICULTY,
            TARGET_COUNT,
            questions,
            null,  // hash not needed
            SCHEMA_VERSION
        );
    }

    /**
     * Validates an answer against the question set.
     * @param questionSet Reference to the QuestionSet object
     * @param qIndex Question index (0-24)
     * @param answer Player's answer
     * @return true if correct, false otherwise
     */
    public boolean validateAnswer(QuestionSet questionSet, int qIndex, int answer)
            throws ExecutionException, InterruptedException {
        if (qIndex < 0 || qIndex >= questionSet.getQuestions().size()) {
            throw new IllegalArgumentException("Invalid question index: " + qIndex);
        }

        QuestionSet.QuestionItem question = questionSet.getQuestions().get(qIndex);
        return question.getCorrect().equals(answer);
    }
}
