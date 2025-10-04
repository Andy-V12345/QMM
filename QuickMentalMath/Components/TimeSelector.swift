//
//  TimeSelector.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/17/24.
//

import SwiftUI

struct TimeSelector: View {
    
    let buttonRadius: CGFloat = 15
    let shadowOffset: CGFloat = 3
    
    @Binding var timeIndex: Int
    @EnvironmentObject var device: DeviceModel
    let isTimeTrial: Bool
            
    var body: some View {
        VStack(spacing: device.valueByDevice(small: 12, normal: 15, ipad: 20)) {
            Button(action: {}, label: {
                Text("1 min")
                    .foregroundStyle(timeIndex == 0 ? .white : Color("darkPurple"))
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 0 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 0 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeIndex = 0
            })
            
            Divider()
            
            Button(action: {}, label: {
                Text("2 min")
                    .foregroundStyle(timeIndex == 1 ? .white : Color("darkPurple"))
                    .opacity(isTimeTrial ? 0.5 : 1)

            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 1 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 1 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeIndex = 1
            })
            .allowsHitTesting(!isTimeTrial)
            
            Divider()
            
            Button(action: {}, label: {
                Text("3 min")
                    .foregroundStyle(timeIndex == 2 ? .white : Color("darkPurple"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 2 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 2 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeIndex = 2
            })
            .allowsHitTesting(!isTimeTrial)
            
            Divider()
            
            Button(action: {}, label: {
                Text("no limit")
                    .foregroundStyle(timeIndex == 3 ? .white : Color("darkPurple"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: timeIndex == 3 ? Color("darkPurple") : Color("offWhite"), shadowColor: timeIndex == 3 ? Color("darkerPurple") :  Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                timeIndex = 3
            })
            .allowsHitTesting(!isTimeTrial)
            
            Divider()
            
            Text("time limit")
                .fontWeight(.heavy)
                .foregroundColor(Color("lightPurple"))
        }
        .font(device.valueByDevice(small: .subheadline, normal: .headline, ipad: .title2))
        .bold()
        .padding(device.valueByDevice(small: 12, normal: 15, ipad: 20))
        .background(.white)
        .roundedCorner(20, corners: .allCorners)
        .clipped()
        .shadow(radius: 2)

    }
}
