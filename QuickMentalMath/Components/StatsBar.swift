//
//  StatsBar.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/14/24.
//

import SwiftUI

struct StatsBar: View {
    
    @State var percentage: Double
    @State var uiPercentage: Double = 0
    @State var imgName: String
    @State var color: Color
    @State var mode: String
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Image(systemName: imgName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 45, height: 45)
                    .background(
                        color
                    )
                    .roundedCorner(8, corners: .allCorners)

                
                Text(mode)
                    .foregroundStyle(color)
                    .fontWeight(.bold)
                    .font(.title2)
                
                Spacer()
                
                Text("\(Int(percentage))%")
                    .foregroundStyle(Color("darkPurple"))
                    .bold()
                    .font(.title3)
                
                
                
            }
            
            RoundedRectangle(cornerRadius: 8)
                .foregroundStyle(Color.gray.opacity(0.2))
                .frame(height: 5)
                .overlay(
                    GeometryReader { metrics in
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(uiPercentage <= 25 ? Color.red : uiPercentage > 25 && uiPercentage <= 50 ? Color.orange : uiPercentage > 50 && uiPercentage <= 75 ? Color.yellow : Color.green)
                            .frame(width: (uiPercentage / 100) * metrics.size.width, height: 5)
                    }
                )
        }
        .onAppear {
            withAnimation(.linear(duration: 0.85)) {
                uiPercentage = percentage
            }
        }
    }
}
