package com.qmm.userservices.controller;

import com.qmm.userservices.firestore.PlayerStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UpdatePlayerRequest {
    private Long user_id;
    private PlayerStatus updated_status;
    private Integer num_completed;
    private String session_id;
}
