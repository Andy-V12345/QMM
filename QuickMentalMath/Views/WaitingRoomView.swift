//
//  WaitingRoomView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/20/25.
//

import SwiftUI

struct WaitingRoomView: View {

    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var device: DeviceModel
    @State private var bounceOffset: CGFloat = 0
    @State private var selectedQuote: String = ""

    let quotes = [
        "your opponent is gonna be shook.",
        "finding you a worthy challenger.",
        "sharpening your mental math game.",
        "this is gonna be legendary.",
        "prepare to cook.",
        "about to witness some real competition.",
        "this matchup is about to go crazy."
    ]
    
    private func leaveQueue() {
        dismiss()
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 10) {
                Spacer()

                // Bouncing dots animation
                HStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 13)) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color("lightPurple"))
                            .frame(height: device.valueByDevice(small: 13, normal: 13, ipad: 20))
                            .offset(y: bounceOffset)
                            .animation(
                                Animation.interpolatingSpring(stiffness: 200, damping: 10)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.1),
                                value: bounceOffset
                            )
                    }
                }
                .padding(.bottom, 30)

                // Status text
                Text("finding a game")
                    .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color("darkPurple"))

                // Secondary text
                Text("give us a moment")
                    .font(device.valueByDevice(small: .body, normal: .headline, ipad: .title2))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("lightPurple"))

                // Quote
                
                
                Spacer()
                
                Text(selectedQuote)
                    .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                    .fontWeight(.medium)
                    .foregroundStyle(Color("darkPurple"))
                    .frame(maxWidth: .infinity)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)

                // Leave queue button
                Button(action: {}, label: {
                    Text("leave queue")
                        .foregroundStyle(Color("offWhite"))
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        .fontWeight(.semibold)
                })
                .padding(device.valueByDevice(small: 10, normal: 12, ipad: 14))
                .frame(maxWidth: .infinity)
                .raisedButton(
                    impactStrength: .medium,
                    cornerRadius: 20,
                    backgroundColor: Color("errorRed"),
                    shadowColor: Color("darkErrorRed"),
                    shadowOffset: device.valueByDevice(small: 8, normal: 10, ipad: 13),
                    action: {
                        leaveQueue()
                    }
                )
            }
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
        }
        .onAppear {
            bounceOffset = -15
            selectedQuote = quotes.randomElement() ?? quotes[0]
        }
    }
}

#Preview {
    return (
        GeometryReader { screen in
            WaitingRoomView()
                .environmentObject(DeviceModel(screen: screen))
        }
    )
    
}
