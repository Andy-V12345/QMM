//
//  LobbyView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI
import FirebaseFirestore

struct LobbyView: View {
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    
    @Namespace var namespace
    
    @State private var players: [LobbyPlayer]
    @State private var lobbyState: LobbyState
    @State private var lobbyListener: ListenerRegistration?
    @State private var isJoiningGame: Bool = false
    @State private var showCancelConfirmation: Bool = false
    @State private var errorMsg: String? = nil
    @State private var errorRetry: @MainActor () -> Void = {}
    
    let code: String
    let hostUid: String
    let minPlayers: Int
    let maxPlayers: Int
    let lobbyId: String
    
    init(lobbyModel: LobbyResponse) {
        self.players = lobbyModel.players
        self.lobbyState = lobbyModel.state
        self.hostUid = lobbyModel.hostUid
        self.maxPlayers = lobbyModel.maxPlayers
        self.minPlayers = lobbyModel.minPlayers
        self.lobbyId = lobbyModel.lobbyId
        self.code = lobbyModel.code
    }
    
    var isHost: Bool {
        return String(authInfo.user?.id ?? 0) == hostUid
    }
    
    var canStart: Bool {
        return players.count >= minPlayers
    }
    
    var buttonText: String {
        if isHost {
            if canStart {
                return "start game"
            }
            
            return "waiting for players..."
        }
        
        return "waiting for host..."
    }
    
