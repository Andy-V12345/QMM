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
    
    @EnvironmentObject private var gameModel: GameModel
    @EnvironmentObject private var deviceModel: DeviceModel
    @EnvironmentObject private var appModel: AppModel
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                
                VStack(spacing: 10) {
                    HStack {
                        Button(action: {
                            appModel.path.removeLast()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color("darkPurple"))
                        })
                        .font(.title3)
                        .bold()
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 40) {
                        
                        
                        VStack(spacing: 10) {
                            QuestionSlider(value: $progress, in: 10...100)
                                .frame(width: metrics.size.height * 0.18, height: metrics.size.height * 0.18)
                            Text("Number of Questions")
                                .font(metrics.size.height < 736 && metrics.size.width < 390 ? .headline : .title3)
                                .foregroundColor(Color("lightPurple"))
                                .bold()
                        }
                        
                        HStack(spacing: 20) {
                            
                            VStack(spacing: metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15) {
                                DifficultySelector(difficultyIndex: $difficultyIndex)
                                    .environmentObject(deviceModel)
                                
                                Divider()
                                
                                Text("Difficulty")
                                    .font(metrics.size.height < 736 && metrics.size.width < 390 ? .subheadline : .headline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color("lightPurple"))
                            }
                            .padding(metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15)
                            .background(.white)
                            .roundedCorner(10, corners: .allCorners)
                            .clipped()
                            .shadow(radius: 2)
                            
                            VStack(spacing: metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15) {
                                
                                TimeSelector(timeIndex: $timeIndex)
                                    .environmentObject(deviceModel)
                                
                                Divider()
                                
                                Text("Time Limit")
                                    .font(metrics.size.height < 736 && metrics.size.width < 390 ? .subheadline : .headline)
                                    .fontWeight(.heavy)
                                    .foregroundColor(Color("lightPurple"))
                            }
                            .padding(metrics.size.height < 736 && metrics.size.width < 390 ? 8 : 15)
                            .background(.white)
                            .roundedCorner(10, corners: .allCorners)
                            .clipped()
                            .shadow(radius: 2)
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                gameModel.setTime(timeIndex: timeIndex)
                                gameModel.setDifficulty(difficultyIndex: difficultyIndex)
                                gameModel.totQuestions = Int(round(progress))
                                
                                appModel.path.append(AppState.GAME)
                            } label: {
                                HStack {
                                    Text("Start")
                                    
                                    Image(systemName: "arrow.right")
                                }
                                .foregroundStyle(Color("darkPurple"))
                                .font(.title2)
                                .fontWeight(.heavy)
                            } //: Start Button
                        }
                        
                        Spacer()
                    } //: VStack
                    
                    
                } //: VStack
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
            } // ZStack
            
        }
        
    }
}

#Preview {
    ExtraOptionsView()
        .environmentObject(GameModel())
        .environmentObject(DeviceModel())
        .environmentObject(AppModel(path: NavigationPath()))
}




