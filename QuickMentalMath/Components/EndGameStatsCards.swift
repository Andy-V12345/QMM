//
//  EndGameStatsCards.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct EndGameStatsCards: View {
    @EnvironmentObject var device: DeviceModel

    let isWinner: Bool
    let updatedStats: UserStats?
    let isNewBestTime: Bool

    var body: some View {
        VStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
            Text("updated stats")
                .foregroundStyle(Color("lightPurple"))
                .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fontWeight(.bold)

            HStack(spacing: device.valueByDevice(small: 8, normal: 12, ipad: 12)) {
                // Wins Card
                VStack(spacing: 5) {
                    Text("wins")
                        .foregroundStyle(isWinner ? Color("offWhite") : Color("correctGreen"))
                        .fontWeight(.bold)
                        .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("\(updatedStats?.wins ?? 0)")
                        .foregroundStyle(Color("darkPurple"))
                        .fontWeight(.heavy)
                        .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
                .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                .frame(maxWidth: .infinity)
                .raisedButton(
                    cornerRadius: 15,
                    backgroundColor: isWinner ? Color("correctGreen") : Color("offWhite"),
                    shadowColor: isWinner ? Color("darkPastelGreen") : Color.gray.opacity(0.4),
                    shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8),
                    action: {}
                )

                // Losses Card
                VStack(spacing: 5) {
                    Text("losses")
                        .foregroundStyle(isWinner == false ? Color("offWhite") : Color("errorRed"))
                        .fontWeight(.bold)
                        .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("\(updatedStats?.losses ?? 0)")
                        .foregroundStyle(Color("darkPurple"))
                        .fontWeight(.heavy)
                        .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
                .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                .frame(maxWidth: .infinity)
                .raisedButton(
                    cornerRadius: 15,
                    backgroundColor: isWinner == false ? Color("errorRed") : Color("offWhite"),
                    shadowColor: isWinner == false ? Color("darkErrorRed") : Color.gray.opacity(0.4),
                    shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8),
                    action: {}
                )

                // Best Time Card
                VStack(spacing: 5) {
                    Text(isNewBestTime ? "new best" : "best")
                        .foregroundStyle(isNewBestTime ? Color("offWhite") : Color("lightPurple"))
                        .fontWeight(.bold)
                        .font(device.valueByDevice(small: .subheadline, normal: .body, ipad: .title2))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(updatedStats?.bestTime != nil ? String(format: "%.1fs", Double(updatedStats!.bestTime!) / 10.0) : "--")
                        .foregroundStyle(Color("darkPurple"))
                        .fontWeight(.heavy)
                        .font(device.valueByDevice(small: .title, normal: .title, ipad: Font.system(size: 45)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                }
                .padding(.horizontal, device.valueByDevice(small: 12, normal: 15, ipad: 20))
                .padding(.vertical, device.valueByDevice(small: 10, normal: 12, ipad: 17))
                .frame(maxWidth: .infinity)
                .raisedButton(
                    cornerRadius: 15,
                    backgroundColor: isNewBestTime ? Color("lighterPurple") : Color("offWhite"),
                    shadowColor: isNewBestTime ? Color("lightPurple") : Color.gray.opacity(0.4),
                    shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8),
                    action: {}
                )
            }
        }
    }
}
