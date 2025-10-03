//
//  StatPanel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/3/25.
//

import SwiftUI

struct StatPanel: View {
    
    let imageName: String
    let imageColor: Color
    let value: String
    let label: String
    let borderColor: Color
    let progress: Double?
    @State var uiProgress: Double = 0
    
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: imageName)
                .foregroundStyle(imageColor)
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text("\(value)")
                    .foregroundStyle(Color("darkPurple"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("\(label)")
                    .foregroundStyle(borderColor)
                    .fontWeight(.medium)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15).stroke(borderColor.opacity(0.4), lineWidth: 3.5)
        )
        .overlay(
            // This overlay draws the “filling” border
            RoundedRectangle(cornerRadius: 15)
                .trim(from: 0.0, to: uiProgress)
                .stroke(borderColor, lineWidth: 3.5)
                .rotationEffect(Angle(degrees: -180))

        )
        .onChange(of: progress, perform: { newValue in
            withAnimation(.linear(duration: 0.85)) {
                uiProgress = newValue ?? 0
            }
        })
    }
}
