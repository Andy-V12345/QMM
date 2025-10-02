//
//  TimeSelector.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/17/24.
//

import SwiftUI

struct TimeSelector: View {
    
    let buttonRadius: CGFloat = 10
    let shadowOffset: CGFloat = 3
    
    @Binding var timeIndex: Int
    @EnvironmentObject private var device: DeviceModel
        
    var body: some View {
        VStack(spacing: device.type == .SMALL ? 8 : 15) {
            Button(action: {}, label: {
                Text("1 Min")
                    .font(device.type == .SMALL ? .subheadline : .headline)
                    .foregroundStyle(timeIndex == 0 ? .white : Color("darkPurple"))
                    .fontWeight(.medium)
            })
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 0 ? Color("darkPurple") : Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: shadowOffset, action: {
                timeIndex = 0
            })
            
            Divider()
            
            Button(action: {}, label: {
                Text("2 Min")
                    .font(device.type == .SMALL ? .subheadline : .headline)
                    .foregroundStyle(timeIndex == 1 ? .white : Color("darkPurple"))
                    .fontWeight(.medium)
            })
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 1 ? Color("darkPurple") : Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: shadowOffset, action: {
                timeIndex = 1
            })
            
            Divider()
            
            Button(action: {}, label: {
                Text("3 Min")
                    .font(device.type == .SMALL ? .subheadline : .headline)
                    .foregroundStyle(timeIndex == 2 ? .white : Color("darkPurple"))
                    .fontWeight(.medium)
            })
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 2 ? Color("darkPurple") : Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: shadowOffset, action: {
                timeIndex = 2
            })
            
            Divider()
            
            Button(action: {}, label: {
                Text("No Limit")
                    .font(device.type == .SMALL ? .subheadline : .headline)
                    .foregroundStyle(timeIndex == 3 ? .white : Color("darkPurple"))
                    .fontWeight(.medium)
            })
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 3 ? Color("darkPurple") : Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: shadowOffset, action: {
                timeIndex = 3
            })
            
        }
    }
}
