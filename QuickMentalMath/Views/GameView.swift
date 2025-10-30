//
//  GameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/15/23.
//

import SwiftUI

struct GameView: View {
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let numSize: CGFloat = 0.11
    let keyColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0, alignment: .center), count: 3)
    let keyNums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 11, 12]
    
    @State var numCorrect: Int
    @State var numIncorrect: Int
    @State var numQuestions: Int
    @State var mode: GameMode
    @State var difficulty: GameDifficulty
    @State var timeLimit: TimeLimit
    @State var missedQuestions: [MissedQuestion]
    @State var questionCount: Int

    
    @State var input: String = "f"
    @State var timeLeft: CGFloat = 0
    @State var num1: Double = 0
    @State var num2: Double = 0
    @State var answer: Double = 0
    @State var tmpMode = ""
    
    @State var topSize = 0.65

    
    @State var isGameOver = false
    @State var showAreYouSure = false
    @State var isTimerPaused = false
    
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var device: DeviceModel

    init(gameModel: GameModel) {
        self.numCorrect = gameModel.numCorrect
        self.numIncorrect = gameModel.numIncorrect
        self.questionCount = gameModel.questionCount
        self.numQuestions = gameModel.gameConfigs.numQuestions
        self.timeLimit = gameModel.gameConfigs.timeLimit
        self.timeLeft = gameModel.gameConfigs.timeLimit.rawValue
        self.difficulty = gameModel.gameConfigs.difficulty
        self.mode = gameModel.gameConfigs.mode
        self.missedQuestions = []
    }

    // MARK: - Game Logic Methods

    private func checkAnswer() -> Bool {
        return answer.isEqual(to: Double(input)!)
    }

    private func newQuestion(mode: String) {
        input = "f"

        if mode == "+" {
            if difficulty == .EASY {
                num1 = Double(Int.random(in: 0...10))
                num2 = Double(Int.random(in: 0...10))
            }
            else if difficulty == .MEDIUM {
                num1 = Double(Int.random(in: 5...50))
                num2 = Double(Int.random(in: 5...50))
            }
            else if difficulty == .HARD {
                num1 = Double(Int.random(in: 10...200))
                num2 = Double(Int.random(in: 10...200))
            }
            else {
                num1 = round(100.0 * Double.random(in: 0.01...10)) / 100.0
                num2 = round(100.0 * Double.random(in: 0.01...10)) / 100.0
            }
            answer = num1 + num2
        }
        else if mode == "-" {
            if difficulty == .EASY {
                num1 = Double(Int.random(in: 5...10))
                num2 = Double(Int.random(in: 0...10))
                while num2 > num1 {
                    num2 = Double(Int.random(in: 0...10))
                }
            }
            else if difficulty == .MEDIUM {
                num1 = Double(Int.random(in: 10...30))
                num2 = Double(Int.random(in: 5...30))
                while num2 > num1 {
                    num2 = Double(Int.random(in: 5...30))
                }
            }
            else if difficulty == .HARD {
                num1 = Double(Int.random(in: 10...500))
                num2 = Double(Int.random(in: 10...400))
                while num2 > num1 {
                    num2 = Double(Int.random(in: 10...500))
                }
            }
            else {
                num1 = round(100.0 * Double.random(in: 10...20)) / 100.0
                num2 = round(100.0 * Double.random(in: 0.01..<10)) / 100.0
                while num2 > num1 {
                    num2 = round(100.0 * Double.random(in: 0.01..<10)) / 100.0
                }
            }
            answer = num1 - num2
        }
        else if mode == "x" {
            if difficulty == .EASY {
                num1 = Double(Int.random(in: 1...5))
                num2 = Double(Int.random(in: 0...5))
            }
            else if difficulty == .MEDIUM {
                num1 = Double(Int.random(in: 1...12))
                num2 = Double(Int.random(in: 0...12))
            }
            else if difficulty == .HARD {
                num1 = Double(Int.random(in: 5...40))
                num2 = Double(Int.random(in: 5...40))
            }
            else {
                num1 = round(100.0 * Double.random(in: 0.01...20)) / 100.0
                num2 = Double(Int.random(in: 1...20))
            }
            answer = num1 * num2
        }
        else {
            if difficulty == .EASY {
                num1 = Double(Int.random(in: 10...20))
                num2 = Double(Int.random(in: 1...10))

                while Int(num1) % Int(num2) != 0 {
                    num1 = Double(Int.random(in: 10...20))
                    num2 = Double(Int.random(in: 1...10))
                }
            }
            else if difficulty == .MEDIUM {

                let choices = Array(1...12)

                let productNums = [choices.randomElement()!, choices.randomElement()!]

                num1 = Double(productNums[0] * productNums[1])
                num2 = Double(productNums.randomElement()!)

            }
            else {
                let choices = Array(5...20)

                let productNums = [choices.randomElement()!, choices.randomElement()!]

                num1 = Double(productNums[0] * productNums[1])
                num2 = Double(productNums.randomElement()!)
            }
            answer = num1 / num2
        }
    }

    private func randomMode() -> String {
        let modes = ["+", "-", "x", "÷"]
        tmpMode = modes.randomElement()!
        return tmpMode
    }

    func handleKeypadClick(id: String) {
        if Int(id) == 10 {
            input.remove(at: input.index(before: input.endIndex))
            if input.count == 0 {
                input = "f"
            }
        }
        else if Int(id) == 12 {
            if input == "f" {
                input = "."
            }
            else {
                if input.count < 5 {
                    input.append(".")
                }
            }
        }
        else if Int(id) == 11 {
            let isCorrect = checkAnswer()

            if isCorrect {
                HapticManager.shared.trigger(.medium)
                numCorrect += 1
            }
            else {
                HapticManager.shared.trigger(.heavy, count: 2, interval: 0.05)
                missedQuestions.append(MissedQuestion(question: "\(String(format: "%.2f", num1)) \(mode == .TIME ? tmpMode : mode.rawValue) \(String(format: "%.2f", num2))", userAns: "\(input)", correctAns: "\(String(format: "%.2f", answer))"))
                numIncorrect += 1
            }

            questionCount += 1

            if mode != .TIME && questionCount > numQuestions {
                isGameOver = true
                return
            }

            if mode == .TIME {
                newQuestion(mode: randomMode())
            }
            else {
                newQuestion(mode: mode.rawValue)
            }
        }
        else {
            if input == "f" {
                input = id
            }
            else {
                if input.count < (difficulty == .DECIMALS ? 5 : 4) {
                    input.append(id)
                }
            }

            if checkAnswer() {
                HapticManager.shared.trigger(.medium)
                numCorrect += 1
                questionCount += 1
                if mode != .TIME && questionCount > numQuestions {
                    isGameOver = true
                    return
                }

                if mode == .TIME {
                    newQuestion(mode: randomMode())
                }
                else {
                    newQuestion(mode: mode.rawValue)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack {
                    InGameStats(timeLimit: timeLimit.rawValue, showAreYouSure: $showAreYouSure, isTimerPaused: $isTimerPaused, timeLeft: $timeLeft, numCorrect: $numCorrect, numIncorrect: $numIncorrect)
                        .padding(.horizontal, device.valueByDevice(small: 15, normal: 20, ipad: 30))
                        .onReceive(timer) { time in
                            if !isTimerPaused {
                                if timeLeft > 0 {
                                    timeLeft -= 1
                                }
                                else {
                                    isGameOver = true
                                    timer.upstream.connect().cancel()
                                }
                            }
                        }
                    
                    Spacer()
                    
                    // numbers display
                    
                    VStack(spacing: 10) {
                        if difficulty != .DECIMALS {
                            Text(num1 > num2 ? String(Int(num1)) : String(Int(num2)))
                                .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                                .foregroundColor(Color("darkPurple"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .tracking(device.valueByDevice(small: 5, normal: 8, ipad: 15))
                        }
                        else {
                            Text(num1 > num2 ? String(format: "%.2f", num1) : String(format: "%.2f", num2))
                                .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                                .foregroundColor(Color("darkPurple"))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .tracking(device.valueByDevice(small: 5, normal: 8, ipad: 15))
                        }
                        
                        HStack {
                            Text("\(mode == .TIME ? tmpMode : mode.rawValue)")
                                .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                                .bold()
                                .foregroundColor(Color("darkPurple"))
                            
                            Spacer()
                            
                            if difficulty != .DECIMALS {
                                Text(num1 < num2 ? String(Int(num1)) : String(Int(num2)))
                                    .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color("darkPurple"))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .tracking(device.valueByDevice(small: 5, normal: 8, ipad: 15))
                            }
                            else {
                                Text(num1 < num2 ? String(format: "%.2f", num1) : String(format: "%.2f", num2))
                                    .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color("darkPurple"))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .tracking(device.valueByDevice(small: 5, normal: 8, ipad: 15))
                            }
                        }
                        
                        Rectangle()
                            .fill(Color("darkPurple"))
                            .frame(maxWidth: .infinity, maxHeight: device.valueByDevice(small: 5, normal: 5, ipad: 7))
                            .cornerRadius(5)
                        
                        
                        Text(input)
                            .font(.system(size: device.screen!.size.width * numSize, weight: .bold, design: .rounded))
                            .bold()
                            .foregroundColor(Color("darkPurple"))
                            .opacity(input == "f" ? 0 : 1)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .tracking(device.valueByDevice(small: 5, normal: 8, ipad: 15))
                        
                        
                        
                    } // VStack
                    .frame(maxWidth: device.screen!.size.width * (difficulty == .DECIMALS ? 0.6 : 0.55))
                    
                    Spacer()
                    
                } // VStack
                .padding(.top, 20)
                .frame(maxHeight: device.screen!.size.height * topSize)
                
                // keypad

                VStack(spacing: device.valueByDevice(small: 13, normal: 13, ipad: 20)) {
                    HStack {
                        ForEach(1...3, id: \.self) { index in
                            KeyPadButton(id: String(keyNums[index-1]), onClick: handleKeypadClick)
                        }
                    }
                    HStack {
                        ForEach(4...6, id: \.self) { index in
                            KeyPadButton(id: String(keyNums[index-1]), onClick: handleKeypadClick)
                        }
                    }
                    HStack {
                        ForEach(7...9, id: \.self) { index in
                            KeyPadButton(id: String(keyNums[index-1]), onClick: handleKeypadClick)
                        }
                    }
                    HStack {
                        KeyPadButton(id: "10", foregroundColor: .white, backgroundColor: Color("errorRed"), shadowColor: Color("darkErrorRed"), imageName: "delete.left", isDisabled: input == "f", onClick: handleKeypadClick)
                        
                        KeyPadButton(id: "0", onClick: handleKeypadClick)
                        
                        KeyPadButton(id: "11", foregroundColor: .white, backgroundColor: Color("correctGreen"), shadowColor: Color("darkGreen"), imageName: "checkmark", isDisabled: Double(input) == nil, onClick: handleKeypadClick)
                    }

                    if difficulty == .DECIMALS {
                        KeyPadButton(id: "12", onClick: handleKeypadClick)
                    }
                }
                .frame(height: device.screen!.size.height * (1 - topSize))
                .padding(.horizontal, device.valueByDevice(small: 10, normal: 10, ipad: 20))
                
                Spacer()
                
            } // VStack
            .frame(maxHeight: .infinity)
            
        } // ZStack
        .frame(maxHeight: .infinity)
        .onAppear() {
            isGameOver = false
            topSize = difficulty == .DECIMALS ? 0.6 : 0.65

            if timeLimit == .NO_LIMIT { // No time limit
                timer.upstream.connect().cancel()
            }

            // Generate first question
            if mode == .TIME {
                newQuestion(mode: randomMode())
            }
            else {
                newQuestion(mode: mode.rawValue)
            }
        }
        .onChange(of: isGameOver) { _, new in
            if new {
                timer.upstream.connect().cancel()
                let config = GameConfigsModel(mode: mode, difficulty: difficulty, timeLimit: timeLimit, numQuestions: numQuestions)
                let gameModel = GameModel(numCorrect: numCorrect, numIncorrect: numIncorrect, missedQuestions: missedQuestions, questionCount: questionCount, gameConfigs: config)
                appModel.path.append(EndGameModel(game: gameModel))
            }
        }
        .alert("Are You Sure?", isPresented: $showAreYouSure, actions: {
            Button(role: .none, action: {
                timer.upstream.connect().cancel()
                appModel.path.removeLast()
                appModel.path.removeLast()
            }, label: {
                Text("Yes")
            })
            
            Button(role: .cancel, action: {
                isTimerPaused.toggle()
            }, label: {
                Text("Cancel")
            })
        }, message: {
            Text("You'll lose your current progress!")
        })
        
    } // body
}

#Preview {
    
    let gameModel = GameModel(gameConfigs: GameConfigsModel(mode: .ADDITION, difficulty: .DECIMALS, timeLimit: .ONE_MIN, numQuestions: 10))
    
    return (
        GeometryReader { screen in
            GameView(gameModel: gameModel)
                .environmentObject(AppModel(path: NavigationPath()))
                .environmentObject(DeviceModel(screen: screen))
        }
    )
}



