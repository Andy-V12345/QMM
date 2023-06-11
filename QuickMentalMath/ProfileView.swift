//
//  ProfileView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 6/10/23.
//

import SwiftUI

struct ProfileView: View {
    
    @Binding var totalQuestionsAnswered: [String: Int]
    @Binding var totalQuestionsCorrect: [String: Int]
    @Binding var isProfileView: Bool
    @State var bestScore: Int = 0
    @State var percentages: [String: Float] = [:]
    
    var body: some View {
        
        VStack(spacing: 30) {
            HStack {
                Text("Your Stats")
                    .padding(.horizontal)
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                Image(systemName: "xmark")
                    .padding(.horizontal)
                    .font(.title)
                    .bold()
                    .onTapGesture {
                        isProfileView = false
                    }
                
            }
            .foregroundColor(Color("textColor"))
                        
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    StatPanel(title: "Addition", percentage: totalQuestionsAnswered["Addition"] == 0 ? 0 :  Float(totalQuestionsCorrect["Addition"]!) / Float(totalQuestionsAnswered["Addition"]!))
                    
                    StatPanel(title: "Subtraction", percentage: totalQuestionsAnswered["Subtraction"] == 0 ? 0 :  Float(totalQuestionsCorrect["Subtraction"]!) / Float(totalQuestionsAnswered["Subtraction"]!))
                }
                
                HStack(spacing: 10) {
                    StatPanel(title: "Multiplication", percentage: totalQuestionsAnswered["Multiplication"] == 0 ? 0 :  Float(totalQuestionsCorrect["Multiplication"]!) / Float(totalQuestionsAnswered["Multiplication"]!))
                    
                    StatPanel(title: "Division", percentage: totalQuestionsAnswered["Division"] == 0 ? 0 :  Float(totalQuestionsCorrect["Division"]!) / Float(totalQuestionsAnswered["Division"]!))
                }
            }
            
            
            Text("Your best score: \(bestScore) points")
                .foregroundColor(Color("textColor"))
                .font(.title)
                .bold()
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    Color.white
                        .cornerRadius(20)
                        .shadow(radius: 10)
                )
                
                
            
            
        }
        .padding(.top)
        .padding(.horizontal)
        .onAppear {
            bestScore = UserDefaults.standard.integer(forKey: "best")

        }
    }
}

struct StatPanel: View {
    
    @State var title: String
    var percentage: Float
    
    @State var displayedPercentage: Float = 0
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color("textColor")
                    .cornerRadius(20)
                
                VStack {
                    Text("\(title)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical)
                        .padding(.horizontal)
                        .background(Color("bgColor"))
                        .roundedCorner(20, corners: [.topLeft, .topRight])
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.9),
                                    style: StrokeStyle(lineWidth: screen.size.width * 0.05))
                            .animatingOverlay(for: Double((displayedPercentage) * 100))
                            .font(.system(size: screen.size.width * 0.14, weight: .bold))
                            .foregroundColor(.white)
                            
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(displayedPercentage))
                            .stroke(Color("bgColor"),
                                    style: StrokeStyle(lineWidth: screen.size.width * 0.05, lineCap: .round)
                            )
                            .rotationEffect(Angle(degrees: -90))
                        
                    } // ZStack
                    .frame(maxWidth: screen.size.width * 0.7)
                    
                    Text("Correct")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    Spacer()
                    
                }
                
                
            }
            .onAppear {
                withAnimation(.linear(duration: 0.75)) {
                    displayedPercentage = percentage
                }
            }
        }
    }
}

