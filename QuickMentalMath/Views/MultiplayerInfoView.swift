//
//  MultiplayerInfoView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/20/25.
//

import SwiftUI

struct MultiplayerInfoView: View {
    @EnvironmentObject var device: DeviceModel
    
    @State private var player1Progress: Int = 0
    @State private var player2Progress: Int = 0
    @State private var winner: String? = nil
    
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
                } //: Text Title VStack
                
                
                // Racing progress bars
                VStack(spacing: device.valueByDevice(small: 30, normal: 35, ipad: 45)) {
                    RacingProgressBar(
                        playerName: "Player 1",
                        backgroundColor: Color("pastelRed"),
                        shadowColor: Color("darkPastelRed"),
                        currentProgress: player1Progress
                    )
                    
                    RacingProgressBar(
                        playerName: "Player 2",
                        backgroundColor: Color("pastelBlue"),
                        shadowColor: Color("darkPastelBlue"),
                        currentProgress: player2Progress
                    )
                    
                    Text("be the first to the finish line")
                        .foregroundStyle(Color("darkPurple"))
                        .fontWeight(.heavy)
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
                        
                        // TODO: find game
                    })
                    //: Start Button
                    
                    Button(action: {
                        // TODO: BACK TO HOME
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
    }
    
    // MARK: - Racing Animation Logic
    
    private func startRacingAnimation() {
        // Animate Player 1
        Task {
            while true {
                let randomDelay = Double.random(in: 0.7...1.3)
                try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000_000))
                
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
        Task {
            while true {
                let randomDelay = Double.random(in: 0.9...1.5)
                try? await Task.sleep(nanoseconds: UInt64(randomDelay * 1_000_000_000))
                
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
}

#Preview {
    return (
        GeometryReader { screen in
            MultiplayerInfoView()
                .environmentObject(DeviceModel(screen: screen))
        }
    )
}
