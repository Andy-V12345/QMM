//
//  MissedQuestionsDisplay.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 6/9/23.
//

import SwiftUI

struct MissedQuestion: Identifiable, Hashable {
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
                    .bold()
                
                VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                    ForEach(0 ..< missedQuestions.count) { i in
                        VStack(spacing: 15) {
                            Text("\(missedQuestions[i].question) = \(missedQuestions[i].userAns)")
                                .foregroundStyle(Color("darkPurple"))
                                .fontWeight(.heavy)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(device.valueByDevice(small: .title3, normal: .title3, ipad: .title))
                            
                            Text("correct answer: \(missedQuestions[i].correctAns)")
                                .foregroundStyle(Color("correctGreen"))
                                .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(device.valueByDevice(small: 15, normal: 15, ipad: 25))
                        .raisedButton(cornerRadius: 20, backgroundColor: Color("silver"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                        .allowsHitTesting(false)
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

