//
//  ConnectingLine.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct ConnectingLine: View {

    let index: Int
    let currentProgress: Int
    let backgroundColor: Color
    let shadowColor: Color

    @EnvironmentObject var device: DeviceModel

    private var lineWidth: CGFloat {
        device.valueByDevice(small: 40, normal: 50, ipad: 70)
    }

    private var lineHeight: CGFloat {
        device.valueByDevice(small: 6, normal: 8, ipad: 12)
    }

    private var isFilled: Bool {
        index < currentProgress - 1
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Background (unfilled)
            Capsule()
                .fill(Color("silver"))
                .frame(width: lineWidth, height: lineHeight)
                .shadow(
                    color: Color.gray.opacity(0.4),
                    radius: 0,
                    x: 0,
                    y: device.valueByDevice(small: 3, normal: 4, ipad: 5)
                )

            // Foreground (filled portion - animates from left to right)
            Capsule()
                .fill(backgroundColor)
                .frame(width: isFilled ? lineWidth : 0, height: lineHeight)
                .shadow(
                    color: isFilled ? shadowColor : Color.clear,
                    radius: 0,
                    x: 0,
                    y: device.valueByDevice(small: 2, normal: 3, ipad: 4)
                )
        }
        .frame(width: lineWidth, height: lineHeight)
    }
}

#Preview {
    GeometryReader { screen in
        HStack(spacing: 20) {
            ConnectingLine(
                index: 0,
                currentProgress: 3,
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple")
            )

            ConnectingLine(
                index: 2,
                currentProgress: 3,
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple")
            )

            ConnectingLine(
                index: 5,
                currentProgress: 3,
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple")
            )
        }
        .padding(20)
        .environmentObject(DeviceModel(screen: screen))
    }
}
