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
    
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
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
            }
            .onChange(of: scenePhase) { phase in
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
                        await authInfo.loadUserStats()
                        appModel.path = NavigationPath([AuthState.UNAUTHORIZED, authInfo.authState])
                    }
                }
            }
            .environmentObject(authInfo)
            .environmentObject(appModel)
            .environmentObject(deviceModel)
            .dynamicTypeSize(.large ... .xxLarge)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
