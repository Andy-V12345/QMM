//
//  ContentView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/8/23.
//

import SwiftUI

struct ContentView: View {

    @StateObject var authInfo = AuthInfoModel()
    @StateObject var appModel = AppModel(path: NavigationPath())
    @StateObject var deviceModel = DeviceModel()
    @StateObject var networkMonitor = NetworkMonitor()

    @Environment(\.scenePhase) var scenePhase

    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0

    @State private var showDeepLinkError = false
    @State private var deepLinkErrorMessage = ""
    
    var body: some View {
        GeometryReader { screen in
            NavigationStack(path: $appModel.path) {
                VStack(spacing: 10) {
                    Text("\"math is for the great. quick mental math is for the legends.\"")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("vividPurple"))
                        .fontWeight(.medium)
                        .italic()
                        .font(DeviceModel(screen: screen).valueByDevice(small: .title3, normal: .title3, ipad: .title))
                    
                    Text("- chatgpt")
                        .foregroundStyle(Color("darkPurple"))
                        .fontWeight(.medium)
                        .font(DeviceModel(screen: screen).valueByDevice(small: .body, normal: .body, ipad: .title3))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, DeviceModel(screen: screen).valueByDevice(small: 30, normal: 30, ipad: 80))
                    .navigationDestination(for: AuthState.self, destination: { state in
                        if state == .UNAUTHORIZED {
                            AuthView()
                                .navigationBarBackButtonHidden()
                        }
                        else if state == .AUTHORIZED || state == .NO_ACCOUNT {
                            HomeView()
                                .navigationBarBackButtonHidden()
                        }
                    })
                    .navigationDestination(for: GameModel.self, destination: { gameModel in
                        GameView(gameModel: gameModel)
                            .id(gameModel.id)
                            .navigationBarBackButtonHidden()
                    })
                    .navigationDestination(for: EndGameModel.self, destination: { endGameModel in
                        EndGameView(endGameModel: endGameModel)
                            .navigationBarBackButtonHidden()
                    })
                    .navigationDestination(for: GameConfigsModel.self, destination: { configModel in
                        
                        if configModel.mode == .TIME {
                            TimeTrialView(gameConfigsModel: configModel)
                                .navigationBarBackButtonHidden()
                        }
                        else {
                            ExtraOptionsView(gameConfigsModel: configModel)
                                .navigationBarBackButtonHidden()
                        }
                    })
                    .navigationDestination(for: GamePlayer.self, destination: { gamePlayer in
                        
                        MultiplayerInfoView(gamePlayer: gamePlayer)
                            .navigationBarBackButtonHidden()
                    })
                    .navigationDestination(for: RegularGameSession.self, destination: { gameSession in
                            
                        MultiplayerGameView(gameSession: gameSession)
                            .navigationBarBackButtonHidden()
                    })
                    .navigationDestination(for: CustomGameSession.self, destination: { gameSession in
                            
                        MultiplayerGameView(gameSession: gameSession)
                            .navigationBarBackButtonHidden()
                    })
                    .navigationDestination(for: RegularMultiplayerEndGameModel.self, destination: { endGameModel in

                        MultiplayerEndGameView(endGameModel: endGameModel)
                            .navigationBarBackButtonHidden()
                    })
                    .navigationDestination(for: CustomMultiplayerEndGameModel.self, destination: { endGameModel in

                        MultiplayerEndGameView(endGameModel: endGameModel)
                            .navigationBarBackButtonHidden()
                    })
                    .navigationDestination(for: CustomLobbyInfoModel.self, destination: { infoModel in
                        
                        CustomLobbyInfoView()
                            .navigationBarBackButtonHidden()
                    })
                    .navigationDestination(for: LobbyResponse.self, destination: { lobbyResponse in
                        
                        LobbyView(lobbyModel: lobbyResponse)
                            .navigationBarBackButtonHidden()
                    })
            }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    authInfo.user = User(id: id, username: username, jwtToken: jwtToken)
                    authInfo.authState = authState
                    
                    Task {
                        if authInfo.authState == .UNAUTHORIZED {
                            appModel.path = NavigationPath([authInfo.authState])
                        }
                    }
                case .background:
                    break
                case .inactive:
                    break
                @unknown default:
                    break
                }
            }
            .onAppear {
                deviceModel.setScreen(screen: screen)
                
                authInfo.user = User(id: id, username: username, jwtToken: jwtToken)
                authInfo.authState = authState
                
                Task {
                    if authInfo.authState == .UNAUTHORIZED {
                        appModel.path = NavigationPath([authInfo.authState])
                    }
                    else if authInfo.authState == .NO_ACCOUNT {
                        appModel.path = NavigationPath([AuthState.UNAUTHORIZED, authInfo.authState])
                    }
                    else {
                        appModel.path = NavigationPath([AuthState.UNAUTHORIZED, authInfo.authState])
                    }
                }
            }
            .environmentObject(authInfo)
            .environmentObject(appModel)
            .environmentObject(deviceModel)
            .environmentObject(networkMonitor)
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .alert("unable to join lobby", isPresented: $showDeepLinkError) {
                Button("ok") {
                    // Navigate to HomeView on error
                    appModel.path = NavigationPath([AuthState.UNAUTHORIZED, AuthState.AUTHORIZED])
                }
            } message: {
                Text(deepLinkErrorMessage.lowercased())
            }
            .dynamicTypeSize(.large)
            .fullScreenCover(isPresented: $appModel.findingGame, content: {
                WaitingRoomView(authInfo: authInfo, appModel: appModel, networkMonitor: networkMonitor)
                    .environmentObject(deviceModel)
            })
        }
    }

    /// Handle deep link URL
    private func handleDeepLink(_ url: URL) {
        let deepLink = DeepLinkHandler.parse(url)

        switch deepLink {
        case .lobby(let code):
            // Check if user is authenticated
            if authInfo.authState == .AUTHORIZED, let user = authInfo.user {
                // User is authenticated, join lobby immediately
                Task {
                    let result = await MultiplayerService.joinLobby(
                        code: code,
                        userId: user.id,
                        username: user.username,
                        jwtToken: user.jwtToken
                    )

                    switch result {
                    case .success(let lobbyResponse):
                        // Navigate to lobby view with full navigation stack
                        await MainActor.run {
                            // Dismiss any open sheets before navigation
                            appModel.dismissAllSheets()
                            appModel.path = NavigationPath([AuthState.UNAUTHORIZED, AuthState.AUTHORIZED])
                            appModel.path.append(CustomLobbyInfoModel())
                            appModel.path.append(lobbyResponse)
                        }
                    case .failure(let error):
                        // Check if user is already in this lobby - if so, do nothing
                        if let nsError = error as NSError?,
                           nsError.code == 400,
                           nsError.localizedDescription.contains("Already in this lobby") {
                            // Silently ignore - user is already in the lobby
                            return
                        }

                        // Show error and navigate to CustomLobbyInfoView
                        await MainActor.run {
                            deepLinkErrorMessage = "failed to join lobby: \(error.localizedDescription)"
                            showDeepLinkError = true
                        }
                    }
                }
            } else {
                // User not authenticated, store pending code
                authInfo.pendingLobbyCode = code
                // Navigate to auth screen if not already there
                if authInfo.authState != .UNAUTHORIZED {
                    appModel.path = NavigationPath([AuthState.UNAUTHORIZED])
                }
            }

        case .invalid:
            // Invalid deep link format
            deepLinkErrorMessage = "invalid lobby link format"
            showDeepLinkError = true
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
