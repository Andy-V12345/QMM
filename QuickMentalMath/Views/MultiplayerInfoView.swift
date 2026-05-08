//
//  MultiplayerInfoView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/20/25.
//

import SwiftUI
import EasySkeleton

struct MultiplayerInfoView: View {
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var networkMonitor: NetworkMonitor

    @State private var player1Progress: Int = 0
    @State private var player2Progress: Int = 0
    @State private var winner: String? = nil
    @State private var player1AnimationTask: Task<Void, Never>?
    @State private var player2AnimationTask: Task<Void, Never>?

    // Local stats state
    @State private var userStats: UserStats?
    @State private var isLoadingStats: Bool = true
    @State private var isErrorFetchingStats = false
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0

    let gamePlayer: GamePlayer
    
    
    init(gamePlayer: GamePlayer) {
        self.gamePlayer = gamePlayer
    }

    private func fetchUserStats() async {
        guard let user = authInfo.user else { return }

        do {
            if let stats = try await AuthService.loadUserStats(userId: user.id, jwtToken: user.jwtToken) {
                await MainActor.run {
                    userStats = stats
                    isLoadingStats = false
                }
            } else {
                await MainActor.run {
                    isLoadingStats = false
                }
            }
        }
        catch {
            await MainActor.run {
                isErrorFetchingStats = true
                isLoadingStats = false
            }
        }
    }

    private func reset() async {
        // Reset after reaching the end
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second pause
        
        withAnimation(.easeInOut(duration: 0.1)) {
            player1Progress = 1
            player2Progress = 1
            
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Check if connected to wifi
            if !networkMonitor.isConnected {
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
                VStack(spacing: 30) {
                VStack {
                    Text("welcome to")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color("darkPurple"))
                        .font(device.valueByDevice(small: .headline, normal: .title2, ipad: .title))
                        .fontWeight(.bold)
                    
                    HStack(spacing: 15) {
                        Text("one v one")
                            .font(device.valueByDevice(small: .title, normal: .largeTitle, ipad: .largeTitle))
                            .fontWeight(.heavy)
                        
                        Image(systemName: "figure.run")
                            .font(.title)
                            .bold()
                        
                        Spacer()
                    }
                    .foregroundStyle(Color("lightPurple"))

                    if !isErrorFetchingStats {
                        HStack(spacing: device.valueByDevice(small: 8, normal: 8, ipad: 12)) {
                            VStack(spacing: 5) {
                                Text("wins")
                                    .foregroundStyle(Color("correctGreen"))
                                    .fontWeight(.bold)
                                    .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .skeletonable()

                                Text("\(userStats?.wins ?? 0)")
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.heavy)
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .skeletonable()
                            }
                            .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                            .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                            .setSkeleton(
                                $isLoadingStats,
                                animationType: .gradient([
                                    Color("correctGreen").opacity(0.3),
                                    Color("correctGreen").opacity(0.2),
                                    Color("correctGreen").opacity(0.3)
                                ]),
                                animation: Animation.linear(duration: 0.2).repeatForever(autoreverses: false),
                                cornerRadius: 8
                            )

                            VStack(spacing: 5) {
                                Text("losses")
                                    .foregroundStyle(Color("errorRed"))
                                    .fontWeight(.bold)
                                    .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .skeletonable()

                                Text("\(userStats?.losses ?? 0)")
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.heavy)
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .skeletonable()
                            }
                            .padding(.horizontal, device.valueByDevice(small: 15, normal: 15, ipad: 20))
                            .padding(.vertical, device.valueByDevice(small: 12, normal: 12, ipad: 17))
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                            .setSkeleton(
                                $isLoadingStats,
                                animationType: .gradient([
                                    Color("errorRed").opacity(0.3),
                                    Color("errorRed").opacity(0.2),
                                    Color("errorRed").opacity(0.3)
                                ]),
                                animation: Animation.linear(duration: 0.2).repeatForever(autoreverses: false),
                                cornerRadius: 8
                            )

                            VStack(spacing: 5) {
                                Text("best")
                                    .foregroundStyle(Color("lightPurple"))
                                    .fontWeight(.bold)
                                    .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .skeletonable()

                                Text(userStats?.bestTime != nil ?  String(format: "%.1fs", Double(userStats!.bestTime!) / 10.0) : "--")
                                    .foregroundStyle(Color("darkPurple"))
                                    .fontWeight(.heavy)
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .skeletonable()
                            }
                            .padding(.horizontal, device.valueByDevice(small: 15, normal: 15, ipad: 20))
                            .padding(.vertical, device.valueByDevice(small: 12, normal: 12, ipad: 17))
                            .frame(maxWidth: .infinity)
                            .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                            .setSkeleton(
                                $isLoadingStats,
                                animationType: .gradient([
                                    Color("lightPurple").opacity(0.3),
                                    Color("lightPurple").opacity(0.2),
                                    Color("lightPurple").opacity(0.3)
                                ]),
                                animation: Animation.linear(duration: 0.2).repeatForever(autoreverses: false),
                                cornerRadius: 8
                            )
                        }
                        .padding(.top, 5)
                    } else {
                        VStack(spacing: 15) {
                            Text("failed to load stats")
                                .foregroundStyle(Color("errorRed"))
                                .fontWeight(.semibold)
                                .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))

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
                                            isErrorFetchingStats = false
                                            isLoadingStats = true
                                            Task {
                                                await fetchUserStats()
                                            }
                                        }
                                    )
                            })
                        }
                        .padding(.top, 20)
                    }
                } //: Text Title VStack
                
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
                
                VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                    Button(action: {}, label: {
                        Text("find a game")
                            .foregroundStyle(Color("darkPurple"))
                            .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                            .fontWeight(.heavy)
                    })
                    .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
                    .frame(maxWidth: .infinity)
                    .raisedButton(impactStrength: .heavy, cornerRadius: device.valueByDevice(small: 18, normal: 20, ipad: 20), backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 8, normal: 8, ipad: 12),
                                  action: {
                        
                        appModel.findingGame = true
                    })
                    //: Start Button
                    
                    Button(action: {
                        appModel.path.removeLast()
                    }, label: {
                        Text("back to home")
                            .foregroundStyle(Color("darkPurple"))
                    })
                    .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                    .fontWeight(.heavy)
                }
            }
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            } // else
        } //: ZStack
        .onAppear {
            if authInfo.user != nil {
                startRacingAnimation()
                Task {
                    await fetchUserStats()
                }
            }
        }
        .onDisappear {
            if authInfo.user != nil {
                stopRacingAnimation()
            }
        }
        .onChange(of: appModel.findingGame) { _, new in
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
}

