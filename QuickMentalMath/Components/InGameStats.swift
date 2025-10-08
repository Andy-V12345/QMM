//
//  InGameStats.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

struct InGameStats: View {
    
    @State var timeLimit: CGFloat
    @Binding var showAreYouSure: Bool
    @Binding var isTimerPaused: Bool
    @Binding var timeLeft: CGFloat
    @Binding var numCorrect: Int
    @Binding var numIncorrect: Int
    
    var numCorrectString: Binding<String> {
        Binding(
            get: { String(Int(numCorrect)) },
            set: { newValue in
                if let intValue = Int(newValue) {
                    numCorrect = Int(intValue)
                }
            }
        )
    }
    
    var numIncorrectString: Binding<String> {
        Binding(get: { String(Int(numIncorrect)) }, set: { newValue in
            if let intValue = Int(newValue) {
                numIncorrect = Int(intValue)
            }
        })
    }
    
    var timeLeftString: Binding<String> {
        Binding(
            get: { String(Int(timeLeft)) },
            set: { newValue in
                if let intValue = Int(newValue) {
                    timeLeft = Double(intValue)
                }
            }
        )
    }
    
    let font = Font.title2.bold()
    let color = Color("darkPurple")
    let digitWidth: CGFloat = 16
    let digitHeight: CGFloat = 60
        
    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                isTimerPaused.toggle()
                showAreYouSure = true
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color("darkPurple"))
                    .dynamicTypeSize(.large)
            })
            
            if timeLeft > 180 {
                Text("∞")
                    .font(font)
                    .foregroundStyle(color)
                    .dynamicTypeSize(.large)
            }
            else {
                HStack(spacing: 2) {
                    RollingNumber(number: timeLeftString, color: color, font: font, digitWidth: digitWidth, digitHeight: digitHeight)
                    
                    Text("s")
                        .font(font)
                        .foregroundStyle(color)
                        .dynamicTypeSize(.large)
                }
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                RollingNumber(number: numCorrectString, color: Color("correctGreen"), font: font, digitWidth: digitWidth, digitHeight: digitHeight)
                
                RollingNumber(number: numIncorrectString, color: Color("errorRed"), font: font, digitWidth: digitWidth, digitHeight: digitHeight)
            }
        }
        .padding(.horizontal, 20)
        .background(
            Capsule().stroke(Color("lightPurple").opacity(0.2), lineWidth: 3.5)
        )
        .overlay(
            // This overlay draws the “filling” border
            Capsule()
                .trim(from: 0.0, to: timeLimit > 180 ? 1 : max(0, min(1, 1 - timeLeft / timeLimit)))
                .stroke(Color("lightPurple"), lineWidth: 3.5)
                .animation(.linear(duration: 1), value: timeLeft)
                .rotationEffect(Angle(degrees: -180))

        )
    }
}
