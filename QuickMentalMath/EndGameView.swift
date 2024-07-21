//
//  EndGameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 6/4/23.
//

import SwiftUI

//struct AnimatableNumberModifier: AnimatableModifier {
//    var number: Double
//
//    var animatableData: Double {
//        get { number }
//        set { number = newValue }
//    }
//
//    func body(content: Content) -> some View {
//        content
//            .overlay(
////                Text("\(Int(number))%")
//                Text("0%")
//            )
//    }
//}

//extension View {
//    func animatingOverlay(for number: Double) -> some View {
//        modifier(AnimatableNumberModifier(number: number))
//    }
//}

struct EndGameView: View {
    
    @State var percentage: Double = 0
    @State var uiPercentage: Double = 0
    
    @State var isGoHome = false
    @State var isRedo = false
    @State var isReviewing = false
    @State var newHighScore = false
    @State var newTtHighScore = false
    @State var rotation: CGFloat = 0.0
    
    @EnvironmentObject var gameModel: GameModel
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfo
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 50) {
                    VStack(spacing: 20) {
                        HStack {
                            VStack {
                                Text("Game over")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.title)
                                    .foregroundStyle(Color("darkPurple"))
                                
                                Text("Your results")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.largeTitle)
                                    .foregroundStyle(Color("lightPurple"))
                                
                            } //: Title VStack
                            .bold()
                            
                            Spacer()
                            
                            Button(action: {
                                gameModel.reset()
                                appModel.path = NavigationPath([AuthState.UNAUTHORIZED, authInfo.authState])
                            }, label: {
                                Image(systemName: "house")
                                    .font(.title2)
                                    .foregroundStyle(Color("darkPurple"))
                                    .bold()
                            })
                        }
                                                
                        VStack(spacing: 20) {
                            if newHighScore && screen.size.width > 0 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.white)
                                        .frame(width: screen.size.width - 40, height: 75)
                                        .shadow(color: Color("lighterPurple"), radius: 3)
                                    
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .frame(width: screen.size.width - 40, height: 100)
                                        .foregroundStyle(LinearGradient(colors: [Color("lightPurple"), Color("lighterPurple"), Color("darkPurple")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .rotationEffect(.degrees(rotation))
                                        .mask {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(lineWidth: 3)
                                                .frame(width: screen.size.width - 40, height: 75)
                                            
                                        }
                                    
                                    Text("NEW HIGH SCORE: \(authInfo.user?.stats!.highScore ?? 0)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("darkPurple"))
                                }
                            }
                            else if newTtHighScore && screen.size.width > 0 {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.white)
                                        .frame(width: screen.size.width - 40, height: 75)
                                        .shadow(color: Color("lighterPurple"), radius: 3)
                                    
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .frame(width: screen.size.width - 40, height: 100)
                                        .foregroundStyle(LinearGradient(colors: [Color("lightPurple"), Color("lighterPurple"), Color("darkPurple")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .rotationEffect(.degrees(rotation))
                                        .mask {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(lineWidth: 3)
                                                .frame(width: screen.size.width - 40, height: 75)
                                            
                                        }
                                    
                                    Text("NEW TIME TRIAL HIGH SCORE: \(authInfo.user?.stats!.ttHighScore ?? 0)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color("darkPurple"))
                                }
                            }
                            
                            VStack(spacing: 20) {
                                VStack(spacing: 15) {
                                    HStack {
                                        Text("Performance")
                                            .foregroundStyle(Color("darkPurple"))
                                        
                                        Spacer()
                                        
                                        Text("\(Int(percentage))%")
                                            .foregroundStyle(Color("lightPurple"))
                                    }
                                    
                                    Rectangle()
                                        .foregroundStyle(Color.gray.opacity(0.2))
                                        .frame(height: 4)
                                        .overlay(
                                            GeometryReader { metrics in
                                                Rectangle()
                                                    .foregroundStyle(percentage <= 25 ? Color.red : percentage > 25 && percentage <= 50 ? Color.orange : percentage > 50 && percentage <= 75 ? Color.yellow : Color.green)
                                                    .frame(width: (percentage / 100) * metrics.size.width, height: 4)
                                            }
                                        )
                                }
                                
                                HStack {
                                    Text("Score: \(gameModel.score)")
                                    
                                    Spacer()
                                    
                                    Text("Questions: \(gameModel.mode == "time" ? gameModel.questionCount - 1 : gameModel.totQuestions)")
                                }
                                .foregroundStyle(Color("darkPurple"))
                            } //: Performance VStack
                            .font(.headline)
                            .padding(20)
                            .bold()
                            .clipped()
                            .background(
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.white)
                                        .shadow(color: Color("lighterPurple"), radius: 3)
                                }
                                
                            )
                            
                            if !gameModel.missedQuestions.isEmpty {
                                VStack(spacing: 20) {
                                    Text("Missed questions")
                                        .foregroundStyle(Color("darkPurple"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    MissedQuestionsView(missedQuestions: gameModel.missedQuestions)
                                        .frame(height: 125)
                                } //: Performance VStack
                                .font(.headline)
                                .padding(20)
                                .bold()
                                .background(
                                    Color.white
                                )
                                .roundedCorner(10, corners: .allCorners)
                                .clipped()
                                .shadow(color: Color("lighterPurple"), radius: 3)
                            }
                        } //: VStack
                    }
                    
                    HStack {
                        Button(action: {
                            gameModel.playAgain()
                            appModel.path.removeLast()
                        }, label: {
                            HStack {
                                Image(systemName: "arrow.left")
                                
                                Text("Play again")
                            }
                        })
                        
                        Spacer()
                    }
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundStyle(Color("darkPurple"))
                    
                    Spacer()
                } //: Parent VStack
                .padding(20)
            } //: ZStack
            .onAppear {
                withAnimation(.linear(duration: 0.85)) {
                    if gameModel.mode == "time" {
                        percentage = Double((Float(gameModel.score) / Float(gameModel.questionCount - 1)) * 100)

                    }
                    else {
                        percentage = Double((Float(gameModel.score) / Float(gameModel.totQuestions)) * 100)
                    }
                }
                
                if authInfo.authState == .AUTHORIZED && authInfo.user != nil {

                    switch gameModel.mode {
                    case "+":
                        authInfo.user?.stats?.additionScore += gameModel.score
                        authInfo.user?.stats?.additionTot += gameModel.totQuestions
                    case "-":
                        authInfo.user?.stats?.subtractionScore += gameModel.score
                        authInfo.user?.stats?.subtractionTot += gameModel.totQuestions
                    case "x":
                        authInfo.user?.stats?.multiplicationScore += gameModel.score
                        authInfo.user?.stats?.multiplicationTot += gameModel.totQuestions
                    case "÷":
                        authInfo.user?.stats?.divisionScore += gameModel.score
                        authInfo.user?.stats?.divisionTot += gameModel.totQuestions
                    default:
                        break
                    }

                    if gameModel.score > (authInfo.user?.stats!.highScore)! {
                        newHighScore = true
                    }
                    
                    if gameModel.mode == "time" && gameModel.score > (authInfo.user?.stats!.ttHighScore)! {
                        newTtHighScore = true
                        authInfo.user?.stats?.ttHighScore = gameModel.score
                    }
                    
                    if newHighScore || newTtHighScore {
                        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }

                    authInfo.user?.stats?.highScore = max((authInfo.user?.stats!.highScore)!, gameModel.score)

                    Task {
                        let statsRequest = UserStatsRequest(userStats: (authInfo.user?.stats)!)
                        let _ = await authInfo.updateUserStats(statsRequest: statsRequest)
                    }
                }
            }
        }
    } // body
    
}
