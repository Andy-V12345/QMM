package com.qmm.userservices.controller;

import com.qmm.userservices.firestore.GameResult;
import com.qmm.userservices.firestore.GameStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SubmitAnswerResponse {
    private Integer completed;              // my new completed count
}
