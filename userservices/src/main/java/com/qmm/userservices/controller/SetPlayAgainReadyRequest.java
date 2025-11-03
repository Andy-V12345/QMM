package com.qmm.userservices.controller;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SetPlayAgainReadyRequest {
    private Long userId;
    private Boolean ready;  // true = wants to play again, false = doesn't want to
}
