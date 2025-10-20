//
//  MissedQuestionsDisplay.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 6/9/23.
//

import SwiftUI

struct MissedQuestion: Identifiable, Hashable, Codable {
    var id = UUID()
    var question: String
    var userAns: String
    var correctAns: String
}

struct MissedQuestionsDisplay: View {
    
    @State var missedQuestions: [MissedQuestion]
    @EnvironmentObject var device: DeviceModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: device.valueByDevice(small: 10, normal: 10, ipad: 15)) {
                Text("missed questions")
                    .foregroundStyle(Color("errorRed"))
                    .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .dynamicTypeSize(.large)
                    .fontWeight(.bold)
                
                VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                    ForEach(missedQuestions) { question in
                        MissedQuestionCard(missedQuestion: question)
                    }
                }
            }
            .padding(.bottom, 10)
        }
        .background(Color.white)
        .frame(maxWidth: .infinity)
        .scrollIndicators(.hidden)
        .dynamicTypeSize(.large)
    }
}

#Preview {
    GeometryReader { screen in
        MissedQuestionsDisplay(missedQuestions: [MissedQuestion(question: "10.55 + 10.55", userAns: "410.01", correctAns: "410.00"), MissedQuestion(question: "5 + 5", userAns: "1", correctAns: "10")])
            .padding(20)
            .environmentObject(DeviceModel(screen: screen))
    }
}

