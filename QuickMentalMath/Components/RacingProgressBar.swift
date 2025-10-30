//
//  RacingProgressBar.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

enum PlayerConnectionStatus: String {
    case CONNECTED = "connected", DISCONNECTED = "disconnected"
}

struct RacingProgressBar: View {
    
    let playerName: String?
    let backgroundColor: Color
    let shadowColor: Color
    let currentProgress: Int
    let totalNodes: Int
    let playerConnection: PlayerConnectionStatus
    let nodeSize: CGFloat?
    
    init(playerName: String, playerConnection: PlayerConnectionStatus, backgroundColor: Color, shadowColor: Color, currentProgress: Int, totalNodes: Int) {
        self.playerName = playerName
        self.playerConnection = playerConnection
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.currentProgress = currentProgress
        self.totalNodes = totalNodes
        self.nodeSize = nil
    }
    
    init(playerName: String, playerConnection: PlayerConnectionStatus, backgroundColor: Color, shadowColor: Color, currentProgress: Int, totalNodes: Int, nodeSize: CGFloat) {
        self.playerName = playerName
        self.playerConnection = playerConnection
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.currentProgress = currentProgress
        self.totalNodes = totalNodes
        self.nodeSize = nodeSize
    }
    
    init(backgroundColor: Color, shadowColor: Color, currentProgress: Int, totalNodes: Int) {
        self.playerName = nil
        self.playerConnection = .CONNECTED
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.currentProgress = currentProgress
        self.totalNodes = totalNodes
        self.nodeSize = nil
    }
    
    var isFinished: Bool {
        currentProgress == totalNodes
    }

    @EnvironmentObject var device: DeviceModel
    

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 2) {
                if let name = playerName {
                    HStack {
                        Text(name)
                            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                            .foregroundStyle(Color("darkPurple"))
                            .fontWeight(.heavy)
                            .opacity(playerConnection == .CONNECTED ? 1 : 0.5)
                        
                        Circle()
                            .fill(Color(playerConnection == .CONNECTED ? "correctGreen" : "errorRed"))
                            .frame(width: device.valueByDevice(small: 8, normal: 8, ipad: 10))
                        
                        Spacer()
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(0..<totalNodes, id: \.self) { index in
                            // Progress node
                            ProgressNode(
                                index: index,
                                currentProgress: currentProgress,
                                backgroundColor: backgroundColor,
                                shadowColor: shadowColor,
                                nodeSize: nodeSize,
                                isFinished: isFinished,
                                totalNodes: totalNodes
                            )

                            // Connecting line (if not the last node)
                            if index < totalNodes - 1 {
                                ConnectingLine(
                                    index: index,
                                    currentProgress: currentProgress,
                                    backgroundColor: backgroundColor,
                                    shadowColor: shadowColor,
                                    isFinished: isFinished,
                                    totalNodes: totalNodes
                                )
                            }
                        }
                    }
                    .padding(.vertical, device.valueByDevice(small: 5, normal: 8, ipad: 15))
                }
                .onChange(of: currentProgress) { _, newProgress in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if newProgress > 0 && newProgress <= totalNodes {
                            proxy.scrollTo(newProgress - 1, anchor: .center)
                        }
                    }
                }
            } //: VStack
        }
    }
}

#Preview {
    GeometryReader { screen in
        VStack(spacing: 30) {
            RacingProgressBar(
                playerName: "Bobby123",
                playerConnection: .DISCONNECTED,
                backgroundColor: Color("errorRed"),
                shadowColor: Color("darkErrorRed"),
                currentProgress: 3,
                totalNodes: 10
            )
            
            RacingProgressBar(
                playerName: "you",
                playerConnection: .CONNECTED,
                backgroundColor: Color("pastelBlue"),
                shadowColor: Color("darkPastelBlue"),
                currentProgress: 7,
                totalNodes: 10
            )
        }
        .padding(20)
        .environmentObject(DeviceModel(screen: screen))
    }
}
