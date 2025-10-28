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

    let endGameModel: MultiplayerEndGameModel

    // Loading and data state
    @State private var isLoading: Bool = true
    @State private var gameSession: GameSession?
    @State private var userProgress: PlayerProgress?
    @State private var opponentProgress: PlayerProgress?
    @State private var opponentProgressListener: ListenerRegistration?
    @State private var fetchErrors: [String] = []

    // Game result state
    @State private var updatedStats: UserStats?
    @State private var isNewBestTime: Bool = false
    @State private var isWinner: Bool = false

    // Confetti state
    @State private var confettiTrigger = 0
    @State private var isConfettiOnCooldown = false
        
    init(endGameModel: MultiplayerEndGameModel) {
        self.endGameModel = endGameModel
    }

    // MARK: - Computed Properties
    var sortedPlayers: [(player: GamePlayer, timeMs: Int64?, position: Int)] {
        guard let gameSession = gameSession,
              let result = gameSession.result,
              let userId = authInfo.user?.id else {
            return []
        }

        // Map players to their times
        var playersWithTimes: [(player: GamePlayer, timeMs: Int64?)] = []

        for player in gameSession.players {
            let timeMs: Int64?
            if player.uid == String(userId) {
                timeMs = userProgress?.elapsedMs
            } else {
                timeMs = opponentProgress?.elapsedMs
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

    // MARK: - Helper Functions

    private func withRetry<T>(maxAttempts: Int = 3, operation: @escaping () async -> Result<T, Error>) async -> Result<T, Error> {
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

    private func fetchGameSession() async {
        let result = await withRetry {
            return await Task<Result<GameSession, Error>, Never> {
                let db = Firestore.firestore()
                let docRef = db.collection("games").document(endGameModel.gameId)

                do {
                    let snapshot = try await docRef.getDocument()
                    let session = try snapshot.data(as: GameSession.self)
                    return .success(session)
                } catch {
                    return .failure(error)
                }
            }.value
        }

        await MainActor.run {
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
    }

    private func fetchUserProgress() async {
        guard let userId = authInfo.user?.id else { return }

        let result = await withRetry {
            return await Task<Result<PlayerProgress, Error>, Never> {
                let db = Firestore.firestore()
                let docRef = db.collection("games").document(endGameModel.gameId)
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

    private func fetchOpponentProgress() async {
        guard let gameSession = gameSession,
              let userId = authInfo.user?.id else { return }

        // Get opponent's uid
        guard let opponent = gameSession.players.first(where: { $0.uid != String(userId) }) else { return }

        let result = await withRetry {
            return await Task<Result<PlayerProgress, Error>, Never> {
                let db = Firestore.firestore()
                let docRef = db.collection("games").document(endGameModel.gameId)
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

    private func fetchUserStats() async {
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

    private func simulateBotCompletion() async {
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

    private func startOpponentProgressListener() async {
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
        let docRef = db.collection("games").document(endGameModel.gameId)
            .collection("progress").document(opponent.uid)

        // Store listener
        await MainActor.run {
            opponentProgressListener = docRef.addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Opponent progress listener error: \(error.localizedDescription)")
                    if fetchErrors.isEmpty || !fetchErrors.contains("Opponent progress") {
                        fetchErrors.append("Opponent progress")
                    }
                    return
                }

                guard let snapshot = snapshot, snapshot.exists else {
                    return
                }

                do {
                    let progress = try snapshot.data(as: PlayerProgress.self)
                    opponentProgress = progress
                } catch {
                    print("Failed to decode opponent progress: \(error.localizedDescription)")
                }
            }
        }
    }

    private func calculateAndUpdateStats() async {
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
            await MainActor.run {
                updatedStats = newStats
            }
        } else {
            print("Failed to update user stats on backend")
        }
    }

    private func loadInitialData() {
        Task {
            // Fetch game session first (needed for opponent listener)
            await fetchGameSession()

            // Fetch user progress first (needed for bot simulation)
            await fetchUserProgress()

            // Fetch opponent progress (needed for bot simulation delay calculation)
            await fetchOpponentProgress()

            // Fetch user stats
            await fetchUserStats()

            // Calculate and update stats after all data loaded
            await calculateAndUpdateStats()

            // All initial data loaded
            await MainActor.run {
                isLoading = false
            }

            await startOpponentProgressListener()
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Check if user is signed in
            if authInfo.user == nil {
                VStack(spacing: 15) {
                    Text("looks like you're not signed in")
                        .foregroundStyle(Color("errorRed"))
                        .fontWeight(.semibold)
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))

                    Button(action: {}, label: {
                        Text("sign in")
                            .foregroundStyle(Color("offWhite"))
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .fontWeight(.bold)
                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 14, ipad: 16))
                            .padding(.vertical, 4)
                            .raisedButton(
                                cornerRadius: 12,
                                backgroundColor: Color("errorRed"),
                                shadowColor: Color("darkErrorRed"),
                                shadowOffset: device.valueByDevice(small: 3, normal: 4, ipad: 6),
                                action: {
                                    authInfo.user = nil
                                    authInfo.authState = .UNAUTHORIZED
                                    jwtToken = ""
                                    username = ""
                                    id = 0
                                    authState = authInfo.authState
                                    appModel.path = NavigationPath([AuthState.UNAUTHORIZED])
                                }
                            )
                    })
                }
            } else {
                VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                
                VStack(spacing: 15) {
                    // Error Message Banner
                    if !fetchErrors.isEmpty && !isLoading {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.white)
                            
                            Text("failed to load some data")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title3))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .raisedButton(backgroundColor: Color("errorRed"), shadowColor: Color("darkErrorRed"), shadowOffset: 2, action: {})
                        .allowsHitTesting(false)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Text(isWinner ? "winner winner, chicken dinner" : "you need some more practice")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.largeTitle)
                        .foregroundStyle(Color("darkPurple"))
                        .bold()
                }
                .animation(.easeInOut(duration: 0.3), value: fetchErrors)

                
                VStack(spacing: device.valueByDevice(small: 30, normal: 30, ipad: 40)) {
                    VStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                        Text("updated stats")
                            .foregroundStyle(Color("lightPurple"))
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fontWeight(.bold)
                        
                        HStack(spacing: device.valueByDevice(small: 8, normal: 12, ipad: 12)) {
                            VStack(spacing: 5) {
                                Text("wins")
                                    .foregroundStyle(isWinner ? Color("offWhite") : Color("correctGreen"))
                                    .fontWeight(.bold)
                                    .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(updatedStats?.wins ?? 0)")
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.heavy)
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 15, backgroundColor: isWinner ? Color("correctGreen") : Color("offWhite"), shadowColor: isWinner ? Color("darkPastelGreen") : Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {
                                
                            })
                            
                            VStack(spacing: 5) {
                                Text("losses")
                                    .foregroundStyle(isWinner == false ? Color("offWhite") : Color("errorRed"))
                                    .fontWeight(.bold)
                                    .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(updatedStats?.losses ?? 0)")
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.heavy)
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 15, backgroundColor: isWinner == false ? Color("errorRed") : Color("offWhite"), shadowColor: isWinner == false ? Color("darkErrorRed") : Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {

                            })

                            VStack(spacing: 5) {
                                Text(isNewBestTime ? "new best" : "best")
                                    .foregroundStyle(isNewBestTime ? Color("offWhite") : Color("lightPurple"))
                                    .fontWeight(.bold)
                                    .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(updatedStats?.bestTime != nil ? String(format: "%.1fs", Double(updatedStats!.bestTime!) / 10.0) : "--")
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.heavy)
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 15, backgroundColor: isNewBestTime ? Color("lighterPurple") : Color("offWhite"), shadowColor: isNewBestTime ? Color("lightPurple") : Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {
                                
                            })
                            
                        }
                    }
                    
                    VStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                        Text("results")
                            .foregroundStyle(Color("lightPurple"))
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fontWeight(.bold)
                        
                        VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                            ForEach(sortedPlayers, id: \.player.uid) { item in
                                let isCurrentUser = item.player.uid == String(authInfo.user?.id ?? 0)

                                HStack(spacing: 20) {
                                    Text("\(item.position)")
                                        .fontWeight(.semibold)

                                    Text(item.player.displayName)
                                        .fontWeight(.heavy)
                                        .lineLimit(1)

                                    Spacer()

                                    if let timeMs = item.timeMs {
                                        Text(String(format: "%.1fs", Double(timeMs) / 1000.0))
                                            .fontWeight(.heavy)
                                    } else {
                                        Text("--")
                                            .fontWeight(.heavy)
                                    }
                                }
                                .padding(device.valueByDevice(small: 20, normal: 20, ipad: 25))
                                .font(device.valueByDevice(small: .title3, normal: .title3, ipad: .title))
                                .foregroundStyle(Color("darkPurple"))
                                .raisedButton(
                                    cornerRadius: 20,
                                    backgroundColor: {
                                        if isCurrentUser && isWinner {
                                            return Color("gold")
                                        } else if isCurrentUser && !isWinner {
                                            return Color("errorRed")
                                        } else {
                                            return Color("offWhite")
                                        }
                                    }(),
                                    shadowColor: {
                                        if isCurrentUser && isWinner {
                                            return Color("darkYellow")
                                        } else if isCurrentUser && !isWinner {
                                            return Color("darkErrorRed")
                                        } else {
                                            return Color.gray.opacity(0.4)
                                        }
                                    }(),
                                    shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8),
                                    action: {
                                        guard isCurrentUser && isWinner && !isConfettiOnCooldown else { return }
                                        confettiTrigger += 1
                                        HapticManager.shared.trigger(.heavy)
                                        isConfettiOnCooldown = true
                                        Task {
                                            try? await Task.sleep(nanoseconds: 2_700_000_000)
                                            isConfettiOnCooldown = false
                                        }
                                    }
                                )
                                .confettiCannon(
                                    trigger: $confettiTrigger,
                                    num: 50,
                                    colors: [Color("gold"), Color("lightPurple"), Color("lighterPurple")],
                                    openingAngle: Angle(degrees: 0),
                                    closingAngle: Angle(degrees: 360),
                                    radius: 200,
                                    repetitions: 4,
                                    repetitionInterval: 0.3,
                                    hapticFeedback: true
                                )
                                .zIndex(1000)
                            }
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                    Button(action: {}, label: {
                        Text("play again")
                            .foregroundStyle(Color("darkPurple"))
                            .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                            .fontWeight(.heavy)
                    })
                    .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
                    .frame(maxWidth: .infinity)
                    .raisedButton(impactStrength: .heavy, cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 11, normal: 11, ipad: 13),
                                  action: {
                        
                        appModel.findingGame = true
                        appModel.path.removeLast()
                        appModel.path.removeLast()
                    })
                    
                    Button(action: {
                        appModel.path = NavigationPath([AuthState.UNAUTHORIZED, authInfo.authState])
                    }, label: {
                        Text("back to home")
                            .foregroundStyle(Color("darkPurple"))
                    })
                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                    .fontWeight(.heavy)
                }
                
            }
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))

            // Loading Overlay
            if isLoading {
                ZStack {
                    Color.white.ignoresSafeArea()

                    VStack(spacing: 20) {
                        LoadingSpinner(size: 25, color: Color("lightPurple"), width: 6)

                        Text("finalizing results...")
                            .font(device.valueByDevice(small: .title3, normal: .title2, ipad: .title))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("darkPurple"))
                    }
                }
                }
            }
        }
        .onAppear {
            if authInfo.user != nil {
                loadInitialData()
            }
        }
        .onChange(of: isLoading, perform: { newValue in
            // Trigger confetti when loading completes and user won
            if !newValue && isWinner {
                confettiTrigger += 1
            }
        })
        .onDisappear {
            opponentProgressListener?.remove()
        }
    }
}

#Preview {
    GeometryReader { screen in
        MultiplayerEndGameView(endGameModel: MultiplayerEndGameModel(gameId: "34xpjSq7vRsa21x33q6L"))
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(AuthInfoModel(user: User(id: 652, username: "andy.v123", jwtToken: "1234dfaf", stats: nil)))
    }
}
