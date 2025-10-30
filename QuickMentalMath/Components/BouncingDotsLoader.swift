//
//  BouncingDotsLoader.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI

struct BouncingDotsLoader: View {

    @EnvironmentObject var device: DeviceModel

    @State private var bounceOffset: CGFloat = 0

    var dotCount: Int = 3
    var dotSize: CGFloat? = nil
    var spacing: CGFloat? = nil
    var color: Color = Color("lightPurple")
    var animationDelay: Double = 0.1
    var bounceHeight: CGFloat = -15
    var stiffness: Double = 200
    var damping: Double = 10

    var body: some View {
        HStack(spacing: spacing ?? device.valueByDevice(small: 10, normal: 10, ipad: 13)) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(height: dotSize ?? device.valueByDevice(small: 13, normal: 13, ipad: 20))
                    .offset(y: bounceOffset)
                    .animation(
                        Animation.interpolatingSpring(stiffness: stiffness, damping: damping)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * animationDelay),
                        value: bounceOffset
                    )
            }
        }
        .onAppear {
            bounceOffset = bounceHeight
        }
    }
}

#Preview {
    GeometryReader { screen in
        VStack(spacing: 40) {
            // Default styling
            BouncingDotsLoader()
                .environmentObject(DeviceModel(screen: screen))

            // Custom color
            BouncingDotsLoader(color: .blue)
                .environmentObject(DeviceModel(screen: screen))

            // Custom size and spacing
            BouncingDotsLoader(dotCount: 5, dotSize: 20, spacing: 15, color: .green)
                .environmentObject(DeviceModel(screen: screen))

            // Faster animation
            BouncingDotsLoader(color: .red, animationDelay: 0.05)
                .environmentObject(DeviceModel(screen: screen))
        }
    }
}
