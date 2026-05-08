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
    @State var showFraction = false
    @State var showNumQuestions = false
    @State var isConfettiOnCooldown = false

    // Local stats state
    @State private var userStats: UserStats?
    @State private var isLoading: Bool = true
    @State private var isErrorFetchingStats = false

    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var authInfo: AuthInfoModel
    @EnvironmentObject var device: DeviceModel
    
    let numCorrect: Int
    let totQuestions: Int
    let missedQuestions: [MissedQuestion]
    let questionCount: Int
    let gameConfigs: GameConfigsModel
    
    let percentage: Double

    
    init(endGameModel: EndGameModel) {
        self.numCorrect = endGameModel.game.numCorrect
        self.missedQuestions = endGameModel.game.missedQuestions
        self.questionCount = endGameModel.game.questionCount
        self.gameConfigs = endGameModel.gameConfigs
        self.totQuestions = self.questionCount - 1

        if self.totQuestions == 0 {
            self.percentage = 0
        }
        else {
            self.percentage = Double((Float(self.numCorrect) / Float(self.totQuestions)) * 100)
        }

    }

    private func fetchUserStats() async {
        guard let user = authInfo.user else { return }

        do {
            if let stats = try await AuthService.loadUserStats(userId: user.id, jwtToken: user.jwtToken) {
                await MainActor.run {
                    isErrorFetchingStats = false
                    userStats = stats
                }
            }
        }
        catch {
            isErrorFetchingStats = true
            isLoading = false
        }
    }

    private func calculateAndUpdateStats() async {
        guard let user = authInfo.user,
              var currentStats = userStats else { return }

        // Update operation-specific stats
        switch self.gameConfigs.mode {
        case .ADDITION:
            currentStats.additionScore += numCorrect
            currentStats.additionTot += self.gameConfigs.numQuestions
        case .SUBTRACTION:
            currentStats.subtractionScore += numCorrect
            currentStats.subtractionTot += self.gameConfigs.numQuestions
        case .MULTIPLICATION:
            currentStats.multiplicationScore += numCorrect
            currentStats.multiplicationTot += self.gameConfigs.numQuestions
        case .DIVISION:
            currentStats.divisionScore += numCorrect
            currentStats.divisionTot += self.gameConfigs.numQuestions
        default:
            break
        }

        // Check for high score
        if numCorrect > currentStats.highScore {
            await MainActor.run {
                newHighScore = true
            }
        }

        // Check for time trial high score
        if self.gameConfigs.mode == .TIME && numCorrect > currentStats.ttHighScore {
            await MainActor.run {
                newTtHighScore = true
            }
            currentStats.ttHighScore = numCorrect
        }

        // Update high score
        currentStats.highScore = max(currentStats.highScore, numCorrect)

        // Update stats on backend
        let statsRequest = UserStatsRequest(userStats: currentStats)
        let success = await AuthService.updateUserStats(
            userId: user.id,
            statId: currentStats.id,
            jwtToken: user.jwtToken,
            statsRequest: statsRequest
        )

        if success {
            await MainActor.run {
                userStats = currentStats
                isLoading = false
            }
        } else {
            // Even if update fails, show the view with calculated stats
            await MainActor.run {
                userStats = currentStats
                isLoading = false
            }
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
                VStack(spacing: 15) {
                    if isErrorFetchingStats {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.white)
                            
                            Text("failed to update your stats")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                        }
                        .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title3))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .raisedButton(backgroundColor: Color("errorRed"), shadowColor: Color("darkErrorRed"), shadowOffset: 2, action: {})
                        .allowsHitTesting(false)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Text("your results")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.largeTitle)
                        .foregroundStyle(Color("darkPurple"))
                        .bold()
                }
                .animation(.easeInOut(duration: 0.3), value: isErrorFetchingStats)                
                                
                VStack(spacing: device.valueByDevice(small: 20, normal: 20, ipad: 35)) {
                    if newHighScore || newTtHighScore {
                        VStack(spacing: 5) {
                            Text("new high score")
                                .foregroundStyle(Color("lightPurple"))
                                .fontWeight(.heavy)
                                .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title2))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text("\(newHighScore ? (userStats?.highScore ?? 0) : (userStats?.ttHighScore ?? 0))")
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: .largeTitle))
                                    .fontWeight(.heavy)
                                    .foregroundStyle(Color("darkPurple"))

                                Image(systemName: "bolt.fill")
                                    .foregroundStyle(Color("lightPurple"))
                                    .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .largeTitle))

                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, device.valueByDevice(small: 20, normal: 20, ipad: 30))
                        .padding(.vertical, 15)
                        .raisedButton(cornerRadius: 20, backgroundColor: Color("gold"), shadowColor: Color("darkYellow"), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {
                            guard !isConfettiOnCooldown else { return }

                            confettiTrigger += 1
                            HapticManager.shared.trigger(.heavy)
                            isConfettiOnCooldown = true

                            Task {
                                try? await Task.sleep(nanoseconds: 2_700_000_000) // 2.7 seconds
                                isConfettiOnCooldown = false
                            }
                        })
                        .confettiCannon(trigger: $confettiTrigger, num: 50, colors: [Color("darkPurple"), Color("lightPurple"), Color("lighterPurple")], openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200, repetitions: 4, repetitionInterval: 0.3)
                        .zIndex(1000)
                        .onAppear {
                            confettiTrigger += 1
                        }
                    }
                    
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("accuracy")
                                .foregroundStyle(Color("lightPurple"))
                                .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title3))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Text(showFraction ? "\(numCorrect)/\(totQuestions)" :  "\(Int(percentage))%")
                                    .foregroundStyle(Color("darkPurple"))
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: .largeTitle))
                                    .fontWeight(.heavy)
                                    .lineLimit(1)
                                    
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
                        .raisedButton(cornerRadius: 20, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {
                            
                            showFraction.toggle()
                        })
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(showNumQuestions ? "questions" : "score")
                                .foregroundStyle(Color("lightPurple"))
                                .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title3))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack {
                                Text(showNumQuestions ? "\(totQuestions)" : "\(numCorrect)")
                                    .foregroundStyle(Color("darkPurple"))
                                    .font(device.valueByDevice(small: .title, normal: .title, ipad: .largeTitle))
                                    .fontWeight(.heavy)
                                
                                Spacer()
                                
                                Image(systemName: showNumQuestions ? "list.clipboard.fill" : "checkmark.seal.fill")
                                    .font(device.valueByDevice(small: .body, normal: .body, ipad: .title))
                                    .foregroundStyle(Color(showNumQuestions ? "pastelBlue" : "correctGreen"))
                            }
                        }
                        .padding(.horizontal, device.valueByDevice(small: 15, normal: 15, ipad: 20))
                        .padding(.vertical, device.valueByDevice(small: 12, normal: 12, ipad: 17))
                        .frame(maxWidth: .infinity)
                        .raisedButton(cornerRadius: 20, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {
                            
                            showNumQuestions.toggle()
                        })
                    }
                    
                    if !missedQuestions.isEmpty {
                        MissedQuestionsDisplay(missedQuestions: missedQuestions)
                            .frame(maxHeight: .infinity)
                    }
                    else if missedQuestions.isEmpty && percentage == 100 {
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
                        .raisedButton(impactStrength: .heavy, cornerRadius: device.valueByDevice(small: 18, normal: 20, ipad: 20), backgroundColor: Color("lighterPurple"), shadowColor: Color("lightPurple"), shadowOffset: device.valueByDevice(small: 8, normal: 8, ipad: 12),
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

            // Loading Overlay
            if isLoading {
                ZStack {
                    Color.white.ignoresSafeArea()

                    VStack(spacing: 20) {
                        BouncingDotsLoader(dotSize: 10)

                        Text("finalizing results...")
                            .font(device.valueByDevice(small: .title3, normal: .title2, ipad: .title))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("darkPurple"))
                    }
                }
            }
        } //: ZStack
        .onAppear {
            saying = perfectSayings.randomElement()!

            // Save the last played game to local storage
            let gameModel = GameModel(numCorrect: numCorrect, numIncorrect: numCorrect + missedQuestions.count, missedQuestions: missedQuestions, questionCount: questionCount, gameConfigs: gameConfigs)
            UserDefaults.standard.saveLastGame(gameModel)

            // Fetch and update stats if user is authorized
            if authInfo.authState == .AUTHORIZED && authInfo.user != nil {
                Task {
                    await fetchUserStats()
                    await calculateAndUpdateStats()
                }
            } else {
                // No user logged in, skip loading
                isLoading = false
            }
        }
    } // body
    
}

#Preview {
    
    let missed = [
        MissedQuestion(question: "5 + 5", userAns: "8", correctAns: "10"),
        MissedQuestion(question: "8 + 5", userAns: "8", correctAns: "13"),
        MissedQuestion(question: "5 + 5", userAns: "8", correctAns: "10")
    ]
    
    let game = GameModel(numCorrect: 10, numIncorrect: 3, missedQuestions: [], questionCount: 50, gameConfigs: GameConfigsModel(mode: .ADDITION, difficulty: .MEDIUM, timeLimit: .ONE_MIN, numQuestions: 50))
    
    return GeometryReader { screen in
        EndGameView(endGameModel: EndGameModel(game: game))
            .environmentObject(AuthInfoModel())
            .environmentObject(AppModel(path: NavigationPath()))
            .environmentObject(DeviceModel(screen: screen))
    }
}
