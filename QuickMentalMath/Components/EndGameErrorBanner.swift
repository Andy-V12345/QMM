//
//  EndGameErrorBanner.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct EndGameErrorBanner: View {
    @EnvironmentObject var device: DeviceModel

    let fetchErrors: [String]
    let isLoading: Bool

    var body: some View {
        if !fetchErrors.isEmpty && !isLoading {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.white)

                Text("failed to load some data")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title3))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .raisedButton(backgroundColor: Color("errorRed"), shadowColor: Color("darkErrorRed"), shadowOffset: 2, action: {})
            .allowsHitTesting(false)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
