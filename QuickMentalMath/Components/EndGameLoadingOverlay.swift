//
//  EndGameLoadingOverlay.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct EndGameLoadingOverlay: View {
    @EnvironmentObject var device: DeviceModel

    let isLoading: Bool

    var body: some View {
        if isLoading {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 20) {
                    BouncingDotsLoader(dotSize: 10)

                    Text("finalizing results...")
                        .font(device.valueByDevice(small: .title3, normal: .title2, ipad: .title))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("darkPurple"))
                }
            }
        }
    }
}

#Preview {
    GeometryReader { screen in
        EndGameLoadingOverlay(isLoading: true)
            .environmentObject(DeviceModel(screen: screen))
    }
}
