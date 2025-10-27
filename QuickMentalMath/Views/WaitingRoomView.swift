//
//  WaitingRoomView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/20/25.
//

import SwiftUI
import FirebaseFirestore

struct WaitingRoomView: View {

    @Environment(\.dismiss) var dismiss

    @ObservedObject var device: DeviceModel
    @ObservedObject var authInfo: AuthInfoModel
    @ObservedObject var appModel: AppModel
    @ObservedObject var networkMonitor: NetworkMonitor

    @State private var bounceOffset: CGFloat = 0
    @State private var selectedQuote: String = ""
    @State private var statusText: String = "joining matchmaking"
    @State private var matchStatusListener: ListenerRegistration?
    @State private var botTimerTask: Task<Void, Never>?
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var gameId: String?
    @State private var hasSeenInitialSnapshot: Bool = false

    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0

    let quotes = [
        "your opponent is gonna be shook.",
        "finding you a worthy challenger.",
        "sharpening your mental math game.",
        "this is gonna be legendary.",
        "prepare to cook.",
        "about to witness some real competition.",
        "this matchup is about to go crazy."
    ]

    private func leaveQueue() {
        // Cancel listeners and timers
        matchStatusListener?.remove()
        botTimerTask?.cancel()

        // Call leave match API
        Task {
            guard let user = authInfo.user else {
                dismiss()
                return
            }
            let _ = await MultiplayerService.leaveMatch(userId: user.id, jwtToken: user.jwtToken)
            dismiss()
        }
    }

    private func joinMatchmaking() {
        guard let user = authInfo.user else { return }

        Task {
            let result = await MultiplayerService.joinMatch(userId: user.id, username: user.username, jwtToken: user.jwtToken)

            switch result {
            case .success(let response):
                switch response {
                case .waiting:
                    // Update status and start listening
                    await MainActor.run {
                        statusText = "finding a game"
                    }
                    startMatchStatusListener()
                    startBotFallbackTimer()
                case .matched(let matchData):
                    // Immediately matched
                    await MainActor.run {
                        gameId = matchData.gameId
                        statusText = "joining game"
                    }
                    await fetchGameSessionAndNavigate(gameId: matchData.gameId)
                case .already_matched:
                    break
                }
            case .failure(let error):
                // Show error after 3 retries failed
                print("error", error)
                await MainActor.run {
                    errorMessage = "error joining matchmaking"
                    showError = true
                }
            }
        }
    }

    private func startMatchStatusListener() {
        guard let user = authInfo.user else { return }

        let db = Firestore.firestore()
        let docRef = db.collection("users").document("\(user.id)").collection("matchStatus").document("current")

        matchStatusListener = docRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to match status: \(error.localizedDescription)")
                Task { @MainActor in
                    errorMessage = "error finding a game"
                    showError = true
                }
                return
            }

            guard let data = snapshot?.data() else {
                return
            }

            // Ignore the initial snapshot (which contains stale data)
            if !hasSeenInitialSnapshot {
                hasSeenInitialSnapshot = true
                return
            }

