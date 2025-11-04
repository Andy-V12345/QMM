//
//  EndGameResultsList.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI
import ConfettiSwiftUI

struct EndGameResultsList: View {
    @EnvironmentObject var device: DeviceModel

    let sortedPlayers: [(player: GamePlayer, timeMs: Int64?, position: Int)]
    let isWinner: Bool
    @Binding var confettiTrigger: Int
    @Binding var isConfettiOnCooldown: Bool
    let currentUserId: Int
    let playAgainReady: [String: Bool]?
    let isCustomGame: Bool

    init(
        sortedPlayers: [(player: GamePlayer, timeMs: Int64?, position: Int)],
        isWinner: Bool,
        confettiTrigger: Binding<Int>,
        isConfettiOnCooldown: Binding<Bool>,
        currentUserId: Int,
    ) {
        self.sortedPlayers = sortedPlayers
        self.isWinner = isWinner
        self._confettiTrigger = confettiTrigger
        self._isConfettiOnCooldown = isConfettiOnCooldown
        self.currentUserId = currentUserId
        self.playAgainReady = nil
        self.isCustomGame = false
    }
    
    init(
        sortedPlayers: [(player: GamePlayer, timeMs: Int64?, position: Int)],
        isWinner: Bool,
        confettiTrigger: Binding<Int>,
        isConfettiOnCooldown: Binding<Bool>,
        currentUserId: Int,
        playAgainReady: [String: Bool]?,
        isCustomGame: Bool
    ) {
        self.sortedPlayers = sortedPlayers
        self.isWinner = isWinner
        self._confettiTrigger = confettiTrigger
        self._isConfettiOnCooldown = isConfettiOnCooldown
        self.currentUserId = currentUserId
        self.playAgainReady = playAgainReady
        self.isCustomGame = isCustomGame
    }

    var body: some View {
        ScrollView {
            VStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                Text("results")
                    .foregroundStyle(Color("lightPurple"))
                    .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.bold)

                VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                    ForEach(sortedPlayers, id: \.player.uid) { item in
                        let isCurrentUser = item.player.uid == String(currentUserId)

                        HStack(spacing: 15) {
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
                                        .lineLimit(1)
                                } else {
                                    Text("--")
                                        .fontWeight(.heavy)
                                        .lineLimit(1)

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
                            
                            if isCustomGame {
                                let status = playAgainReady?[item.player.uid]
                                
                                if status == nil {
                                    AnimatedCheckmark(size: 25, color: Color("lightGray"), strokeWidth: 2.5)
                                }
                                else if status == true {
                                    AnimatedCheckmark(size: 25, strokeWidth: 2.5)
                                }
                                else if status == false {
                                    AnimatedErrorMark(size: 25, strokeWidth: 2.5)
                                }
                            }
                        } //: VStack
                    }
                }
            } //: VStack
            .padding(.trailing, isCustomGame ? 3 : 0)

        } //: ScrollView
        .scrollIndicators(.hidden)
        .padding(.bottom, 10)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var confettiTrigger = 0
        @State private var isConfettiOnCooldown = false

        var body: some View {
            GeometryReader { screen in
                EndGameResultsList(
                    sortedPlayers: [
                        (
                            player: GamePlayer(uid: "652", displayName: "andy.v123"),
                            timeMs: 45300,
                            position: 1
                        ),
                        (
                            player: GamePlayer(uid: "789", displayName: "MathWizard42"),
                            timeMs: 52100,
                            position: 2
                        )
                    ],
                    isWinner: true,
                    confettiTrigger: $confettiTrigger,
                    isConfettiOnCooldown: $isConfettiOnCooldown,
                    currentUserId: 789, playAgainReady: ["652": true, "719": false], isCustomGame: true
                )
                .environmentObject(DeviceModel(screen: screen))
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
