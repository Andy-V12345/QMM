//
//  RacingProgressBar.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct RacingProgressBar: View {
    
    let playerName: String
    let backgroundColor: Color
    let shadowColor: Color
    let currentProgress: Int
    
    @EnvironmentObject var device: DeviceModel
    
    private let totalNodes = 10

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<totalNodes, id: \.self) { index in
                        // Progress node
                        ProgressNode(
                            index: index,
                            currentProgress: currentProgress,
                            backgroundColor: backgroundColor,
                            shadowColor: shadowColor
                        )

                        // Connecting line (if not the last node)
                        if index < totalNodes - 1 {
                            ConnectingLine(
                                index: index,
                                currentProgress: currentProgress,
                                backgroundColor: backgroundColor,
                                shadowColor: shadowColor
                            )
                        }
                    }
                    
                    //                        // Final connecting line to flag
                    //                        Capsule()
                    //                            .fill(currentProgress >= totalNodes ? backgroundColor : Color("silver"))
                    //                            .frame(width: device.valueByDevice(small: 40, normal: 50, ipad: 70),
                    //                                   height: device.valueByDevice(small: 6, normal: 8, ipad: 12))
                    //                            .shadow(color: currentProgress >= totalNodes ? shadowColor : Color.gray.opacity(0.4),
                    //                                    radius: 0,
                    //                                    x: 0,
                    //                                    y: device.valueByDevice(small: 3, normal: 4, ipad: 5))
                    //
                    //                        // Checkered flag at the end
                    //                        Image(systemName: "flag")
                    //                            .font(device.valueByDevice(small: .largeTitle, normal: Font.system(size: 45), ipad: Font.system(size: 65)))
                    //                            .foregroundStyle(currentProgress >= totalNodes ? Color("gold") : Color.gray.opacity(0.3))
                    //                            .id("flag")
                }
                .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 15))
            }
            .onChange(of: currentProgress) { newProgress in
                withAnimation(.easeInOut(duration: 0.3)) {
                    if newProgress > 0 && newProgress <= totalNodes {
                        proxy.scrollTo(newProgress - 1, anchor: .center)
                    } else if newProgress > totalNodes {
                        //                            proxy.scrollTo("flag", anchor: .center)
                    }
                }
            }
        }
    }
}

#Preview {
    GeometryReader { screen in
        VStack(spacing: 30) {
            RacingProgressBar(
                playerName: "Player 1",
                backgroundColor: Color("lighterPurple"),
                shadowColor: Color("lightPurple"),
                currentProgress: 3
            )
            
            RacingProgressBar(
                playerName: "Player 2",
                backgroundColor: Color("pastelBlue"),
                shadowColor: Color("darkPastelBlue"),
                currentProgress: 10
            )
        }
        .padding(20)
        .environmentObject(DeviceModel(screen: screen))
    }
}
