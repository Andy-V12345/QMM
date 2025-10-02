//
//  InGameStats.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

/// A geometry effect that shakes a view horizontally.
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10     // how far to move left/right
    var shakesPerUnit: CGFloat = 4 // how many shakes per animation cycle
    var animatableData: CGFloat   // drives the animation

    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amount * sin(animatableData * .pi * shakesPerUnit)
        return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
    }
}

struct InGameStats: View {
    
    @State var startTime: CGFloat
    @Binding var shakeTrigger: Int
    @Binding var showAreYouSure: Bool
    @Binding var isTimerPaused: Bool
    @Binding var isGameOver: Bool
    @Binding var timeLeft: CGFloat
    @Binding var numCorrect: Int
    
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
    
    var progress: CGFloat {
        if startTime > 180 {
            return 1
        }
        
        // progress goes from 0 (start) to 1 (complete)
        return max(0, min(1, 1 - timeLeft / startTime))
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
            })
            
            if startTime > 180 {
                Text("∞")
                    .font(font)
                    .foregroundStyle(color)
            }
            else {
                HStack(spacing: 2) {
                    RollingNumber(number: timeLeftString, color: color, font: font, digitWidth: digitWidth, digitHeight: digitHeight)
                    
                    Text("s")
                        .font(font)
                        .foregroundStyle(color)
                }
            }
            
            Spacer()
            
            RollingNumber(number: numCorrectString, color: Color("lightGreen"), font: font, digitWidth: digitWidth, digitHeight: digitHeight)
        }
        .padding(.horizontal, 20)
        .background(
            Capsule().stroke(Color("lighterPurple").opacity(0.2), lineWidth: 3.5)
        )
        .overlay(
            // This overlay draws the “filling” border
            Capsule()
                .trim(from: 0.0, to: progress)
                .stroke(Color("lighterPurple"), lineWidth: 3.5)
                .animation(.linear(duration: 1), value: progress)
                .rotationEffect(Angle(degrees: -180))

        )
        .modifier(ShakeEffect(animatableData: CGFloat(shakeTrigger)))
    }
}
