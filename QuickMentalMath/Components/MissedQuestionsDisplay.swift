//
//  MissedQuestionsDisplay.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 6/9/23.
//

import SwiftUI

struct MissedQuestion: Identifiable {
    var id = UUID()
    var question: String
    var userAns: String
    var correctAns: String
}

struct MissedQuestionsDisplay: View {
    
    @State var missedQuestions: [MissedQuestion]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Divider()
                
                ForEach(0 ..< missedQuestions.count) { i in
                    HStack(spacing: 0) {
                        Text("\(missedQuestions[i].question) = \(missedQuestions[i].correctAns)")
                            .foregroundStyle(Color("lightPurple"))
                            .bold()
                        
                        Spacer()
                        
                        Text("your answer: \(missedQuestions[i].userAns)")
                            .foregroundStyle(Color("darkPurple"))
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                }
            }
        }
        .background(Color.white)
        .frame(maxWidth: .infinity)
        .scrollIndicators(.hidden)
    }
}

#Preview {
    MissedQuestionsDisplay(missedQuestions: [MissedQuestion(question: "5 + 5", userAns: "1", correctAns: "10"), MissedQuestion(question: "5 + 5", userAns: "1", correctAns: "10")])
        .padding(20)
}

