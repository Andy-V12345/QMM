//
//  MultiplayerInfoView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/20/25.
//

import SwiftUI

struct MultiplayerInfoView: View {
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel

    @State private var player1Progress: Int = 0
    @State private var player2Progress: Int = 0
    @State private var winner: String? = nil
    @State private var player1AnimationTask: Task<Void, Never>?
    @State private var player2AnimationTask: Task<Void, Never>?

    let gamePlayer: GamePlayer
    
    
    init(gamePlayer: GamePlayer) {
        self.gamePlayer = gamePlayer
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
            
            VStack(spacing: 30) {
                VStack {
                    Text("welcome to")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color("darkPurple"))
                        .font(device.valueByDevice(small: .headline, normal: .title2, ipad: .title))
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
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 5) {
                            Text("wins")
                                .foregroundStyle(Color("correctGreen"))
                                .fontWeight(.bold)
                                .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("\(authInfo.user?.stats?.wins ?? 0)")
                                .foregroundStyle(Color("darkPurple"))
                                .fontWeight(.heavy)
                                .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                        .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                        .frame(maxWidth: .infinity)
                        .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                        
                        VStack(spacing: 5) {
                            Text("losses")
                                .foregroundStyle(Color("errorRed"))
                                .fontWeight(.bold)
                                .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("\(authInfo.user?.stats?.losses ?? 0)")
                                .foregroundStyle(Color("darkPurple"))
                                .fontWeight(.heavy)
                                .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, device.valueByDevice(small: 15, normal: 15, ipad: 20))
                        .padding(.vertical, device.valueByDevice(small: 12, normal: 12, ipad: 17))
                        .frame(maxWidth: .infinity)
                        .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                        
                        VStack(spacing: 5) {
                            Text("best")
                                .foregroundStyle(Color("lightPurple"))
                                .fontWeight(.bold)
                                .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(authInfo.user!.stats!.bestTime != nil ?  String(format: "%.1fs", Double(authInfo.user!.stats!.bestTime!) / 10.0) : "--")
                                .foregroundStyle(Color("darkPurple"))
                                .fontWeight(.heavy)
                                .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, device.valueByDevice(small: 15, normal: 15, ipad: 20))
                        .padding(.vertical, device.valueByDevice(small: 12, normal: 12, ipad: 17))
                        .frame(maxWidth: .infinity)
                        .raisedButton(cornerRadius: 15, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                        
                    }
                    .padding(.top, 5)
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
                    .raisedButton(impactStrength: .heavy, cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 11, normal: 11, ipad: 13),
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
        } //: ZStack
        .onAppear {
            startRacingAnimation()
        }
        .onDisappear {
            stopRacingAnimation()
        }
        .onChange(of: appModel.findingGame, perform: { new in
            if new {
                // Sheet appeared - stop animations
                stopRacingAnimation()
            } else {
                // Sheet dismissed - resume animations
                startRacingAnimation()
            }
        })
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

#Preview {
    return (
        GeometryReader { screen in
            MultiplayerInfoView(gamePlayer: GamePlayer(uid: "123", displayName: "andy.v123"))
                .environmentObject(DeviceModel(screen: screen))
                .environmentObject(AppModel(path: NavigationPath()))
                .environmentObject(AuthInfoModel())
        }
    )
}