            if let matched = data["matched"] as? Bool, matched == true {
                // Match found!
                if let foundGameId = data["gameId"] as? String {
                    gameId = foundGameId
                    statusText = "joining game"
                    botTimerTask?.cancel()
                    matchStatusListener?.remove()

                    Task {
                        await fetchGameSessionAndNavigate(gameId: foundGameId)
                    }
                }
            }
        }
    }

    private func startBotFallbackTimer() {
        botTimerTask = Task {
            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds

            // Check if task was cancelled or already navigated
            if Task.isCancelled { return }

            // Still not matched, play with bot
            guard let user = authInfo.user else { return }

            let result = await MultiplayerService.playBot(userId: user.id, username: user.username, jwtToken: user.jwtToken)

            // Check if cancelled after await (Firestore listener may have triggered navigation)
            if Task.isCancelled { return }

            switch result {
            case .success(let matchData):
                await MainActor.run {
                    gameId = matchData.gameId
                    statusText = "joining game"
                }
            case .failure(let error):
                // Only show error alert for non-cancellation errors
                let nsError = error as NSError
                if nsError.code != NSURLErrorCancelled {
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
    }

    private func fetchGameSessionAndNavigate(gameId: String) async {
        let db = Firestore.firestore()
        let docRef = db.collection("games").document(gameId)

        do {
            let snapshot = try await docRef.getDocument()

            // Use Firestore's built-in decoding to handle Timestamp objects
            let gameSession = try snapshot.data(as: GameSession.self)

            // Navigate to game on main thread
            await MainActor.run {
                appModel.path.append(gameSession)
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = "error joining the game"
                showError = true
            }
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Check if connected to wifi
            if !networkMonitor.isConnected {
                VStack(spacing: 10) {
                    Spacer()

                    Text("not connected to wifi")
                        .foregroundStyle(Color("errorRed"))
                        .fontWeight(.semibold)
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        .multilineTextAlignment(.center)

                    Spacer()

                    // Leave queue button
                    Button(action: {}, label: {
                        Text("leave queue")
                            .foregroundStyle(Color("offWhite"))
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .fontWeight(.bold)
                    })
                    .padding(device.valueByDevice(small: 10, normal: 12, ipad: 14))
                    .frame(maxWidth: .infinity)
                    .raisedButton(
                        impactStrength: .medium,
                        cornerRadius: 20,
                        backgroundColor: Color("errorRed"),
                        shadowColor: Color("darkErrorRed"),
                        shadowOffset: device.valueByDevice(small: 6, normal: 8, ipad: 10),
                        action: {
                            leaveQueue()
                        }
                    )
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            } else if authInfo.user == nil {
                // Check if user is signed in
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
                                    dismiss()
                                }
                            )
                    })
                }
            } else {
                VStack(spacing: 10) {
                    Spacer()

                    if !showError {
                    // Bouncing dots animation
                    HStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 13)) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color("lightPurple"))
                                .frame(height: device.valueByDevice(small: 13, normal: 13, ipad: 20))
                                .offset(y: bounceOffset)
                                .animation(
                                    Animation.interpolatingSpring(stiffness: 200, damping: 10)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.1),
                                    value: bounceOffset
                                )
                        }
                    }
                    .padding(.bottom, 30)

                    // Status text
                    Text(statusText)
                        .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                        .fontWeight(.heavy)
                        .foregroundStyle(Color("darkPurple"))
                } else {
                    // Error UI
                    VStack(spacing: 15) {
                        Text(errorMessage)
                            .foregroundStyle(Color("errorRed"))
                            .fontWeight(.semibold)
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .multilineTextAlignment(.center)

                        Button(action: {}, label: {
                            Text("retry")
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
                                        // Reset error state and retry
                                        showError = false
                                        errorMessage = ""
                                        hasSeenInitialSnapshot = false
                                        statusText = "joining matchmaking"
                                        selectedQuote = quotes.randomElement() ?? quotes[0]
                                        bounceOffset = -15
                                        joinMatchmaking()
                                    }
                                )
                        })
                    }
                }

                // Quote


                Spacer()

                if !showError {
                    Text(selectedQuote)
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("darkPurple"))
                        .frame(maxWidth: .infinity)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                }

                // Leave queue button
                Button(action: {}, label: {
                    Text("leave queue")
                        .foregroundStyle(Color("offWhite"))
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        .fontWeight(.bold)
                })
                .padding(device.valueByDevice(small: 10, normal: 12, ipad: 14))
                .frame(maxWidth: .infinity)
                .raisedButton(
                    impactStrength: .medium,
                    cornerRadius: 20,
                    backgroundColor: Color("errorRed"),
                    shadowColor: Color("darkErrorRed"),
                    shadowOffset: device.valueByDevice(small: 6, normal: 8, ipad: 10),
                    action: {
                        leaveQueue()
                    }
                )
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            }
        }
        .onAppear {
            if authInfo.user != nil {
                bounceOffset = -15
                selectedQuote = quotes.randomElement() ?? quotes[0]
                joinMatchmaking()
            }
        }
        .onDisappear {
            matchStatusListener?.remove()
            botTimerTask?.cancel()
        }
    }
}

// Preview wrapper to show error state
private struct WaitingRoomPreviewWrapper: View {
    @State private var showError = true
    @State private var errorMessage = "failed to connect to matchmaking server."

    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 10) {
                    Spacer()

                    if showError {
                        VStack(spacing: 15) {
                            Text(errorMessage)
                                .foregroundStyle(Color("errorRed"))
                                .fontWeight(.semibold)
                                .font(.body)
                                .multilineTextAlignment(.center)

                            Button(action: {}, label: {
                                Text("retry")
                                    .foregroundStyle(Color("offWhite"))
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .raisedButton(
                                        cornerRadius: 12,
                                        backgroundColor: Color("errorRed"),
                                        shadowColor: Color("darkErrorRed"),
                                        shadowOffset: 3,
                                        action: {
                                            showError = false
                                        }
                                    )
                            })
                        }
                    }

                    Spacer()

                    Button(action: {}, label: {
                        Text("leave queue")
                            .foregroundStyle(Color("offWhite"))
                            .font(.body)
                            .fontWeight(.bold)
                    })
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .raisedButton(
                        impactStrength: .medium,
                        cornerRadius: 20,
                        backgroundColor: Color("errorRed"),
                        shadowColor: Color("darkErrorRed"),
                        shadowOffset: 6,
                        action: {}
                    )
                }
                .padding(15)
            }
            .environmentObject(DeviceModel(screen: screen))
        }
    }
}

#Preview("Error State") {
    WaitingRoomPreviewWrapper()
}

//#Preview("Normal State") {
//    GeometryReader { screen in
//        WaitingRoomView(device: DeviceModel(screen: screen), authInfo: AuthInfoModel(), appModel: AppModel(path: NavigationPath()))
//    }
//}
