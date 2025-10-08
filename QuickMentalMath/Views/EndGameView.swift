//
//  EndGameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 6/4/23.
//

import SwiftUI
import ConfettiSwiftUI

struct EndGameView: View {
    @State var newHighScore = false
    @State var newTtHighScore = false
    @State var saying: String = ""
    @State var confettiTrigger = 0
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var device: DeviceModel
    
    let numCorrect: Int
    let missedQuestions: [MissedQuestion]
    let questionCount: Int
    let gameConfigs: GameConfigsModel
    
    let percentage: Double

    
    init(endGameModel: EndGameModel) {
        self.numCorrect = endGameModel.game.numCorrect
        self.missedQuestions = endGameModel.game.missedQuestions
        self.questionCount = endGameModel.game.questionCount
        self.gameConfigs = endGameModel.gameConfigs
        
        if endGameModel.gameConfigs.mode == .TIME {
            self.percentage = Double((Float(self.numCorrect) / Float(self.questionCount - 1)) * 100)
        }
        else {
            self.percentage = Double((Float(self.numCorrect) / Float(self.gameConfigs.numQuestions)) * 100)
        }
    }
    
    let perfectSayings = [
        "a perfect score. you must be a genius.",
        "you sort of cooked here.",
        "we have a perfectionist on our hands.",
        "the perfect game.",
        "i see a goat here."
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 30)) {
                Text("your results")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.largeTitle)
                    .foregroundStyle(Color("darkPurple"))
                    .bold()
                                
                VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 35)) {
                    if newHighScore || newTtHighScore {
                        VStack(spacing: 5) {
                            Text("new high score")
                                .foregroundStyle(Color("vividPurple"))
                                .fontWeight(.heavy)
                                .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title2))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text("\(newHighScore ? (authInfo.user?.stats?.highScore ?? 0) : (authInfo.user?.stats?.ttHighScore ?? 0))")
                                    .font(device.valueByDevice(small: .largeTitle, normal: .largeTitle, ipad: Font.system(size: 60)))
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color("darkPurple"))
                                
                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(Color("vividPurple"))
                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .largeTitle))
                                
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, device.valueByDevice(small: 20, normal: 20, ipad: 30))
                        .padding(.vertical, 15)
                        .raisedButton(cornerRadius: 20, backgroundColor: Color("gold"), shadowColor: Color("darkYellow"), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                        .confettiCannon(trigger: $confettiTrigger, num: 50, colors: [Color("darkPurple"), Color("lightPurple"), Color("lighterPurple")], openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200, repetitions: 4, repetitionInterval: 0.3)
                        .zIndex(1000)
                        .onAppear {
                            confettiTrigger += 1
                        }
                        .allowsHitTesting(false)
                    }
                    
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("accuracy")
                                .foregroundStyle(Color("lightPurple"))
                                .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title3))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text("\(Int(percentage))%")
                                    .foregroundStyle(Color("darkPurple"))
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: .largeTitle))
                                    .fontWeight(.heavy)
                                    
                                Spacer()
                                
                                Image(systemName: "scope")
                                    .font(device.valueByDevice(small: .body, normal: .body, ipad: .title))
                                    .foregroundStyle(Color("vividPurple"))
                                    .fontWeight(.heavy)
                            }

                        }
                        .padding(.horizontal, device.valueByDevice(small: 15, normal: 15, ipad: 20))
                        .padding(.vertical, device.valueByDevice(small: 12, normal: 12, ipad: 17))
                        .frame(maxWidth: .infinity)
                        .raisedButton(cornerRadius: 20, backgroundColor: Color("silver"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                        .allowsHitTesting(false)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("score")
                                .foregroundStyle(Color("lightPurple"))
                                .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title3))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack {
                                Text("\(numCorrect)")
                                    .foregroundStyle(Color("darkPurple"))
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: .largeTitle))
                                    .fontWeight(.heavy)
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .font(device.valueByDevice(small: .body, normal: .body, ipad: .title))
                                    .foregroundStyle(Color("pastelBlue"))
                            }
                        }
                        .padding(.horizontal, device.valueByDevice(small: 15, normal: 15, ipad: 20))
                        .padding(.vertical, device.valueByDevice(small: 12, normal: 12, ipad: 17))
                        .frame(maxWidth: .infinity)
                        .raisedButton(cornerRadius: 20, backgroundColor: Color("silver"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {})
                        .allowsHitTesting(false)
                    }
                    
                    if !missedQuestions.isEmpty {
                        MissedQuestionsDisplay(missedQuestions: missedQuestions)
                            .frame(maxHeight: .infinity)
                    }
                    else if missedQuestions.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 10) {
                            Image(systemName: "trophy.fill")
                                .font(Font.system(size: device.valueByDevice(small: 75, normal: 85, ipad: 125)))
                                .foregroundStyle(Color("darkPurple"))
                                .offset(x: 0, y: 5)
                                .overlay(
                                    Image(systemName: "trophy.fill")
                                        .font(Font.system(size: device.valueByDevice(small: 75, normal: 85, ipad: 125)))
                                        .foregroundStyle(Color("gold"))
                                )
                            
                            Text("\(saying)")
                                .foregroundStyle(Color("darkPurple"))
                                .fontWeight(.heavy)
                                .italic()
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 15)
                                .font(device.valueByDevice(small: .body, normal: .body, ipad: .title2))
                        }
                        .confettiCannon(trigger: $confettiTrigger, num: 50, colors: [Color("gold"), Color("darkYellow"), Color("lightPurple")], openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200, repetitions: 4, repetitionInterval: 0.3)
                        .zIndex(1000)
                        .onAppear {
                            if !newHighScore && !newTtHighScore {
                                confettiTrigger += 1
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: device.valueByDevice(small: 35, normal: 35, ipad: 40)) {
                        Button(action: {}, label: {
                            HStack {
                                Image(systemName: "arrow.left")
                                
                                Text("play again")
                            }
                            .foregroundStyle(Color("darkPurple"))
                            .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                            .fontWeight(.heavy)
                        })
                        .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
                        .frame(maxWidth: .infinity)
                        .raisedButton(impactStrength: .heavy, cornerRadius: 20, backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 11, normal: 11, ipad: 13),
                                      action: {
                            
                            let newGame = GameModel(gameConfigs: gameConfigs)
                            
                            appModel.path.removeLast()
                            appModel.path.removeLast()
                            appModel.path.append(newGame)
                        })
                        
                        Button(action: {
                            appModel.path = NavigationPath([AuthState.UNAUTHORIZED, authInfo.authState])
                        }, label: {
                            Text("back to home")
                                .foregroundStyle(Color("darkPurple"))
                        })
                        .font(device.valueByDevice(small: .headline, normal: .headline, ipad: .title3))
                        .fontWeight(.heavy)
                    }
                }
            }
            .padding(device.valueByDevice(small: 15, normal: 20, ipad: 30))
        } //: ZStack
        .onAppear {
            saying = perfectSayings.randomElement()!
            
            if authInfo.authState == .AUTHORIZED && authInfo.user != nil {
                
                switch self.gameConfigs.mode {
                case .ADDITION:
                    authInfo.user?.stats?.additionScore += numCorrect
                    authInfo.user?.stats?.additionTot += self.gameConfigs.numQuestions
                case .SUBTRACTION:
                    authInfo.user?.stats?.subtractionScore += numCorrect
                    authInfo.user?.stats?.subtractionTot += self.gameConfigs.numQuestions
                case .MULTIPLICATION:
                    authInfo.user?.stats?.multiplicationScore += numCorrect
                    authInfo.user?.stats?.multiplicationTot += self.gameConfigs.numQuestions
                case .DIVISION:
                    authInfo.user?.stats?.divisionScore += numCorrect
                    authInfo.user?.stats?.divisionTot += self.gameConfigs.numQuestions
                default:
                    break
                }
                
                if numCorrect > (authInfo.user?.stats!.highScore)! {
                    newHighScore = true
                }
                
                if self.gameConfigs.mode == .TIME && numCorrect > (authInfo.user?.stats!.ttHighScore)! {
                    newTtHighScore = true
                    authInfo.user?.stats?.ttHighScore = numCorrect
                }
                
                authInfo.user?.stats?.highScore = max((authInfo.user?.stats!.highScore)!, numCorrect)
                
                Task {
                    let statsRequest = UserStatsRequest(userStats: (authInfo.user?.stats)!)
                    let _ = await authInfo.updateUserStats(statsRequest: statsRequest)
                }
            }
        }
    } // body
    
}

//#Preview {
//    
//    let missed = [
//        MissedQuestion(question: "5 + 5", userAns: "8", correctAns: "10"),
//        MissedQuestion(question: "8 + 5", userAns: "8", correctAns: "13"),
//        MissedQuestion(question: "5 + 5", userAns: "8", correctAns: "10")
//    ]
//    let gameModel = GameModel(mode: "+", difficulty: "easy", totQuestions: 15, score: 10, missedQuestions: [])
//    
//    return GeometryReader { screen in
//        EndGameView()
//            .environmentObject(AuthInfoModel())
//            .environmentObject(AppModel(path: NavigationPath()))
//            .environmentObject(gameModel)
//            .environmentObject(DeviceModel(screen: screen))
//    }
//}
