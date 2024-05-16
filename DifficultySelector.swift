//
//  DifficultySelector.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 3/30/24.
//

import SwiftUI

struct DifficultySelector: View {
    
    @Binding var difficultyIndex: Int
        
    var body: some View {
        HStack {
            Button(action: {
                difficultyIndex = 0
            }, label: {
                Text("Easy")
                    .foregroundStyle(difficultyIndex == 0 ? .white : Color("lightGreen"))
                    .fontWeight(.medium)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(difficultyIndex == 0 ? Color("lightGreen") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
            })
            
            Divider().frame(width: 1)
            
            Button(action: {
                difficultyIndex = 1
            }, label: {
                Text("Medium")
                    .foregroundStyle(difficultyIndex == 1 ? .white : Color("lightYellow"))
                    .fontWeight(.medium)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(difficultyIndex == 1 ? Color("lightYellow") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
            })
            
            Divider().frame(width: 1)
            
            Button(action: {
                difficultyIndex = 2
            }, label: {
                Text("Hard")
                    .foregroundStyle(difficultyIndex == 2 ? .white : Color("lightOrange"))
                    .fontWeight(.medium)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(difficultyIndex == 2 ? Color("lightOrange") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
            })
            
            Divider().frame(width: 1)
            
            Button(action: {
                difficultyIndex = 3
            }, label: {
                Text("Decimals")
                    .foregroundStyle(difficultyIndex == 3 ? .white : Color("lightRed"))
                    .fontWeight(.medium)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                    .background(difficultyIndex == 3 ? Color("lightRed") : .white)
                    .roundedCorner(10, corners: .allCorners)
                    .animation(.easeInOut(duration: 0.25), value: difficultyIndex)
            })
            
        }
        .frame(height: 30)
    }
}
