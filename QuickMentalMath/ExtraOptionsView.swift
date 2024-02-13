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
    @Binding var difficultyIndex: Int
    
    
    
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
                    ZStack {
                        Color("textColor")
                            .roundedCorner(30, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                        
                        VStack {
                            
                            HStack {
                                Button {
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                        .bold()
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 20) {
                                
                                QuestionSlider(value: $progress, in: 10...100)
                                    .frame(maxWidth: metrics.size.height * 0.2, maxHeight: metrics.size.height * 0.2)
                                Text("Number of Questions")
                                    .font(metrics.size.height < 736 && metrics.size.width < 390 ? .headline : .title3)
                                    .foregroundColor(Color.white)
                                    .bold()
                                
                                
                                VStack(spacing: 15) {
                                    OptionSlider(items: ["1 min", "2 min", "3 min", "∞ min"], color: Color.white.opacity(0.65), borderRadius: 30, isSmall: metrics.size.height < 736 && metrics.size.width < 390, selectedIndex: $timeIndex)
                                    
                                    Text("Time Limit")
                                        .font(metrics.size.height < 736 && metrics.size.width < 390 ? .headline : .title3)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .padding(.bottom, 20)
                                
                                
                            }
                            
                            
                        } // VStack
                        
                        
                    } // ZStack
                    .frame(maxHeight: metrics.size.height * (metrics.size.height < 736 ? 0.7 : 0.65))
                    
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



