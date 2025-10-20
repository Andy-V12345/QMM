//
//  MissedQuestionCard.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import SwiftUI

struct MissedQuestionCard: View {
    
    let missedQuestion: MissedQuestion
    @State private var isAcknowledged = false
    
    @EnvironmentObject var device: DeviceModel
    
    func handleTap() {
        withAnimation(.easeInOut(duration: 0.15)) {
            isAcknowledged = true
        }
        
        HapticManager.shared.trigger(.medium)
        
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
            
            withAnimation(.easeInOut(duration: 0.15)) {
                isAcknowledged = false
            }
        }
    }
    
    var body: some View {
        
        VStack(spacing: 15) {
            Text("\(missedQuestion.question) = \(missedQuestion.userAns)")
                .foregroundStyle(Color("darkPurple"))
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(device.valueByDevice(small: .title3, normal: .title3, ipad: .title))
                .opacity(isAcknowledged ? 0 : 1)

            
            Text("correct answer: \(missedQuestion.correctAns)")
                .foregroundStyle(Color("correctGreen"))
                .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .opacity(isAcknowledged ? 0 : 1)

        }
        .padding(device.valueByDevice(small: 15, normal: 15, ipad: 25))
        .raisedButton(
            cornerRadius: 20,
            backgroundColor: isAcknowledged ? Color("correctGreen") : Color("offWhite"),
            shadowColor: isAcknowledged ? Color("darkGreen") : Color.gray.opacity(0.4),
            shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8),
            action: { handleTap() }
        )
        .overlay(
            Text("got it")
                .foregroundStyle(Color("offWhite"))
                .fontWeight(.heavy)
                .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(isAcknowledged ? 1 : 0)
            
        )
        
        
    }
}

#Preview {
    GeometryReader { screen in
        MissedQuestionCard(missedQuestion: MissedQuestion(question: "10.55 + 10.55", userAns: "410.01", correctAns: "410.00"))
            .padding(20)
            .environmentObject(DeviceModel(screen: screen))
    }
}
