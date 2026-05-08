package com.qmm.userservices.firestore;

public enum LobbyState {
    WAITING,      // Host waiting for guest to join
    READY,        // Guest has joined, waiting for host to start
    STARTED,      // Game has been created and started
    CANCELLED     // Lobby has been cancelled
}
