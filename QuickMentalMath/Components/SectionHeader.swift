//
//  SectionHeader.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct SectionHeader: View {

    let title: String

    @EnvironmentObject var device: DeviceModel

    var body: some View {
        Text(title)
            .foregroundStyle(Color("darkPurple"))
            .font(device.valueByDevice(small: .body, normal: .body, ipad: .title3))
            .fontWeight(.heavy)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    GeometryReader { screen in
        VStack(spacing: 20) {
            SectionHeader(title: "compete")
            SectionHeader(title: "solo practice")
            SectionHeader(title: "last practice")
        }
        .padding(20)
        .environmentObject(DeviceModel(screen: screen))
    }
}