// Preview wrapper to show stats error state
private struct MultiplayerInfoErrorPreview: View {
    @State private var isErrorFetchingStats = true
    @State private var isLoadingStats = false

    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 30) {
                    VStack {
                        Text("welcome to")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("darkPurple"))
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 15) {
                            Text("one v one")
                                .font(.largeTitle)
                                .fontWeight(.heavy)

                            Image(systemName: "figure.run")
                                .font(.title)
                                .bold()

                            Spacer()
                        }
                        .foregroundStyle(Color("lightPurple"))

                        if isErrorFetchingStats {
                            VStack(spacing: 15) {
                                Text("failed to load stats")
                                    .foregroundStyle(Color("errorRed"))
                                    .fontWeight(.semibold)
                                    .font(.body)

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
                                                isErrorFetchingStats = false
                                            }
                                        )
                                })
                            }
                            .padding(.top, 20)
                        }
                    }

                    Spacer()
                }
                .padding(15)
            }
            .environmentObject(DeviceModel(screen: screen))
        }
    }
}

#Preview("Stats Error State") {
    MultiplayerInfoErrorPreview()
}

#Preview("Not Signed In") {
    GeometryReader { screen in
        MultiplayerInfoView(gamePlayer: GamePlayer(uid: "123", displayName: "andy.v123"))
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(AuthInfoModel()) // No user, so will show sign-in error
    }
}

#Preview("Normal State") {
    let userStats = UserStats(id: 0, additionScore: 20, additionTot: 40, subtractionScore: 10, subtractionTot: 30, multiplicationScore: 0, multiplicationTot: 0, divisionScore: 10, divisionTot: 50, highScore: 45, ttHighScore: 100, wins: 5, losses: 3, bestTime: 247)
    let user = User(id: 0, username: "Andyv123", jwtToken: "token", stats: userStats)
    let authInfo = AuthInfoModel(user: user)

    return (
        GeometryReader { screen in
            MultiplayerInfoView(gamePlayer: GamePlayer(uid: "123", displayName: "andy.v123"))
                .environmentObject(DeviceModel(screen: screen))
                .environmentObject(AppModel(path: NavigationPath()))
                .environmentObject(authInfo)
        }
    )
}
