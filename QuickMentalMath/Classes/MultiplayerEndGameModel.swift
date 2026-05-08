//
//  MultiplayerEndGameModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/22/25.
//

import Foundation
import FirebaseFirestore

class MultiplayerEndGameModel: Hashable, ObservableObject {
    static func == (lhs: MultiplayerEndGameModel, rhs: MultiplayerEndGameModel) -> Bool {
        return lhs.gameId == rhs.gameId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.gameId)
    }
    
    // Loading and data state
    @Published var isLoading: Bool = true
    @Published var gameSession: GameSession?
    @Published var userProgress: PlayerProgress?
    @Published var opponentProgress: PlayerProgress?
    @Published var opponentProgressListener: ListenerRegistration?
    @Published var fetchErrors: [String] = []

    // Game result state
    @Published var updatedStats: UserStats?
    @Published var isNewBestTime: Bool = false
    @Published var isWinner: Bool = false

    // Confetti state
    @Published var confettiTrigger = 0
    @Published var isConfettiOnCooldown = false
    
    var gameId: String
    
    init(gameId: String) {
        self.gameId = gameId
    }
    
    func withRetry<T>(maxAttempts: Int = 3, operation: @escaping () async -> Result<T, Error>) async -> Result<T, Error> {
        var lastError: Error?

        for attempt in 1...maxAttempts {
            let result = await operation()

            switch result {
            case .success:
                return result
            case .failure(let error):
                lastError = error
                if attempt < maxAttempts {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
                }
            }
        }

        return .failure(lastError ?? NSError(domain: "MultiplayerEndGameView", code: -1))
    }
    
    @MainActor
    func fetchGameSession(authInfo: AuthInfoModel) async {
        let result = await withRetry {
            return await Task<Result<GameSession, Error>, Never> {
                let db = Firestore.firestore()
                let docRef = db.collection("games").document(self.gameId)

                do {
                    let snapshot = try await docRef.getDocument()
                    let session = try snapshot.data(as: GameSession.self)
                    return .success(session)
                } catch {
                    return .failure(error)
                }
            }.value
        }

        switch result {
        case .success(let session):
            gameSession = session
            
            if let gameResult = session.result, let userId = authInfo.user?.id {
                isWinner = gameResult.winnerUid == String(userId)
            }
        case .failure:
            fetchErrors.append("game session")
        }
    }

    func fetchUserProgress(authInfo: AuthInfoModel) async {
        guard let userId = authInfo.user?.id else { return }

        let result = await withRetry {
            return await Task<Result<PlayerProgress, Error>, Never> {
                let db = Firestore.firestore()
                let docRef = db.collection("games").document(self.gameId)
                    .collection("progress").document(String(userId))

                do {
                    let snapshot = try await docRef.getDocument()
                    let progress = try snapshot.data(as: PlayerProgress.self)
                    return .success(progress)
                } catch {
                    return .failure(error)
                }
            }.value
        }

        await MainActor.run {
            switch result {
            case .success(let progress):
                userProgress = progress
            case .failure:
                fetchErrors.append("your progress")
            }
        }
    }

    func fetchOpponentProgress(authInfo: AuthInfoModel) async {
        guard let gameSession = gameSession,
              let userId = authInfo.user?.id else { return }

        // Get opponent's uid
        guard let opponent = gameSession.players.first(where: { $0.uid != String(userId) }) else { return }

        let result = await withRetry {
            return await Task<Result<PlayerProgress, Error>, Never> {
                let db = Firestore.firestore()
                let docRef = db.collection("games").document(self.gameId)
                    .collection("progress").document(opponent.uid)

                do {
                    let snapshot = try await docRef.getDocument()
                    let progress = try snapshot.data(as: PlayerProgress.self)
                    return .success(progress)
                } catch {
                    return .failure(error)
                }
            }.value
        }

        await MainActor.run {
            switch result {
            case .success(let progress):
                opponentProgress = progress
            case .failure:
                fetchErrors.append("opponent progress")
            }
        }
    }

    func fetchUserStats(authInfo: AuthInfoModel) async {
        guard let user = authInfo.user else { return }

        let result = await withRetry {
            return await Task<Result<UserStats, Error>, Never> {
                if let stats = try? await AuthService.loadUserStats(userId: user.id, jwtToken: user.jwtToken) {
                    return .success(stats)
                } else {
                    return .failure(NSError(domain: "MultiplayerEndGameView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load user stats"]))
                }
            }.value
        }

        await MainActor.run {
            switch result {
            case .success(let stats):
                updatedStats = stats
            case .failure:
                fetchErrors.append("user stats")
            }
        }
    }

    func simulateBotCompletion() async {
        guard let userProgress = userProgress,
              let userTimeMs = userProgress.elapsedMs else { return }

        // Get bot's actual completed questions
        let botCompleted = opponentProgress?.completed ?? 0
        let totalQuestions = 25

        // Calculate questions remaining for bot
        let questionsRemaining = totalQuestions - botCompleted

        // Calculate delay: 0.75 seconds per question remaining
        let delay = Double(questionsRemaining) * 0.75
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        // Calculate bot's time: user's time + delay
        let delayMs = Int64(delay * 1000.0)
        let botTimeMs = userTimeMs + delayMs

        // Create simulated PlayerProgress for bot
        let simulatedProgress = PlayerProgress(
            completed: totalQuestions,
            status: "FINISHED",
            lastAnswerAt: Timestamp(),
            finishedAt: Timestamp(),
            elapsedMs: botTimeMs
        )

        // Set opponent progress
        await MainActor.run {
            opponentProgress = simulatedProgress
        }
    }

    @MainActor
    func startOpponentProgressListener(authInfo: AuthInfoModel) async {
        guard let session = gameSession,
              let userId = authInfo.user?.id else { return }

        // Determine opponent
        guard let opponent = session.players.first(where: { $0.uid != String(userId) }) else { return }

        // Check if opponent is a bot and user won
        let isOpponentBot = opponent.uid.lowercased().contains("bot")
        let userWon = session.result?.winnerUid == String(userId)
        
        // If opponent is bot and user won, simulate bot completion instead of listening
        if isOpponentBot && userWon {
            await simulateBotCompletion()
            return
        }

        // Otherwise, create normal listener for real opponent
        let db = Firestore.firestore()
        let docRef = db.collection("games").document(self.gameId)
            .collection("progress").document(opponent.uid)

        // Store listener
        opponentProgressListener = docRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Opponent progress listener error: \(error.localizedDescription)")
                if self.fetchErrors.isEmpty || !self.fetchErrors.contains("Opponent progress") {
                    self.fetchErrors.append("Opponent progress")
                }
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                return
            }

            do {
                let progress = try snapshot.data(as: PlayerProgress.self)
                self.opponentProgress = progress
            } catch {
                print("Failed to decode opponent progress: \(error.localizedDescription)")
            }
        }
    }

    func calculateAndUpdateStats(authInfo: AuthInfoModel) async {
        guard let user = authInfo.user,
              let gameSession = gameSession,
              let userProgress = userProgress,
              let currentStats = updatedStats else { return }

        // Check if result exists
        guard let result = gameSession.result else {
            await MainActor.run {
                fetchErrors.append("game result")
            }
            return
        }

        // Determine if user won
        let userWon = result.winnerUid == String(user.id)

        await MainActor.run {
            isWinner = userWon
        }

        // Get user's time in tenths of a second (convert from ms)
        // Store as tenths to preserve one decimal place (e.g., 19.1s = 191 tenths)
        guard let userTimeMs = userProgress.elapsedMs else { return }
        let userTimeTenths = Int(round(Double(userTimeMs) / 100.0))  // Convert ms to tenths of seconds

        
        // Calculate new stats
        var newStats = currentStats

        // Update wins or losses
        if userWon {
            newStats.wins = (currentStats.wins ?? 0) + 1
        } else {
            newStats.losses = (currentStats.losses ?? 0) + 1
        }

        // Update best time if improved
        if let currentBest = currentStats.bestTime {
            if userTimeTenths < currentBest {
                newStats.bestTime = userTimeTenths
                await MainActor.run {
                    isNewBestTime = true
                }
            }
        } else {
            // First time, set best time
            newStats.bestTime = userTimeTenths
            await MainActor.run {
                isNewBestTime = true
            }
        }
        
        // Update stats on backend
        let statsRequest = UserStatsRequest(userStats: newStats)
        let success = await AuthService.updateUserStats(
            userId: user.id,
            statId: currentStats.id,
            jwtToken: user.jwtToken,
            statsRequest: statsRequest
        )

        if success {
            let finalStats = newStats
            await MainActor.run {
                updatedStats = finalStats
            }
        } else {
            print("Failed to update user stats on backend")
        }
    }
    
    // Needs to be overriden
    func loadInitialData(authInfo: AuthInfoModel) {}
    
    // Needs to be overriden
    func handlePlayAgain(appModel: AppModel, authInfo: AuthInfoModel) {}
}
