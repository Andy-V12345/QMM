//
//  ContentView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/8/23.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

class AppModel: ObservableObject {
    @Published var path: NavigationPath
    
    init(path: NavigationPath) {
        self.path = path
    }
}

enum DeviceType {
    case SMALL, NORMAL, LARGE
}

class DeviceModel: ObservableObject {
    @Published var type: DeviceType = .NORMAL
}


struct ContentView: View {
    
    @StateObject var authInfo = AuthInfo()
    @StateObject var appModel = AppModel(path: NavigationPath())
    @StateObject private var gameModel = GameModel()
    @StateObject private var deviceModel = DeviceModel()
    
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0
    
    var body: some View {
        NavigationStack(path: $appModel.path) {
            EmptyView()
                .navigationDestination(for: AuthState.self, destination: { state in
                    if state == .UNAUTHORIZED {
                        AuthView()
                            .navigationBarBackButtonHidden()
                    }
                    else if state == .AUTHORIZED {
                        HomeView()
                            .navigationBarBackButtonHidden()
                    }
                    else if state == .NO_ACCOUNT {
                        HomeView()
                            .navigationBarBackButtonHidden()
                    }
                })
                .navigationDestination(for: AppState.self, destination: { state in
                    if state == .SETTINGS {
                        if gameModel.mode == "time" {
                            TimeTrialView()
                                .navigationBarBackButtonHidden()
                        }
                        else {
                            ExtraOptionsView()
                                .navigationBarBackButtonHidden()
                        }
                    }
                    else if state == .GAME {
                        GameView()
                            .navigationBarBackButtonHidden()
                    }
                    else if state == .END {
                        EndGameView()
                            .navigationBarBackButtonHidden()
                    }
                })
        }
        .onChange(of: scenePhase) { phase in
            print(phase)
            switch phase {
            case .active:
                print("active")
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
            case .background:
                break
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        .environmentObject(authInfo)
        .environmentObject(appModel)
        .environmentObject(gameModel)
        .environmentObject(deviceModel)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
