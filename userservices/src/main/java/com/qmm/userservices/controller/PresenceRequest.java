package com.qmm.userservices.controller;

import com.qmm.userservices.firestore.ConnectionStatus;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PresenceRequest {
    private Long userId;
    private ConnectionStatus connection;  // ONLINE or OFFLINE
}
