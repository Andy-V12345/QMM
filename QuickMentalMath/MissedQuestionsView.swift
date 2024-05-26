//
//  MissedQuestionsView.swift
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

struct MissedQuestionsView: View {
    
    @State var misssedQuestions: [MissedQuestion]
    @Binding var isReviewing: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("Missed Questions")
                    .font(.title)
                    .bold()
                    .padding(.horizontal)
                
                Spacer()
                
                Image(systemName: "xmark")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                    .onTapGesture {
                        isReviewing = false
                    }
                
            }
            .foregroundColor(Color("darkPurple"))
            ScrollView {
                VStack(spacing: 30) {
                    ForEach(misssedQuestions) { question in
                        VStack(spacing: 10) {
                            Text("\(question.question) = \(question.correctAns)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Your answer: \(question.userAns)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .font(.title)
                        .foregroundColor(Color("darkPurple"))
                        
                        Divider()
                    }
                }
            }
        }
        .padding(.top)
        .background(Color.white)
        .frame(maxWidth: .infinity)
    }
}

