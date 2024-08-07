//
//  DifficultySelector.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 3/30/24.
//

import SwiftUI

struct DifficultySelector: View {
    
    @Binding var difficultyIndex: Int
    
    @EnvironmentObject private var device: DeviceModel
        
    var body: some View {
        VStack(spacing: device.type == .SMALL ? 8 : 15) {
            Button(action: {
                difficultyIndex = 0
            }, label: {
                Text("Easy")
                    .foregroundStyle(difficultyIndex == 0 ? .white : Color("lightGreen"))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .background(difficultyIndex == 0 ? Color("lightGreen") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
            })
            
            Divider()
            
            Button(action: {
                difficultyIndex = 1
            }, label: {
                Text("Medium")
                    .foregroundStyle(difficultyIndex == 1 ? .white : Color("lightYellow"))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .background(difficultyIndex == 1 ? Color("lightYellow") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
            })
            
            Divider()
            
            Button(action: {
                difficultyIndex = 2
            }, label: {
                Text("Hard")
                    .foregroundStyle(difficultyIndex == 2 ? .white : Color("lightOrange"))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .background(difficultyIndex == 2 ? Color("lightOrange") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
            })
            
            Divider()
            
            Button(action: {
                difficultyIndex = 3
            }, label: {
                Text("Decimals")
                    .foregroundStyle(difficultyIndex == 3 ? .white : Color("lightRed"))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .frame(maxWidth: .infinity)
                    .background(difficultyIndex == 3 ? Color("lightRed") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
            })
            
        }
        .font(device.type == .SMALL ? .subheadline : .headline)
        .bold()
    }
}
