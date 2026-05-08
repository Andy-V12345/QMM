//
//  LobbyStatusDisplay.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/29/25.
//

import SwiftUI

struct LobbyStatusDisplay: View {
    @EnvironmentObject var device: DeviceModel

    let isHost: Bool
    let lobbyState: LobbyState
    let isJoiningGame: Bool
    let errorMsg: String?
    let retry: @MainActor () -> Void

    init(isHost: Bool, lobbyState: LobbyState, isJoiningGame: Bool, errorMsg: String?, retry: @escaping @MainActor () -> Void) {
        self.isHost = isHost
        self.lobbyState = lobbyState
        self.isJoiningGame = isJoiningGame
        self.errorMsg = errorMsg
        self.retry = retry
    }
    
    init(isHost: Bool, lobbyState: LobbyState, isJoiningGame: Bool, errorMsg: String?) {
        self.isHost = isHost
        self.lobbyState = lobbyState
        self.isJoiningGame = isJoiningGame
        self.errorMsg = errorMsg
        self.retry = { @MainActor in }
    }

    var body: some View {
        if let error = errorMsg {
            VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                AnimatedErrorMark(size: device.valueByDevice(small: 55, normal: 60, ipad: 100), strokeWidth: device.valueByDevice(small: 4.25, normal: 4.5, ipad: 8))

                Text(error)
                    .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color("darkPurple"))
                
                Button(action: {}, label: {
                    Text("retry")
                        .foregroundStyle(Color("offWhite"))
                        .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        .fontWeight(.bold)
                        .padding(.horizontal, device.valueByDevice(small: 12, normal: 14, ipad: 16))
                        .padding(.vertical, 4)
                        .raisedButton(
                            cornerRadius: 12,
                            backgroundColor: Color("errorRed"),
                            shadowColor: Color("darkErrorRed"),
                            shadowOffset: device.valueByDevice(small: 3, normal: 4, ipad: 6),
                            action: {
                                // Reset error state and retry
                                retry()
                            }
                        )
                })
            }
        }
        else if isJoiningGame {
            VStack(spacing: 30) {
                BouncingDotsLoader(dotSize: device.valueByDevice(small: 11, normal: 12, ipad: 12))

                Text("joining game...")
                    .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color("darkPurple"))
            }
        } else if lobbyState == .WAITING {
            VStack(spacing: 30) {
                BouncingDotsLoader(dotSize: device.valueByDevice(small: 11, normal: 12, ipad: 12))

                Text("waiting for players...")
                    .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color("darkPurple"))
            }
        } else if lobbyState == .READY {
            if isHost {
                VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                    AnimatedCheckmark(size: device.valueByDevice(small: 55, normal: 60, ipad: 100), strokeWidth: device.valueByDevice(small: 4.25, normal: 4.5, ipad: 8))

                    Text("ready to go")
                        .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                        .fontWeight(.heavy)
                        .foregroundStyle(Color("darkPurple"))
                }
            } else {
                VStack(spacing: 30) {
                    BouncingDotsLoader(dotSize: device.valueByDevice(small: 11, normal: 12, ipad: 12))

                    Text("waiting for host...")
                        .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                        .fontWeight(.heavy)
                        .foregroundStyle(Color("darkPurple"))
                }
            }
        }
        else if lobbyState == .CANCELLED {
            VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                AnimatedErrorMark(size: device.valueByDevice(small: 55, normal: 60, ipad: 100), strokeWidth: device.valueByDevice(small: 4.25, normal: 4.5, ipad: 8))

                Text("host canceled")
                    .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                    .fontWeight(.heavy)
                    .foregroundStyle(Color("darkPurple"))
            }
        }
    }
}

#Preview {
    GeometryReader { screen in
        VStack(spacing: 40) {
            // Host ready state
            LobbyStatusDisplay(
                isHost: true,
                lobbyState: .READY,
                isJoiningGame: false,
                errorMsg: nil
            )
            .environmentObject(DeviceModel(screen: screen))

            // Guest waiting for host
            LobbyStatusDisplay(
                isHost: false,
                lobbyState: .READY,
                isJoiningGame: false,
                errorMsg: nil
            )
            .environmentObject(DeviceModel(screen: screen))

            // Waiting for players
            LobbyStatusDisplay(
                isHost: false,
                lobbyState: .READY,
                isJoiningGame: true,
                errorMsg: "failed to join game"
            )
            .environmentObject(DeviceModel(screen: screen))
        }
    }
}
