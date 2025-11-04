//
//  EndGameActionButtons.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct EndGameActionButtons: View {
    @EnvironmentObject var device: DeviceModel

    let endGameModel: MultiplayerEndGameModel
    let handlePlayAgain: () -> Void
    let handleBackToHome: () -> Void

    var body: some View {
        VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
            // Play Again Button
            Button(action: {}, label: {
                let customModel = endGameModel as? CustomMultiplayerEndGameModel
                let buttonText: String = {
                    if let custom = customModel {
                        return custom.hasMarkedReady ? "waiting for others..." : "play again"
                    } else {
                        return "play again"
                    }
                }()

                Text(buttonText)
                    .foregroundStyle(Color("darkPurple"))
                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                    .fontWeight(.heavy)
                    .opacity((customModel?.hasMarkedReady ?? false) ? 0.5 : 1.0)
            })
            .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(
                impactStrength: .heavy,
                cornerRadius: device.valueByDevice(small: 18, normal: 20, ipad: 20),
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple"),
                shadowOffset: device.valueByDevice(small: 8, normal: 8, ipad: 12),
                action: handlePlayAgain
            )
            .disabled((endGameModel as? CustomMultiplayerEndGameModel)?.hasMarkedReady ?? false)

            // Back to Home Button
            Button(action: handleBackToHome, label: {
                Text("back to home")
                    .foregroundStyle(Color("darkPurple"))
            })
            .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
            .fontWeight(.heavy)
        }
    }
}
