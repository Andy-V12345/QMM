//
//  TimeSelectView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/14/23.
//

import SwiftUI


struct ExtraOptionsView: View {
    
    @State var progress = 10.0
    var progressString: Binding<String> {
        Binding(
            get: { String(Int(progress)) },
            set: { newValue in
                if let newValueAsDouble = Double(newValue) {
                    self.progress = newValueAsDouble
                }
            }
        )
    }
    
    @State var showGame = false
    
    @State var timeIndex = 0
    @State var difficultyIndex = 0
    
    @EnvironmentObject private var gameModel: GameModel
    @EnvironmentObject private var appModel: AppModel
    
    @Environment(\.presentationMode) var presentationMode
    
    func handleStart() {
        gameModel.setTime(timeIndex: timeIndex)
        gameModel.setDifficulty(difficultyIndex: difficultyIndex)
        gameModel.totQuestions = Int(round(progress))
        
        appModel.path.append(AppState.GAME)
    }
    
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                Color.white
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                
                VStack(spacing: 20) {
                    VStack(spacing: 5) {
                        HStack(spacing: 20) {
                            Button(action: {}, label: {
                                Image(systemName: "minus")
                            })
                            .font(.subheadline)
                            .foregroundStyle(Color("darkPurple"))
                            .bold()
                            .padding(.horizontal, 6)
                            .frame(height: 25)
                            .raisedButton(impactStrength: .soft, cornerRadius: 10, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: 3, action: {
                                progress -= 1
                            })
                            
                            RollingNumber(number: progressString, color: Color("darkPurple"), digitWidth: 22, digitHeight: 38)
                            
                            Button(action: {}, label: {
                                Image(systemName: "plus")
                            })
                            .font(.subheadline)
                            .foregroundStyle(Color("darkPurple"))
                            .bold()
                            .padding(.horizontal, 6)
                            .frame(height: 25)
                            .raisedButton(impactStrength: .soft, cornerRadius: 10, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: 3, action: {
                                progress += 1
                            })
                        }
                        
                        Slider(value: $progress, in: 10...99)
                            .tint(Color("darkPurple"))

                        Text("number of problems")
                            .font(metrics.size.height < 736 ? .subheadline : .headline)
                            .fontWeight(.heavy)
                            .foregroundStyle(Color("lightPurple"))

                        
                    }
                    .padding(15)
                    .background(.white)
                    .roundedCorner(20, corners: .allCorners)
                    .clipped()
                    .shadow(radius: 2)

//                    VStack(spacing: 10) {
//                        QuestionSlider(value: $progress, in: 10...100)
//                            .frame(width: metrics.size.height * 0.18, height: metrics.size.height * 0.18)
//                        Text("number of questions")
//                            .font(metrics.size.height < 736 && metrics.size.width < 390 ? .headline : .title3)
//                            .foregroundColor(Color("lightPurple"))
//                            .bold()
//                    }
//                    .onChange(of: progress, perform: { _ in
//                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
//                    })
                    
                    HStack(spacing: 20) {
                        DifficultySelector(difficultyIndex: $difficultyIndex, metrics: metrics)
                        
                        TimeSelector(timeIndex: $timeIndex, metrics: metrics)
                    }
                                            
                    Spacer()
                    
                    VStack(spacing: 35) {
                        Button(action: {}, label: {
                            HStack {
                                Text("start")
                                
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(Color("darkPurple"))
                            .font(.title2)
                            .fontWeight(.heavy)
                        })
                        .padding(15)
                        .frame(maxWidth: .infinity)
                        .raisedButton(impactStrength: .heavy, cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: 11,
                                      action: {
                            handleStart()
                        })
                        //: Start Button
                        
                        Button(action: {
                            appModel.path.removeLast()
                        }, label: {
                            Text("back to home")
                                .foregroundStyle(Color("darkPurple"))
                        })
                        .font(.body)
                        .fontWeight(.heavy)
                    }
                } //: VStack
                .padding(20)
                
            } // ZStack
            
        }
        
    }
}

#Preview {
    ExtraOptionsView()
        .environmentObject(GameModel())
        .environmentObject(AppModel(path: NavigationPath()))
}




