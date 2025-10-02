//
//  DifficultySelector.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 3/30/24.
//

import SwiftUI

struct DifficultySelector: View {
    
    let buttonRadius: CGFloat = 10
    let shadowOffset: CGFloat = 3
    
    @Binding var difficultyIndex: Int
    
    @EnvironmentObject private var device: DeviceModel
        
    var body: some View {
        VStack(spacing: device.type == .SMALL ? 8 : 15) {
            Button(action: {
            }, label: {
                Text("Easy")
                    .foregroundStyle(difficultyIndex == 0 ? .white : Color("lightGreen"))
            })
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 0 ? Color("lightGreen") : Color("offWhite"), shadowColor: Color.gray.opacity(0.3), shadowOffset: shadowOffset, action: {
                difficultyIndex = 0
            })
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("Medium")
                    .foregroundStyle(difficultyIndex == 1 ? .white : Color("lightYellow"))
            })
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 1 ? Color("lightYellow") : Color("offWhite"), shadowColor: Color.gray.opacity(0.3), shadowOffset: shadowOffset, action: {
                difficultyIndex = 1
            })
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("Hard")
                    .foregroundStyle(difficultyIndex == 2 ? .white : Color("lightOrange"))
            })
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 2 ? Color("lightOrange") : Color("offWhite"), shadowColor: Color.gray.opacity(0.3), shadowOffset: shadowOffset, action: {
                difficultyIndex = 2
            })
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("Decimals")
                    .foregroundStyle(difficultyIndex == 3 ? .white : Color("lightRed"))
            })
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 3 ? Color("lightRed") : Color("offWhite"), shadowColor: Color.gray.opacity(0.3), shadowOffset: shadowOffset, action: {
                difficultyIndex = 3
            })
            
        }
        .font(device.type == .SMALL ? .subheadline : .headline)
        .bold()
    }
}
