//
//  DifficultySelector.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 3/30/24.
//

import SwiftUI

struct DifficultySelector: View {
    
    let buttonRadius: CGFloat = 15
    let shadowOffset: CGFloat = 3
    
    @Binding var difficultyIndex: Int
    let isTimeTrial: Bool
    @EnvironmentObject var device: DeviceModel
            
    var body: some View {
        VStack(spacing: device.valueByDevice(small: 12, normal: 15, ipad: 20)) {
            Button(action: {
            }, label: {
                Text("easy")
                    .foregroundStyle(difficultyIndex == 0 ? .white : Color("lightGreen"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 0 ? Color("lightGreen") : Color("offWhite"), shadowColor: difficultyIndex == 0 ? Color("darkGreen") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficultyIndex = 0
            })
            .allowsHitTesting(!isTimeTrial)
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("medium")
                    .foregroundStyle(difficultyIndex == 1 ? .white : Color("lightYellow"))
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 1 ? Color("lightYellow") : Color("offWhite"), shadowColor: difficultyIndex == 1 ? Color("darkYellow") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficultyIndex = 1
            })
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("hard")
                    .foregroundStyle(difficultyIndex == 2 ? .white : Color("lightOrange"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 2 ? Color("lightOrange") : Color("offWhite"), shadowColor: difficultyIndex == 2 ? Color("darkOrange") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficultyIndex = 2
            })
            .allowsHitTesting(!isTimeTrial)

            
            Divider()
            
            Button(action: {
            }, label: {
                Text("decimals")
                    .foregroundStyle(difficultyIndex == 3 ? .white : Color("lightRed"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 3 ? Color("lightRed") : Color("offWhite"), shadowColor: difficultyIndex == 3 ? Color("darkRed") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficultyIndex = 3
            })
            .allowsHitTesting(!isTimeTrial)

            
            Divider()
            
            Text("difficulty")
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
