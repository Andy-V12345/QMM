//
//  LastPracticeDisplay.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/18/25.
//

import SwiftUI

struct LastPracticeDisplay: View {

    let gameModel: GameModel

    @State var showPercentage = false

    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var device: DeviceModel

    // Computed properties for display
    private var modeName: String {
        switch gameModel.gameConfigs.mode {
        case .ADDITION: return "addition"
        case .SUBTRACTION: return "subtraction"
        case .MULTIPLICATION: return "multiplication"
        case .DIVISION: return "division"
        case .TIME: return "time trial"
        }
    }
    
    private var circleDisplay: String {
        if showPercentage {
            if gameModel.questionCount - 1 <= 0 { return "0%" }
            
            let percentage = Double((Float(gameModel.numCorrect) / Float(totalQuestions)) * 100)
            
            return "\(Int(percentage))%"
        }
        else {
            return "\(gameModel.numCorrect) / \(totalQuestions)"
        }
    }

    private var modeColor: Color {
        switch gameModel.gameConfigs.mode {
        case .ADDITION: return Color("pastelPurple")
        case .SUBTRACTION: return Color("pastelBlue")
        case .MULTIPLICATION: return Color("pastelRed")
        case .DIVISION: return Color("pastelGreen")
        case .TIME: return Color("pastelPink")
        }
    }

    private var difficultyName: String {
        switch gameModel.gameConfigs.difficulty {
        case .EASY: return "easy"
        case .MEDIUM: return "medium"
        case .HARD: return "hard"
        case .DECIMALS: return "decimals"
        }
    }

    private var difficultyColor: Color {
        switch gameModel.gameConfigs.difficulty {
        case .EASY: return Color("lightGreen")
        case .MEDIUM: return Color("pastelOrange")
        case .HARD: return Color("errorRed")
        case .DECIMALS: return Color("pastelPurple")
        }
    }

    private var timeLimitText: String {
        switch gameModel.gameConfigs.timeLimit {
        case .ONE_MIN: return "1 min"
        case .TWO_MIN: return "2 min"
        case .THREE_MIN: return "3 min"
        case .NO_LIMIT: return "no limit"
        }
    }

    private var totalQuestions: Int {
        return gameModel.questionCount - 1
    }

    private var progressPercentage: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(gameModel.numCorrect) / Double(totalQuestions)
    }

    var body: some View {
        VStack(spacing: device.valueByDevice(small: 25, normal: 25, ipad: 30)) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: device.valueByDevice(small: 15, normal: 15, ipad: 25)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("mode")
                            .foregroundStyle(Color.gray)
                            .fontWeight(.semibold)
                            .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title2))

                        Text(modeName)
                            .foregroundStyle(modeColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)


                    VStack(alignment: .leading, spacing: 2) {
                        Text("difficulty")
                            .foregroundStyle(Color.gray)
                            .fontWeight(.semibold)
                            .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title2))

                        Text(difficultyName)
                            .foregroundStyle(difficultyColor)
                    }


                    VStack(alignment: .leading, spacing: 2) {
                        Text("time")
                            .foregroundStyle(Color.gray)
                            .fontWeight(.semibold)
                            .font(device.valueByDevice(small: .subheadline, normal: .subheadline, ipad: .title2))

                        Text(timeLimitText)
                            .foregroundStyle(Color("darkPurple"))
                    }
                        
                }
                .font(device.valueByDevice(small: .title3, normal: .title3, ipad: .title))
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity)
                
                Spacer()
                                                
                ZStack {
                    Circle().stroke(Color.gray.opacity(0.4), lineWidth: device.valueByDevice(small: 10, normal: 10, ipad: 15))
                        .frame(maxWidth: device.valueByDevice(small: 120, normal: 130, ipad: 225))
                        .overlay(
                            Circle()
                                .trim(from: 0.0, to: progressPercentage)
                                .stroke(Color("lightPurple"), lineWidth: device.valueByDevice(small: 10, normal: 10, ipad: 15))
                                .rotationEffect(Angle(degrees: -90))
                        )

                    Text(circleDisplay)
                        .font(device.valueByDevice(small: .title2, normal: .title, ipad: .largeTitle))
                        .foregroundStyle(Color("darkPurple"))
                        .fontWeight(.heavy)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding([.vertical, .leading], device.valueByDevice(small: 15, normal: 15, ipad: 30))
            .padding(.trailing, device.valueByDevice(small: 20, normal: 20, ipad: 35))
            .raisedButton(cornerRadius: 20, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.4), shadowOffset: device.valueByDevice(small: 6, normal: 6, ipad: 8), action: {
                showPercentage.toggle()
            })
            
            Button(action: {}, label: {
                HStack {
                    Text("play again")

                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(Color("darkPurple"))
                .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .title))
                .fontWeight(.heavy)
            })
            .padding(device.valueByDevice(small: 12, normal: 15, ipad: 15))
            .frame(maxWidth: .infinity)
            .raisedButton(impactStrength: .heavy, cornerRadius: 20, shadowOffset: device.valueByDevice(small: 11, normal: 11, ipad: 13), action: {
                // Create a new game with the same configuration
                let newGame = GameModel(gameConfigs: gameModel.gameConfigs)
                appModel.path.append(gameModel.gameConfigs)
                appModel.path.append(newGame)
            })
        }
    }
}

#Preview {
    let config = GameConfigsModel(mode: .ADDITION, difficulty: .EASY, timeLimit: .NO_LIMIT, numQuestions: 10)
    let game = GameModel(numCorrect: 7, numIncorrect: 3, missedQuestions: [], questionCount: 10, gameConfigs: config)

    return GeometryReader { screen in
        ZStack {
            Color.white.ignoresSafeArea()

            LastPracticeDisplay(gameModel: game)
                .padding(.horizontal, 20)
                .environmentObject(AppModel(path: NavigationPath()))
                .environmentObject(DeviceModel(screen: screen))
        }
    }
}
