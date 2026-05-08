//
//  ModeCard.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct ModeCard: View {

    let title: String
    let iconName: String
    let backgroundColor: Color
    let shadowColor: Color
    let action: () -> Void

    @EnvironmentObject var device: DeviceModel

    var body: some View {
        Button(action: {}, label: {
            VStack(alignment: .trailing, spacing: 10) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.bold)
                    .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))

                Image(systemName: iconName)
                    .font(device.valueByDevice(small: .largeTitle, normal: .largeTitle, ipad: Font.system(size: 45)))
                    .fontWeight(.bold)
                    .frame(height: device.valueByDevice(small: 32, normal: 32, ipad: 50))
            }
            .foregroundStyle(.white)
        })
        .padding(15)
        .raisedButton(
            cornerRadius: device.valueByDevice(small: 18, normal: 20, ipad: 20),
            backgroundColor: backgroundColor,
            shadowColor: shadowColor,
            shadowOffset: device.valueByDevice(small: 8, normal: 8, ipad: 12),
            action: action
        )
    }
}

#Preview {
    GeometryReader { screen in
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                ModeCard(
                    title: "addition",
                    iconName: "plus",
                    backgroundColor: Color("pastelPurple"),
                    shadowColor: Color("darkPastelPurple"),
                    action: {}
                )

                ModeCard(
                    title: "subtraction",
                    iconName: "minus",
                    backgroundColor: Color("pastelBlue"),
                    shadowColor: Color("darkPastelBlue"),
                    action: {}
                )
            }

            HStack(spacing: 15) {
                ModeCard(
                    title: "time trial",
                    iconName: "timer",
                    backgroundColor: Color("pastelPink"),
                    shadowColor: Color("darkPastelPink"),
                    action: {}
                )

                ModeCard(
                    title: "one vs one",
                    iconName: "figure.run",
                    backgroundColor: Color("pastelOrange"),
                    shadowColor: Color("darkPastelOrange"),
                    action: {}
                )
            }
        }
        .padding(20)
        .environmentObject(DeviceModel(screen: screen))
    }
}
