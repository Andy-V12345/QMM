//
//  LeaderboardEntry.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/14/24.
//

import SwiftUI

struct LeaderboardEntry: View {
    
    @State var rank: Int = 4
    @State var username: String = "Andy.v.1234567"
    @State var score: Int = 99
    
    var backgroundColor: Color {
        if rank <= 3 {
            return Color("lighterPurple")
        }
            
        return Color("offWhite")
    }
    
    var shadowColor: Color {
        if rank <= 3 {
            return Color("lightPurple")
        }
        
        return Color.gray.opacity(0.4)
    }
    
    var trophyColor: Color {
        if rank == 1 {
            return Color("gold")
        }
        else if rank == 2 {
            return Color("silver")
        }
        else if rank == 3 {
            return Color("bronze")
        }
        
        return Color("lightPurple")
    }
    
    var capsuleColor: Color {
        if rank <= 3 {
            return Color("lightPurple")
        }
        
        return Color("lighterPurple")
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Text("\(rank).")
                .foregroundStyle(Color("darkPurple"))
                .font(.title3)
                .bold()
            
            Text(username)
                .foregroundStyle(Color("darkPurple"))
                .font(.title3)
                .fontWeight(.heavy)
                .lineLimit(1)
            
            Spacer()
            
            Text("\(score)")
                .foregroundStyle(Color("darkPurple"))
                .font(.title3)
                .fontWeight(.heavy)
                .padding(.vertical, 2)
                .padding(.horizontal, 10)
                .padding(.leading, 5)
                .background(
                    Capsule()
                        .fill(capsuleColor)
                )
                .overlay(
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(trophyColor)
                        .font(.title)
                        .offset(x: -16)
                    , alignment: .leading)
        }
        .padding(20)
        .raisedButton(cornerRadius: 20, backgroundColor: backgroundColor, shadowColor: shadowColor, shadowOffset: 6, action: {})
        .allowsHitTesting(false)
        .dynamicTypeSize(.large)
    }
}

#Preview {
    LeaderboardEntry()
        .padding(20)
}
