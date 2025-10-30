//
//  LobbyPlayerSlot.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI
import FirebaseFirestore

struct LobbyPlayerSlot: View {

    @EnvironmentObject var device: DeviceModel

    let player: LobbyPlayer?
    let hostUid: String

    private var text: String {
        if player == nil {
            return "f" // placeholder
        }

        if player!.uid == hostUid {
            return "\(player!.username) (host)"
        }

        return player!.username
    }

    private var bgColor: Color {
        if player == nil {
            return Color("lightGray").opacity(0.5)
        }

        if player!.uid == hostUid {
            return Color("gold")
        }

        return Color("offWhite")
    }

    private var shadowColor: Color {
        if player == nil {
            return Color.gray.opacity(0.4)
        }

        if player!.uid == hostUid {
            return Color("darkYellow")
        }

        return Color.gray.opacity(0.4)
    }

    var body: some View {
        Text(text)
            .fontWeight(.heavy)
            .lineLimit(1)
            .padding(.vertical, device.valueByDevice(small: 12, normal: 13, ipad: 20))
            .padding(.horizontal, device.valueByDevice(small: 15, normal: 20, ipad: 25))
            .font(device.valueByDevice(small: .body, normal: .title3, ipad: .title))
            .foregroundStyle(player == nil ? Color.clear : Color("darkPurple"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .raisedButton(
                cornerRadius: device.valueByDevice(small: 12, normal: 16, ipad: 20),
                backgroundColor: bgColor,
                shadowColor: shadowColor,
                shadowOffset: 5,
                action: {}
            )
            .disabled(player == nil)
    }
}

#Preview {
    GeometryReader { screen in
        VStack(spacing: 20) {
            // Host player
            LobbyPlayerSlot(
                player: LobbyPlayer(uid: "123", username: "andyv.123", joinedAt: FirebaseTimestamp(seconds: 100, nanos: 0)),
                hostUid: "123"
            )
            .environmentObject(DeviceModel(screen: screen))

            // Regular player
            LobbyPlayerSlot(
                player: LobbyPlayer(uid: "124", username: "johndoe", joinedAt: FirebaseTimestamp(seconds: 150, nanos: 0)),
                hostUid: "123"
            )
            .environmentObject(DeviceModel(screen: screen))

            // Empty slot
            LobbyPlayerSlot(
                player: nil,
                hostUid: "123"
            )
            .environmentObject(DeviceModel(screen: screen))
        }
        .padding()
    }
}
