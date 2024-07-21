//
//  TimeSelector.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/17/24.
//

import SwiftUI

struct TimeSelector: View {
    
    @Binding var timeIndex: Int
    @EnvironmentObject private var device: DeviceModel
        
    var body: some View {
        VStack(spacing: device.type == .SMALL ? 8 : 15) {
            Button(action: {
                timeIndex = 0
            }, label: {
                Text("1 Min")
                    .font(device.type == .SMALL ? .subheadline : .headline)
                    .foregroundStyle(timeIndex == 0 ? .white : Color("darkPurple"))
                    .fontWeight(.medium)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .background(timeIndex == 0 ? Color("darkPurple") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: timeIndex)
            })
            
            Divider()
            
            Button(action: {
                timeIndex = 1
            }, label: {
                Text("2 Min")
                    .font(device.type == .SMALL ? .subheadline : .headline)
                    .foregroundStyle(timeIndex == 1 ? .white : Color("darkPurple"))
                    .fontWeight(.medium)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .background(timeIndex == 1 ? Color("darkPurple") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: timeIndex)
            })
            
            Divider()
            
            Button(action: {
                timeIndex = 2
            }, label: {
                Text("3 Min")
                    .font(device.type == .SMALL ? .subheadline : .headline)
                    .foregroundStyle(timeIndex == 2 ? .white : Color("darkPurple"))
                    .fontWeight(.medium)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .background(timeIndex == 2 ? Color("darkPurple") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: timeIndex)
            })
            
            Divider()
            
            Button(action: {
                timeIndex = 3
            }, label: {
                Text("No Limit")
                    .font(device.type == .SMALL ? .subheadline : .headline)
                    .foregroundStyle(timeIndex == 3 ? .white : Color("darkPurple"))
                    .fontWeight(.medium)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .background(timeIndex == 3 ? Color("darkPurple") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: timeIndex)
            })
            
        }
    }
}
