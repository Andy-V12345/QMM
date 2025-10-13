package com.qmm.userservices.firestore;

import lombok.Getter;
import lombok.Setter;

/** Embedded in GameSession.questions. */
@Getter
@Setter
public class Question {
    private Integer num1;
    private Operation operation;
    private Integer num2;
    private Integer answer;

    public Question() {} // required

    public Question(Integer num1, Operation operation, Integer num2, Integer answer) {
        this.num1 = num1;
        this.operation = operation;
        this.num2 = num2;
        this.answer = answer;
    }
}