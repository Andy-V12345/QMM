package com.qmm.userservices.firestore;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

/**
 * Represents a question set document stored in /questionSets/{qsId}
 * Contains 25 pre-generated questions with a hash for audit
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class QuestionSet {
    private String mode;                       // "MIXED" for random operations
    private String difficulty;                 // "MEDIUM" by default
    private Integer targetCount;               // always 25
    private List<QuestionItem> questions;      // array of 25 questions
    private String hash;                       // SHA-256 hash of normalized JSON
    private Integer schemaVersion;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class QuestionItem {
        private Integer a;
        private Integer b;
        private String op;                     // "+", "-", "×", "÷"
        private Integer correct;
    }
}
