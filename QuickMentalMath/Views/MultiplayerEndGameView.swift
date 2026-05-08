//
//  MultiplayerEndGameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/22/25.
//

import SwiftUI
import FirebaseFirestore
import ConfettiSwiftUI

struct MultiplayerEndGameView: View {
    
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    @ObservedObject var endGameModel: MultiplayerEndGameModel
    
    init(endGameModel: MultiplayerEndGameModel) {
        self.endGameModel = endGameModel
    }
    
    // MARK: - Computed Properties
    var sortedPlayers: [(player: GamePlayer, timeMs: Int64?, position: Int)] {
        guard let gameSession = endGameModel.gameSession,
              let result = gameSession.result,
              let userId = authInfo.user?.id else {
            return []
        }
        
        // Map players to their times
        var playersWithTimes: [(player: GamePlayer, timeMs: Int64?)] = []
        
        for player in gameSession.players {
            let timeMs: Int64?
            if player.uid == String(userId) {
                timeMs = endGameModel.userProgress?.elapsedMs
            } else {
                timeMs = endGameModel.opponentProgress?.elapsedMs
            }
            playersWithTimes.append((player: player, timeMs: timeMs))
        }
        
        // Sort by winner first
        let sorted = playersWithTimes.sorted { p1, p2 in
            if p1.player.uid == result.winnerUid {
                return true
            } else if p2.player.uid == result.winnerUid {
                return false
            }
            return false
        }
        
        // Add position numbers
        return sorted.enumerated().map { (index, item) in
            (player: item.player, timeMs: item.timeMs, position: index + 1)
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                VStack(spacing: 15) {
                    EndGameErrorBanner(
                        fetchErrors: endGameModel.fetchErrors,
                        isLoading: endGameModel.isLoading
                    )
                    
                    EndGameHeader(isWinner: endGameModel.isWinner)
                }
                .animation(.easeInOut(duration: 0.3), value: endGameModel.fetchErrors)
                
                
                VStack(spacing: device.valueByDevice(small: 30, normal: 30, ipad: 40)) {
                    if endGameModel is RegularMultiplayerEndGameModel {
                        EndGameStatsCards(
                            isWinner: endGameModel.isWinner,
                            updatedStats: endGameModel.updatedStats,
                            isNewBestTime: endGameModel.isNewBestTime
                        )
                    }
                    
                    
                    let isCustom = endGameModel is CustomMultiplayerEndGameModel
                    
                    EndGameResultsList(
                        sortedPlayers: sortedPlayers,
                        isWinner: endGameModel.isWinner,
                        confettiTrigger: $endGameModel.confettiTrigger,
                        isConfettiOnCooldown: $endGameModel.isConfettiOnCooldown,
                        currentUserId: authInfo.user?.id ?? 0, playAgainReady: isCustom ? endGameModel.gameSession?.playAgainReady : nil, isCustomGame: isCustom)
                    .confettiCannon(
                        trigger: $endGameModel.confettiTrigger,
                        num: 50,
                        colors: [Color("gold"), Color("lightPurple"), Color("lighterPurple")],
                        openingAngle: Angle(degrees: 0),
                        closingAngle: Angle(degrees: 360),
                        repetitions: 4,
                        repetitionInterval: 0.3,
                        hapticFeedback: true
                    )
                    
                    
                }
                
                Spacer()
                
                EndGameActionButtons(
                    endGameModel: endGameModel,
                    handlePlayAgain: {
                        endGameModel.handlePlayAgain(appModel: appModel, authInfo: authInfo)
                    },
                    handleBackToHome: {
                        // Mark as not ready if custom lobby
                        if let _ = endGameModel as? CustomMultiplayerEndGameModel,
                           let user = authInfo.user {
                            Task {
                                _ = await MultiplayerService.setPlayAgainReady(
                                    gameId: endGameModel.gameId,
                                    userId: user.id,
                                    ready: false,
                                    jwtToken: user.jwtToken
                                )
                            }
                        }
                        
                        appModel.path = NavigationPath([AuthState.UNAUTHORIZED, authInfo.authState])
                    }
                )
                .zIndex(0)
                
            }
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            
            // Loading Overlay
            EndGameLoadingOverlay(isLoading: endGameModel.isLoading)
        }
        .onAppear {
            if authInfo.user != nil {
                endGameModel.loadInitialData(authInfo: authInfo)
            }
        }
        .onChange(of: endGameModel.isLoading) { _, newValue in
            // Trigger confetti when loading completes and user won
            if !newValue && endGameModel.isWinner {
                endGameModel.confettiTrigger += 1
            }
        }
        .onChange(of: (endGameModel as? CustomMultiplayerEndGameModel)?.newGameId) { oldValue, newValue in
            // Detect new game creation for custom lobbies
            if let customModel = endGameModel as? CustomMultiplayerEndGameModel,
               let newGameId = newValue {
                print("Detected new game ID from lobby: \(newGameId)")
                
                // Clean up listeners before navigating
                customModel.gameSessionListener?.remove()
                customModel.lobbyListener?.remove()
                customModel.opponentProgressListener?.remove()
                
                
                // Fetch the new game session and navigate
                Task {
                    let db = Firestore.firestore()
                    let gameRef = db.collection("games").document(newGameId)
                    
                    do {
                        let snapshot = try await gameRef.getDocument()
                        if snapshot.exists {
                            let newGameSession = try snapshot.data(as: CustomGameSession.self)
                            
                            await MainActor.run {
                                appModel.path.removeLast()
                                appModel.path.removeLast()
                                appModel.path.append(newGameSession)
                            }
                        }
                    } catch {
                        print("Failed to fetch new game session: \(error.localizedDescription)")
                    }
                }
            }
        }
        .onDisappear {
            endGameModel.opponentProgressListener?.remove()
            
            // Clean up listeners for custom lobbies
            if let customModel = endGameModel as? CustomMultiplayerEndGameModel {
                customModel.gameSessionListener?.remove()
                customModel.lobbyListener?.remove()
            }
        }
    }
}

#Preview {
    GeometryReader { screen in
        MultiplayerEndGameView(endGameModel: CustomMultiplayerEndGameModel(gameId: "AgznpnEXqaiw0Z86pHZF"))
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(AuthInfoModel(user: User(id: 1204, username: "andy.v123", jwtToken: "1234dfaf", stats: nil)))
    }
}
