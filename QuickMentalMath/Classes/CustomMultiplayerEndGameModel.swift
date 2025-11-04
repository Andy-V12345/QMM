//
//  CustomMultiplayerEndGameModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/30/25.
//

import Foundation
import FirebaseFirestore

@MainActor
class CustomMultiplayerEndGameModel: MultiplayerEndGameModel {
    @Published var isSettingReady: Bool = false
    @Published var hasMarkedReady: Bool = false
    @Published var lobbyId: String?
    @Published var newGameId: String?  // Set when lobby's gameId changes
    var gameSessionListener: ListenerRegistration?
    var lobbyListener: ListenerRegistration?

    override func loadInitialData(authInfo: AuthInfoModel) {
        Task {
            await fetchGameSession(authInfo: authInfo)
            await fetchUserProgress(authInfo: authInfo)
            await fetchOpponentProgress(authInfo: authInfo)

            await MainActor.run {
                // Extract lobbyId from game session
                self.lobbyId = self.gameSession?.lobbyId
                self.isLoading = false
            }

            await startOpponentProgressListener(authInfo: authInfo)

            // Start game session listener for real-time ready status updates
            await startGameSessionListener(authInfo: authInfo)

            // Start lobby listener to detect when new game is created
            if let lobbyId = await self.lobbyId {
                await startLobbyListener(lobbyId: lobbyId)
            }
        }
    }

    override func handlePlayAgain(appModel: AppModel, authInfo: AuthInfoModel) {
        guard let user = authInfo.user else { return }

        Task {
            await MainActor.run {
                isSettingReady = true
                hasMarkedReady = true  // Set immediately for instant UI feedback
            }

            let result = await MultiplayerService.setPlayAgainReady(
                gameId: gameId,
                userId: user.id,
                ready: true,
                jwtToken: user.jwtToken
            )

            await MainActor.run {
                switch result {
                case .success(let response):
                    // Update game session with new playAgainReady map
                    if let playAgainReady = response.playAgainReady {
                        gameSession?.playAgainReady = playAgainReady
                    }

                    // If game was reset, it will be detected by the listener
                    isSettingReady = false

                case .failure(let error):
                    print("Failed to set play again ready: \(error.localizedDescription)")
                    fetchErrors.append("play again ready")
                    hasMarkedReady = false  // Reset to allow retry
                    isSettingReady = false
                }
            }
        }
    }

    func startGameSessionListener(authInfo: AuthInfoModel) async {
        let db = Firestore.firestore()
        let gameRef = db.collection("games").document(gameId)

        gameSessionListener = gameRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Game session listener error: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                return
            }

            do {
                let updatedSession = try snapshot.data(as: CustomGameSession.self)

                // Update the game session (including playAgainReady map for real-time updates)
                Task { @MainActor in
                    self.gameSession = updatedSession
                }

            } catch {
                print("Failed to decode game session: \(error.localizedDescription)")
            }
        }
    }

    func startLobbyListener(lobbyId: String) async {
        let db = Firestore.firestore()
        let lobbyRef = db.collection("lobbies").document(lobbyId)

        lobbyListener = lobbyRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Lobby listener error: \(error.localizedDescription)")
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                return
            }

            do {
                let lobbyData = try snapshot.data(as: LobbyDocument.self)

                // Check if gameId has changed (new game created)
                if let newGameId = lobbyData.gameId, newGameId != self.gameId {
                    Task { @MainActor in
                        print("New game detected in lobby! Old game: \(self.gameId), New game: \(newGameId)")

                        // Set newGameId to trigger navigation in view
                        self.newGameId = newGameId
                    }
                }

            } catch {
                print("Failed to decode lobby document: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    deinit {
        gameSessionListener?.remove()
        lobbyListener?.remove()
    }
}
