//
//  LeaderboardEntry.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/14/24.
//

import SwiftUI

struct LeaderboardEntry: View {
    
    @State var rank: Int = 1
    @State var username: String = "Andy.v.123"
    @State var score: Int = 123
    
    var body: some View {
        HStack(spacing: 20) {
            Text("\(rank).")
                .foregroundStyle(Color("darkPurple"))
            
            Text(username)
                .foregroundStyle(Color("darkPurple"))
            
            Spacer()
            
            Text("\(score)")
                .foregroundStyle(Color.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 18)
                .background(
                    Capsule()
                        .fill(Color("lighterPurple"))
                )
        }
        .bold()
        .padding(20)
        .background(
            .white
        )
        .roundedCorner(8, corners: .allCorners)
        .shadow(radius: 2)
    }
}

#Preview {
    LeaderboardEntry()
}
