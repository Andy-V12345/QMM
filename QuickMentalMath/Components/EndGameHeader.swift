//
//  EndGameHeader.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct EndGameHeader: View {
    let isWinner: Bool

    var body: some View {
        Text(isWinner ? "winner winner, chicken dinner" : "you need some more practice")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.largeTitle)
            .foregroundStyle(Color("darkPurple"))
            .bold()
    }
}
