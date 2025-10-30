//
//  SignInNeededView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/28/25.
//

import SwiftUI

struct SignInNeededView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var device: DeviceModel
    @EnvironmentObject var appModel: AppModel
        
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 10) {
                Spacer()
                
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundStyle(Color("lightPurple"))
                
                Text("account required")
                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                    .fontWeight(.bold)
                    .foregroundStyle(Color("darkPurple"))
                
                Button(action: {}, label: {
                    Text("sign in")
                        .foregroundStyle(Color("offWhite"))
                        .font(device.valueByDevice(small: .title3, normal: .title3, ipad: .title2))
                        .fontWeight(.bold)
                        .padding(.horizontal, device.valueByDevice(small: 12, normal: 14, ipad: 16))
                        .padding(.vertical, 4)
                        .raisedButton(
                            cornerRadius: 12,
                            shadowOffset: device.valueByDevice(small: 3, normal: 4, ipad: 6),
                            action: {
                                dismiss()
                                appModel.path = NavigationPath([AuthState.UNAUTHORIZED])
                            }
                        )
                })
                .padding(.top, 20)
                
                Spacer()
                
                
            }
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    GeometryReader { screen in
        SignInNeededView()
            .environmentObject(DeviceModel(screen: screen))
            .environmentObject(AppModel(path: NavigationPath()))
    }
}
