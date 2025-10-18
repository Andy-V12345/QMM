package com.qmm.userservices.controller;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SubmitAnswerRequest {
    private String userId;
    @JsonProperty("qIndex")
    private Integer qIndex;             // must equal server's recorded progress.completed
    private Integer answer;             // 1..200
    private Long clientSentAt;          // optional ms epoch for telemetry
}