    func handleStartGame() {
        guard let user = authInfo.user else { return }

        // Set loading state and reset errors
        isJoiningGame = true
        resetError()

        Task {
            let result = await MultiplayerService.startGame(
                lobbyId: lobbyId,
                hostUid: String(user.id),
                jwtToken: user.jwtToken
            )

            await MainActor.run {
                switch result {
                case .success(let response):
                    // Success - Firestore listener will handle navigation
                    print("Game started successfully with ID: \(response.gameId)")
                    // Keep isJoiningGame = true, listener will navigate

                case .failure(let error):
                    // Reset loading state and show error
                    isJoiningGame = false

                    // Parse specific error codes
                    let nsError = error as NSError
                    if nsError.code == 403 {
                        errorMsg = "only host can start the game"
                    } else if nsError.code == 400 {
                        errorMsg = "not enough players to start"
                    } else if nsError.code == 404 {
                        errorMsg = "lobby not found"
                    } else {
                        errorMsg = "failed to start game"
                    }

                    errorRetry = handleStartGame
                    print("Error starting game: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handleLeaveLobby() {
        // Show confirmation alert for host
        if isHost {
            showCancelConfirmation = true
            return
        }

        // For non-host, leave directly
        guard let user = authInfo.user else { return }

        Task {
            let result = await MultiplayerService.leaveLobby(
                lobbyId: lobbyId,
                userId: user.id,
                jwtToken: user.jwtToken
            )

            await MainActor.run {
                switch result {
                case .success(_):
                    // Successfully left lobby, navigate back
                    appModel.path.removeLast()
                case .failure(let error):
                    // Handle error - could show alert or just navigate back
                    print("Error leaving lobby: \(error.localizedDescription)")
                    appModel.path.removeLast()
                }
            }
        }
    }
    
    private func resetError() {
        errorMsg = nil
        errorRetry = {}
    }

    private func startLobbyListener() {
        resetError()
        
        lobbyListener?.remove()
        
        let db = Firestore.firestore()
        let lobbyRef = db.collection("lobbies").document(lobbyId)

        lobbyListener = lobbyRef.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error listening to lobby: \(error.localizedDescription)")
                
                errorMsg = "failed to connect to lobby"
                errorRetry = startLobbyListener
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                print("Lobby document does not exist")
                errorMsg = "lobby not found"
                errorRetry = startLobbyListener
                return
            }

            do {
                let updatedLobby = try snapshot.data(as: LobbyDocument.self)

                Task { @MainActor in
                    // Update players list
                    players = updatedLobby.players.map({
                        $0.asLobbyPlayer()
                    })

                    lobbyState = updatedLobby.state
                    
                    // Check if game has started
                    if updatedLobby.state == .STARTED, let gameId = updatedLobby.gameId {
                        isJoiningGame = true
                        await fetchGameAndNavigate(gameId: gameId)
                    }
                }
            } catch {
                print("Error decoding lobby: \(error.localizedDescription)")
                errorMsg = "error loading lobby"
                errorRetry = startLobbyListener
            }
        }
    }

    private func fetchGameAndNavigate(gameId: String) async {
        let db = Firestore.firestore()
        let gameRef = db.collection("games").document(gameId)

        do {
            let snapshot = try await gameRef.getDocument()
            let gameSession = try snapshot.data(as: GameSession.self)

            await MainActor.run {
                appModel.path.removeLast() // Remove LobbyView from stack
                appModel.path.append(gameSession)
            }
        } catch {
            print("Error fetching game session: \(error.localizedDescription)")
            await MainActor.run {
                isJoiningGame = false
                errorMsg = "failed to join game"
                errorRetry = {
                    Task {
                        await fetchGameAndNavigate(gameId: gameId)
                    }
                }
            }
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                ShareLink(item: code, label: {
                    HStack {
                        VStack(spacing: 5) {
                            Text("lobby code")
                                .foregroundStyle(Color("lightPurple"))
                                .font(device.valueByDevice(small: .body, normal: .body, ipad: .title3))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fontWeight(.bold)
                            
                            Text(code)
                                .tracking(3)
                                .font(device.valueByDevice(small: .title, normal: .title, ipad: .largeTitle))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }
                        
                        Spacer()
                        
                        Image(systemName: "square.and.arrow.up")
                            .font(device.valueByDevice(small: .body, normal: .title3, ipad: .title))
                    }
                    .foregroundStyle(Color("darkPurple"))
                })
                .fontWeight(.heavy)
                .padding(.vertical, device.valueByDevice(small: 12, normal: 18, ipad: 24))
                .padding(.horizontal, device.valueByDevice(small: 15, normal: 20, ipad: 25))
                .raisedButton(cornerRadius: device.valueByDevice(small: 12, normal: 20, ipad: 20), backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: 5, action: {})
                
                Spacer()

                LobbyStatusDisplay(
                    isHost: isHost,
                    lobbyState: lobbyState,
                    isJoiningGame: isJoiningGame,
                    errorMsg: errorMsg,
                    retry: errorRetry
                )
                
                Spacer()
                                
                ScrollView {
                    VStack(spacing: device.valueByDevice(small: 13, normal: 15, ipad: 16)) {
                        ForEach(0..<maxPlayers, id: \.self) { i in
                            let player: LobbyPlayer? = i < players.count ? players[i] : nil
                            
                            LobbyPlayerSlot(player: player, hostUid: hostUid)
                        }
                    }
                    
                } //: ScrollView
                .padding(.bottom, 10)
                .scrollIndicators(.hidden)
                .frame(height: device.valueByDevice(small: isHost ? 200 : 250, normal: isHost ? 225 : 300, ipad: 400))

                                
                VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                    
                    if isHost {
                        Button(action: {}, label: {
                            Text("start game")
                                .foregroundStyle(Color("darkPurple"))
                                .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                                .fontWeight(.heavy)
                                .opacity((isHost && !canStart) || isJoiningGame ? 0.5 : 1)
                        })
                        .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
                        .frame(maxWidth: .infinity)
                        .raisedButton(impactStrength: .heavy, cornerRadius: device.valueByDevice(small: 18, normal: 20, ipad: 20), backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 8, normal: 8, ipad: 12),
                                      action: {

                            if isHost && canStart && !isJoiningGame {
                                handleStartGame()
                            }
                        })
                        .disabled((isHost && !canStart) || isJoiningGame)
                        //: Start Button
                    }

                    Button(action: {
                        handleLeaveLobby()
                    }, label: {
                        Text("leave lobby")
                            .foregroundStyle(Color("errorRed"))
                            .opacity(isJoiningGame ? 0.5 : 1)
                    })
                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                    .fontWeight(.heavy)
                    .disabled(isJoiningGame)
                }
            }
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
        } //: ZStack
        .alert("cancel lobby?", isPresented: $showCancelConfirmation) {
            Button("nevermind", role: .cancel) { }
            Button("confirm", role: .destructive) {
                // Execute leave lobby for host
                guard let user = authInfo.user else { return }

                Task {
                    let result = await MultiplayerService.leaveLobby(
                        lobbyId: lobbyId,
                        userId: user.id,
                        jwtToken: user.jwtToken
                    )

                    await MainActor.run {
                        switch result {
                        case .success(_):
                            appModel.path.removeLast()
                        case .failure(let error):
                            print("Error leaving lobby: \(error.localizedDescription)")
                            appModel.path.removeLast()
                        }
                    }
                }
            }
        } message: {
            Text("this will cancel the lobby for all players")
        }
        .onAppear {
            startLobbyListener()
        }
        .onDisappear {
            lobbyListener?.remove()
        }
    }
}

#Preview {
    GeometryReader { screen in
        LobbyView(lobbyModel: LobbyResponse(lobbyId: "abc", code: "ABCDEF", players: [LobbyPlayer(uid: "123", username: "andyv.123", joinedAt: FirebaseTimestamp(seconds: 100, nanos: 0)), LobbyPlayer(uid: "122", username: "ping123", joinedAt: FirebaseTimestamp(seconds: 150, nanos: 0))], hostUid: "123", minPlayers: 3, maxPlayers: 4, state: .WAITING, createdAt: FirebaseTimestamp(seconds: 80, nanos: 0)))
            .environmentObject(NetworkMonitor())
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AuthInfoModel(user: User(id: 123, username: "andyv.123", jwtToken: "1234", stats: nil)))
    }
}
