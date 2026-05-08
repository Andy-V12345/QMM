package com.qmm.userservices.controller;

import com.google.cloud.Timestamp;
import com.qmm.userservices.firestore.LobbyPlayer;
import com.qmm.userservices.firestore.LobbyState;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class LobbyResponse {
    private String lobbyId;
    private String code;
    private List<LobbyPlayer> players;
    private String hostUid;
    private Integer minPlayers;
    private Integer maxPlayers;
    private LobbyState state;
    private String gameId;
    private Timestamp createdAt;
}
