//
//  ProgressNode.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct ProgressNode: View {

    let index: Int
    let currentProgress: Int
    let backgroundColor: Color
    let shadowColor: Color
    let nodeSize: CGFloat
    let isFinished: Bool

    @State private var isVisuallyCompleted: Bool = false

    @EnvironmentObject var device: DeviceModel

    private var shouldBeCompleted: Bool {
        index < currentProgress
    }
    
    init(index: Int, currentProgress: Int, backgroundColor: Color, shadowColor: Color, nodeSize: CGFloat?, isFinished: Bool) {
        self.index = index
        self.currentProgress = currentProgress
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.nodeSize = nodeSize ?? 40
        self.isFinished = isFinished
    }
    
    var actualBackgroundColor: Color {
        if isVisuallyCompleted {
            if isFinished {
                return Color("gold")
            }
            
            return self.backgroundColor
        }
        
        return Color("silver")
    }
    
    var actualShadowColor: Color {
        if isVisuallyCompleted {
            if isFinished {
                return Color("darkYellow")
            }
            
            return self.shadowColor
        }
        
        return Color.gray.opacity(0.4)
    }

    var body: some View {
        Circle()
            .fill(actualBackgroundColor)
            .frame(width: device.valueByDevice(small: nodeSize, normal: nodeSize, ipad: nodeSize + 20))
            .overlay(
                // Show checkmark for completed nodes
                isVisuallyCompleted ?
                    Image(systemName: "checkmark")
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title))
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                    : nil
            )
            .overlay(
                // Show number for uncompleted nodes
                !isVisuallyCompleted ?
                    Text("\(index + 1)")
                        .fontWeight(.bold)
                        .foregroundStyle(Color("darkPurple"))
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title))
                    : nil
            )
            .clipped()
            .shadow(
                color: actualShadowColor,
                radius: 0,
                x: 0,
                y: device.valueByDevice(small: 3, normal: 3, ipad: 5)
            )
            .id(index)
            .onChange(of: shouldBeCompleted) { newValue in
                if newValue {
                    // Delay the node completion to let the connecting line animate first
                    Task {
                        try? await Task.sleep(nanoseconds: 100_000_000) // 0.3 seconds (line animation duration)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isVisuallyCompleted = true
                        }
                    }
                } else {
                    // Reset immediately when going back
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isVisuallyCompleted = false
                    }
                }
            }
            .onAppear {
                // Initialize the state based on current progress
                isVisuallyCompleted = shouldBeCompleted
            }
    }
}

#Preview {
    GeometryReader { screen in
        HStack(spacing: 20) {
            ProgressNode(
                index: 0,
                currentProgress: 3,
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple"),
                nodeSize: nil,
                isFinished: true
            )

            ProgressNode(
                index: 2,
                currentProgress: 3,
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple"),
                nodeSize: nil,
                isFinished: false
            )

            ProgressNode(
                index: 5,
                currentProgress: 3,
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple"),
                nodeSize: nil,
                isFinished: true
            )
        }
        .padding(20)
        .environmentObject(DeviceModel(screen: screen))
    }
}
