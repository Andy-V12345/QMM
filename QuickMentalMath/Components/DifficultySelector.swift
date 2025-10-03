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
    
    let metrics: GeometryProxy
        
    var body: some View {
        VStack(spacing: metrics.size.height < 736 ? 12 : 15) {
            Button(action: {
            }, label: {
                Text("easy")
                    .foregroundStyle(difficultyIndex == 0 ? .white : Color("lightGreen"))
            })
            .padding(.vertical, metrics.size.height < 736 ? 8 : 10)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 0 ? Color("lightGreen") : Color("offWhite"), shadowColor: difficultyIndex == 0 ? Color("darkGreen") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficultyIndex = 0
            })
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("medium")
                    .foregroundStyle(difficultyIndex == 1 ? .white : Color("lightYellow"))
            })
            .padding(.vertical, metrics.size.height < 736 ? 8 : 10)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 1 ? Color("lightYellow") : Color("offWhite"), shadowColor: difficultyIndex == 1 ? Color("darkYellow") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficultyIndex = 1
            })
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("hard")
                    .foregroundStyle(difficultyIndex == 2 ? .white : Color("lightOrange"))
            })
            .padding(.vertical, metrics.size.height < 736 ? 8 : 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 2 ? Color("lightOrange") : Color("offWhite"), shadowColor: difficultyIndex == 2 ? Color("darkOrange") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficultyIndex = 2
            })
            
            Divider()
            
            Button(action: {
            }, label: {
                Text("decimals")
                    .foregroundStyle(difficultyIndex == 3 ? .white : Color("lightRed"))
            })
            .padding(.vertical, metrics.size.height < 736 ? 8 : 10)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .raisedButton(cornerRadius: buttonRadius, backgroundColor: difficultyIndex == 3 ? Color("lightRed") : Color("offWhite"), shadowColor: difficultyIndex == 3 ? Color("darkRed") : Color.gray.opacity(0.2), shadowOffset: shadowOffset, action: {
                difficultyIndex = 3
            })
            
            Divider()
            
            Text("difficulty")
                .fontWeight(.heavy)
                .foregroundColor(Color("lightPurple"))
            
        }
        .font(metrics.size.height < 736 ? .subheadline : .headline)
        .bold()
        .padding(metrics.size.height < 736 && metrics.size.width < 390 ? 12 : 15)
        .background(.white)
        .roundedCorner(20, corners: .allCorners)
        .clipped()
        .shadow(radius: 2)
    }
}
