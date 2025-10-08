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
    
    @Binding var difficulty: GameDifficulty
    
    let isTimeTrial: Bool
    
    @EnvironmentObject var device: DeviceModel
            
    var body: some View {
        VStack(spacing: device.valueByDevice(small: 12, normal: 15, ipad: 20)) {
            Button(action: {
            }, label: {
                Text("easy")
                    .foregroundStyle(difficulty == .EASY ? .white : Color("lightGreen"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficulty == .EASY ? Color("lightGreen") : Color("offWhite"), shadowColor: difficulty == .EASY ? Color("darkGreen") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficulty = .EASY
            })
            .allowsHitTesting(!isTimeTrial)
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("medium")
                    .foregroundStyle(difficulty == .MEDIUM ? .white : Color("lightOrange"))
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficulty == .MEDIUM ? Color("lightOrange") : Color("offWhite"), shadowColor: difficulty == .MEDIUM ? Color("darkOrange") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficulty = .MEDIUM
            })
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("hard")
                    .foregroundStyle(difficulty == .HARD ? .white : Color("lightRed"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficulty == .HARD ? Color("lightRed") : Color("offWhite"), shadowColor: difficulty == .HARD ? Color("darkRed") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficulty = .HARD
            })
            .allowsHitTesting(!isTimeTrial)

            
            Divider()
            
            Button(action: {
            }, label: {
                Text("decimals")
                    .foregroundStyle(Color("darkPurple"))
                    .opacity(isTimeTrial ? 0.5 : 1)
            })
            .padding(.vertical, device.valueByDevice(small: 8, normal: 10, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficulty == .DECIMALS ? Color("lighterPurple") : Color("offWhite"), shadowColor: difficulty == .DECIMALS ? Color("lightPurple") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficulty = .DECIMALS
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
        .shadow(color: Color("lighterPurple"), radius: 3)
    }
}
