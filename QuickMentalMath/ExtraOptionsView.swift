//
//  TimeSelectView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/14/23.
//

import SwiftUI


struct ExtraOptionsView: View {
    
    @State var progress = 10.0
    @State var pulsingAmount = 0.95
    @State var showGame = false
    
    @State var timeIndex = 0
    @Binding var modeIndex: Int
    @State var difficultyIndex = 0
    
    
    
    var modes: [String] = ["+", "-", "x", "÷"]
    var difficulties: [String] = ["easy", "medium", "hard", "decimals"]
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { metrics in
            
            ZStack {
                
                VStack(spacing: 0) {
                    Color.white
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                
                VStack {
                        VStack {
                            HStack {
                                Button {
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(Color("darkPurple"))
                                        .font(.title3)
                                        .bold()
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 30) {
                                
                                VStack(spacing: 10) {
                                    QuestionSlider(value: $progress, in: 10...100)
                                        .frame(maxWidth: metrics.size.height * 0.2, maxHeight: metrics.size.height * 0.2)
                                    Text("Number of Questions")
                                        .font(metrics.size.height < 736 && metrics.size.width < 390 ? .headline : .title3)
                                        .foregroundColor(Color("darkPurple"))
                                        .bold()
                                }
                                
                                VStack(spacing: 10) {
                                    DifficultySelector(difficultyIndex: $difficultyIndex)
                                    Text("Difficulty")
                                        .font(metrics.size.height < 736 && metrics.size.width < 390 ? .headline : .title3)
                                        .bold()
                                        .foregroundColor(Color("darkPurple"))
                                }
                                
                                
                                VStack(spacing: 10) {
                                    OptionSlider(items: ["1 min", "2 min", "3 min", "∞ min"], color: Color("darkPurple"), borderRadius: 30, isSmall: metrics.size.height < 736 && metrics.size.width < 390, selectedIndex: $timeIndex)
                                    
                                    Text("Time Limit")
                                        .font(metrics.size.height < 736 && metrics.size.width < 390 ? .headline : .title3)
                                        .bold()
                                        .foregroundColor(Color("darkPurple"))
                                }
                                .padding(.bottom, 20)
                                
                            }
                            
                            
                        } // VStack
                        
                    
                    Spacer()
                    
                    Button {
                        showGame = true
                    } label: {
                        ZStack {
                            Capsule(style: .continuous)
                                .fill(Color("goColor"))
                                .frame(width: metrics.size.width * 0.8)
                                .frame(maxHeight: metrics.size.width * 0.3)
                                .shadow(radius: 15)
                            
                            Text("Begin")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.white)
                            
                        } // ZStack
                    }
                    .fullScreenCover(isPresented: $showGame, content: {
                        GameView(timeIndex: $timeIndex, totalQuestions: Int(round(progress)), mode: modes[modeIndex], difficulty: difficulties[difficultyIndex])
                    })
                    
                    Spacer()
                    
                    
                } // VStack
            } // ZStack
            
        }
        
    }
}



