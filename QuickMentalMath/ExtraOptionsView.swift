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
    @State var difficultyIndex = 0
    
    @EnvironmentObject private var game: GameModel
    @EnvironmentObject private var device: DeviceModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                
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
                    .padding(.top)
                    .frame(maxWidth: .infinity)
                    
                    
                    VStack {
                        
                        VStack(spacing: 30) {
                            
                            
                            VStack(spacing: 10) {
                                QuestionSlider(value: $progress, in: 10...100)
                                    .frame(width: metrics.size.height * 0.18, height: metrics.size.height * 0.18)
                                Text("Number of Questions")
                                    .font(metrics.size.height < 736 && metrics.size.width < 390 ? .headline : .title3)
                                    .foregroundColor(Color("darkPurple"))
                                    .bold()
                            }
                            
                            HStack(spacing: 20) {
                                
                                VStack(spacing: metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15) {
                                    DifficultySelector(difficultyIndex: $difficultyIndex)
                                        .environmentObject(device)
                                    
                                    Divider()
                                    
                                    Text("Difficulty")
                                        .font(metrics.size.height < 736 && metrics.size.width < 390 ? .subheadline : .headline)
                                        .bold()
                                        .foregroundColor(Color("darkPurple"))
                                }
                                .padding(metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15)
                                .background(.white)
                                .roundedCorner(10, corners: .allCorners)
                                .clipped()
                                .shadow(radius: 5)
                                
                                VStack(spacing: metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15) {
                                    
                                    TimeSelector(timeIndex: $timeIndex)
                                        .environmentObject(device)
                                    
                                    Divider()
                                    
                                    Text("Time Limit")
                                        .font(metrics.size.height < 736 && metrics.size.width < 390 ? .subheadline : .headline)
                                        .bold()
                                        .foregroundColor(Color("darkPurple"))
                                }
                                .padding(metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15)
                                .background(.white)
                                .roundedCorner(10, corners: .allCorners)
                                .clipped()
                                .shadow(radius: 5)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            game.setTime(timeIndex: timeIndex)
                            game.setDifficulty(difficultyIndex: difficultyIndex)
                            game.totQuestions = Int(round(progress))
                            showGame = true
                        } label: {
//                            ZStack {
//                                Capsule(style: .continuous)
//                                    .fill(Color("darkPurple"))
//                                    .frame(maxHeight: metrics.size.height * 0.1)
//                                    .shadow(color: Color("darkPurple"), radius: 5)
//                                
//                                
//                                
//                                
//                                Text("Begin")
//                                    .font(.system(size: 35, weight: .bold))
//                                    .foregroundColor(.white)
//                                
//                            } // ZStack
                            Text("Begin")
                                .padding(.vertical, 30)
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(Color("darkPurple"))
                                )
                                .font(.system(size: metrics.size.height < 736 && metrics.size.width < 390 ? 30 : 35, weight: .bold))
                                .foregroundStyle(.white)
                            
                        }
                        .fullScreenCover(isPresented: $showGame, content: {
                            GameView()
                                .environmentObject(game)
                        })
                        
                        
                    }
                    
                } // VStack
                .padding(.horizontal, 15)
                .padding(.bottom, 15)
                
                
            } // ZStack
            
        }
        
    }
}




