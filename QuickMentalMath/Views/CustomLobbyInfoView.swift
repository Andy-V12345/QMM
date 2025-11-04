//
//  CustomLobbyInfoView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI

struct CustomLobbyInfoView: View {
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var networkMonitor: NetworkMonitor

    // State for future functionality
    @State private var showingCreateLobby = false
    @State private var showingJoinLobby = false
    @State private var lobbyCode: String = ""
    
    @State private var player1Progress: Int = 0
    @State private var player2Progress: Int = 0
    @State private var winner: String? = nil
    @State private var player1AnimationTask: Task<Void, Never>?
    @State private var player2AnimationTask: Task<Void, Never>?
    
    private func reset() async {
        // Reset after reaching the end
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second pause
        
        withAnimation(.easeInOut(duration: 0.1)) {
            player1Progress = 1
            player2Progress = 1
            
        }
    }
    
    // MARK: - Racing Animation Logic
    
    private func startRacingAnimation() {
        // Animate Player 1
        player1AnimationTask = Task {
            while true {
                // Check if task was cancelled
                if Task.isCancelled { return }

                let randomDelay = Double.random(in: 0.7...1.3)
                try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000_000))

                // Check again after sleep
                if Task.isCancelled { return }

                if player1Progress < 10 {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        player1Progress += 1
                    }
                } else {
                    if player2Progress == 10 {
                        await reset()
                    }
                }
            }
        }

        // Animate Player 2
        player2AnimationTask = Task {
            while true {
                // Check if task was cancelled
                if Task.isCancelled { return }

                let randomDelay = Double.random(in: 0.9...1.5)
                try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000_000))

                // Check again after sleep
                if Task.isCancelled { return }

                if player2Progress < 10 {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        player2Progress += 1
                    }
                } else {
                    if player1Progress == 10 {
                        await reset()
                    }
                }
            }
        }
    }

    private func stopRacingAnimation() {
        player1AnimationTask?.cancel()
        player2AnimationTask?.cancel()
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if !networkMonitor.isConnected {
                // Network error view
                VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                    Spacer()

                    Text("not connected to wifi")
                        .foregroundStyle(Color("errorRed"))
                        .fontWeight(.semibold)
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        .multilineTextAlignment(.center)

                    Spacer()

                    Button(action: {
                        appModel.path.removeLast()
                    }, label: {
                        Text("back to home")
                            .foregroundStyle(Color("darkPurple"))
                    })
                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                    .fontWeight(.heavy)
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            } else {
                // Main content
                VStack(spacing: device.valueByDevice(small: 30, normal: 40, ipad: 60)) {
                    // Header section
                    VStack(spacing: 0) {
                        Text("welcome to")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("darkPurple"))
                            .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                            .fontWeight(.bold)

                        HStack(spacing: 15) {
                            Text("custom lobbies")
                                .fontWeight(.heavy)
                            
                            Image(systemName: "arcade.stick")
                                .font(device.valueByDevice(small: .title, normal: .largeTitle, ipad: .largeTitle))
                                .bold()
                            
                            Spacer()
                        }
                        .font(device.valueByDevice(small: .title, normal: .largeTitle, ipad: .largeTitle))
                        .foregroundStyle(Color("lightPurple"))


                        
                        Text("create or join a private lobby to play with your friends")
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title3))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("darkPastelGray"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 5)
                    }
                    
                    Spacer()
                    
                    // Racing progress bars
                    VStack(spacing: device.valueByDevice(small: 25, normal: 30, ipad: 45)) {
                        RacingProgressBar(
                            backgroundColor: Color("errorRed"),
                            shadowColor: Color("darkPastelRed"),
                            currentProgress: player1Progress,
                            totalNodes: 10
                        )
                        
                        RacingProgressBar(
                            backgroundColor: Color("pastelBlue"),
                            shadowColor: Color("darkPastelBlue"),
                            currentProgress: player2Progress,
                            totalNodes: 10
                        )
                        
                        Text("be the first to the finish line")
                            .foregroundStyle(Color("darkPurple"))
                            .fontWeight(.heavy)
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title))
                    }
                    
                    Spacer()

                    VStack(spacing: device.valueByDevice(small: 25, normal: 30, ipad: 40)) {
                        

                        // Mode cards
                        VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 25)) {
                            // Create Lobby Card
                            ModeCard(
                                title: "create lobby",
                                iconName: "person.line.dotted.person.fill",
                                backgroundColor: Color("pastelGreen"),
                                shadowColor: Color("darkPastelGreen"),
                                action: {
                                    showingCreateLobby = true
                                }
                            )

                            // Join Lobby Card
                            ModeCard(
                                title: "join lobby",
                                iconName: "number.square.fill",
                                backgroundColor: Color("pastelBlue"),
                                shadowColor: Color("darkPastelBlue"),
                                action: {
                                    showingJoinLobby = true
                                }
                            )
                        }
                    }

                    // Bottom actions
                    VStack(spacing: 35) {
                        Button(action: {
                            appModel.path.removeLast()
                        }) {
                            Text("back to home")
                                .foregroundStyle(Color("darkPurple"))
                                .font(.headline)
                                .fontWeight(.heavy)
                        }
                    }
                }
                .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            }
        } //: ZStack
        .onAppear {
            if authInfo.user != nil {
                startRacingAnimation()
            }
        }
        .onDisappear {
            if authInfo.user != nil {
                stopRacingAnimation()
            }
        }
        .onChange(of: showingJoinLobby) { _, new in
            if authInfo.user != nil {
                if new {
                    // Sheet appeared - stop animations
                    stopRacingAnimation()
                } else {
                    // Sheet dismissed - resume animations
                    startRacingAnimation()
                }
            }
        }
        .onChange(of: showingCreateLobby) { _, new in
            if authInfo.user != nil {
                if new {
                    // Sheet appeared - stop animations
                    stopRacingAnimation()
                } else {
                    // Sheet dismissed - resume animations
                    startRacingAnimation()
                }
            }
        }
        .fullScreenCover(isPresented: $showingJoinLobby, content: {
            EnterCodeView()
        })
        .fullScreenCover(isPresented: $showingCreateLobby, content: {
            CreatingLobbyView()
        })
    }
}

#Preview {
    GeometryReader { screen in
        CustomLobbyInfoView()
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(AuthInfoModel(user: User(id: 123, username: "andy.v", jwtToken: "123dkfja")))
            .environmentObject(NetworkMonitor())
    }
}
