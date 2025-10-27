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
    let isFinished: Bool
    let totalNodes: Int

    @State private var isFlashing: Bool = false
    @State private var flashTask: Task<Void, Never>?

    @EnvironmentObject var device: DeviceModel

    private var lineWidth: CGFloat {
        device.valueByDevice(small: 40, normal: 45, ipad: 70)
    }

    private var lineHeight: CGFloat {
        device.valueByDevice(small: 6, normal: 6, ipad: 12)
    }

    private var isFilled: Bool {
        index < currentProgress - 1
    }

    private var isInFinalStretch: Bool {
        totalNodes - currentProgress <= 5 && currentProgress < totalNodes && !isFinished
    }

    var actualShadowColor: Color {
        if isFilled {
            if isFinished {
                return Color("darkYellow")
            }

            if isInFinalStretch && isFlashing {
                return Color("darkYellow")
            }

            return shadowColor
        }

        return Color.clear
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
                    y: device.valueByDevice(small: 2, normal: 2, ipad: 3)
                )

            // Foreground (filled portion - animates from left to right)
            Capsule()
                .fill(isFinished ? Color("gold") : (isInFinalStretch && isFlashing ? Color("gold") : backgroundColor))
                .frame(width: isFilled ? lineWidth : 0, height: lineHeight)
                .shadow(
                    color: actualShadowColor,
                    radius: 0,
                    x: 0,
                    y: device.valueByDevice(small: 2, normal: 2, ipad: 3)
                )
        }
        .frame(width: lineWidth, height: lineHeight)
        .onAppear {
            // Start flashing if already in final stretch
            if isInFinalStretch {
                startFlashing()
            }
        }
        .onChange(of: currentProgress) { _ in
            // Check if we should be flashing
            if isInFinalStretch {
                if flashTask == nil {
                    startFlashing()
                }
            } else {
                stopFlashing()
            }
        }
        .onDisappear {
            stopFlashing()
        }
    }

    private func startFlashing() {
        flashTask?.cancel()
        flashTask = Task {
            while !Task.isCancelled && isInFinalStretch {
                try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s
                guard !Task.isCancelled else { break }
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFlashing.toggle()
                }
            }
        }
    }

    private func stopFlashing() {
        flashTask?.cancel()
        flashTask = nil
        isFlashing = false
    }
}

#Preview {
    GeometryReader { screen in
        HStack(spacing: 20) {
            ConnectingLine(
                index: 0,
                currentProgress: 3,
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple"),
                isFinished: true,
                totalNodes: 10

            )

            ConnectingLine(
                index: 2,
                currentProgress: 3,
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple"),
                isFinished: false,
                totalNodes: 10

            )

            ConnectingLine(
                index: 5,
                currentProgress: 3,
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple"),
                isFinished: true,
                totalNodes: 10

            )
        }
        .padding(20)
        .environmentObject(DeviceModel(screen: screen))
    }
}
