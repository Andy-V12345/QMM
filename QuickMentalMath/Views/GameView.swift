//
//  GameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/15/23.
//

import SwiftUI

struct GameView: View {
        
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var topSize = 0.65
    @State var shakeTrigger: Int = 0
    
    @State var input: String = "f"
    
    @State var num1: Double = 0
    @State var num2: Double = 0
    
    @State var answer: Double = 0
            
    @State var isGameOver = false
    @State var showAreYouSure = false
    @State var isTimerPaused = false
    
    let numSize: CGFloat = 0.11
    
    var keyColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0, alignment: .center), count: 3)
    
    var keyNums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 11, 12]
        
    @EnvironmentObject var appModel: AppModel
    @EnvironmentObject var gameModel: GameModel
    
    var body: some View {
        GeometryReader { screen in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        Color(.white)
                            .roundedCorner(25, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                            .frame(maxHeight: .infinity)
                        
                        VStack {
                            InGameStats(startTime: gameModel.startTime, shakeTrigger: $shakeTrigger, showAreYouSure: $showAreYouSure, isTimerPaused: $isTimerPaused, isGameOver: $isGameOver, timeLeft: $gameModel.timeLeft, numCorrect: $gameModel.score)
                                .padding(.horizontal, 20)
                            
                            Spacer()
                            
                            // numbers display
                            
                            VStack(spacing: 10) {
                                if gameModel.difficulty != "decimals" {
                                    Text(num1 > num2 ? String(Int(num1)) : String(Int(num2)))
                                        .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                        .foregroundColor(Color("darkPurple"))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                }
                                else {
                                    Text(num1 > num2 ? String(format: "%.2f", num1) : String(format: "%.2f", num2))
                                        .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                        .foregroundColor(Color("darkPurple"))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                }
                                
                                HStack {
                                    Text("\(gameModel.mode == "time" ? gameModel.tmpMode : gameModel.mode)")
                                        .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                        .bold()
                                        .foregroundColor(Color("darkPurple"))
                                    
                                    Spacer()
                                    
                                    if gameModel.difficulty != "decimals" {
                                        Text(num1 < num2 ? String(Int(num1)) : String(Int(num2)))
                                            .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                            .bold()
                                            .foregroundColor(Color("darkPurple"))
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                    }
                                    else {
                                        Text(num1 < num2 ? String(format: "%.2f", num1) : String(format: "%.2f", num2))
                                            .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                            .bold()
                                            .foregroundColor(Color("darkPurple"))
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                    }
                                }
                                
                                Rectangle()
                                    .fill(Color("darkPurple"))
                                    .frame(maxWidth: .infinity, maxHeight: 5)
                                    .cornerRadius(5)
                                
                                
                                Text(input)
                                    .font(.system(size: screen.size.width * numSize, weight: .bold, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color("darkPurple"))
                                    .opacity(input == "f" ? 0 : 1)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                
                                
                                
                            } // VStack
                            .frame(maxWidth: screen.size.width * (gameModel.difficulty == "decimals" ? 0.6 : 0.55))
                            
                            Spacer()
                            
                        } // VStack
                        .padding(.top, 20)
                        .frame(maxHeight: .infinity)
                        
                    } // ZStack
                    .frame(maxHeight: screen.size.height * topSize)
                    
                    // keypad
                    
                    VStack {
                        HStack {
                            ForEach(1...3, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500, shakeTrigger: $shakeTrigger)
                            }
                        }
                        HStack {
                            ForEach(4...6, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500, shakeTrigger: $shakeTrigger)
                            }
                        }
                        HStack {
                            ForEach(7...9, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500, shakeTrigger: $shakeTrigger)
                            }
                        }
                        HStack {
                            ForEach(10...12, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500, shakeTrigger: $shakeTrigger)
                            }
                        }
                        
                        if gameModel.difficulty == "decimals" {
                            KeyPadButton(id: String(keyNums[12]), input: $input, num1: $num1, num2: $num2, answer: $answer, isGameOver: $isGameOver, isIpad: screen.size.width > 500, shakeTrigger: $shakeTrigger)
                        }
                    }
                    .frame(height: screen.size.height * (1 - topSize))
                    
                    Spacer()
                    
                } // VStack
                .frame(maxHeight: .infinity)
                
            } // ZStack
            .frame(maxHeight: .infinity)
            .onAppear() {
                isGameOver = false
                topSize = gameModel.difficulty == "decimals" ? 0.6 : 0.65
                
                if gameModel.startTime > 180 { // No time limit
                    timer.upstream.connect().cancel()
                }
            }
            .onChange(of: isGameOver, perform: { new in
                if new {
                    timer.upstream.connect().cancel()
                    gameModel.timeLeft = gameModel.startTime
                    appModel.path.append(AppState.END)
                }
            })
            .alert("Are You Sure?", isPresented: $showAreYouSure, actions: {
                Button(role: .none, action: {
                    timer.upstream.connect().cancel()
                    gameModel.reset()
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
        } // GeometryReader
        .onReceive(timer) { time in
            if !isTimerPaused {
                if gameModel.timeLeft > 0 {
                    gameModel.timeLeft -= 1
                }
                else {
                    isGameOver = true
                    timer.upstream.connect().cancel()
                }
            }
        }
    } // body
    
    func convertTime(seconds: CGFloat) -> String {
        let min = Int(floor(seconds / 60))
        let sec = Int(seconds) % 60
        
        
        if sec < 10 {
            return "\(min):0\(sec)"
        }
        else {
            return "\(min):\(sec)"
        }
    }
    
    
} // struct

struct KeyPadButton: View {
    
    @State var id: String
    @Binding var input: String
    @Binding var num1: Double
    @Binding var num2: Double
    @Binding var answer: Double
    
    @EnvironmentObject var gameModel: GameModel
    
    @Binding var isGameOver: Bool
    
    @State var isIpad: Bool
    @Binding var shakeTrigger: Int
    
    let softImpact = UIImpactFeedbackGenerator(style: .soft)
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    
    func checkAnswer() -> Bool {
        return answer.isEqual(to: Double(input)!)
    }
    
    func shake() {
        withAnimation(.default) {
            shakeTrigger += 1
        }
    }
    
    func newQuestion(mode: String) {
        
        input = "f"
        
        if mode == "+" {
            if gameModel.difficulty == "easy" {
                num1 = Double(Int.random(in: 0...10))
                num2 = Double(Int.random(in: 0...10))
            }
            else if gameModel.difficulty == "medium" {
                num1 = Double(Int.random(in: 5...50))
                num2 = Double(Int.random(in: 5...50))
            }
            else if gameModel.difficulty == "hard" {
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
            if gameModel.difficulty == "easy" {
                num1 = Double(Int.random(in: 5...10))
                num2 = Double(Int.random(in: 0...10))
                while num2 > num1 {
                    num2 = Double(Int.random(in: 0...10))
                }
            }
            else if gameModel.difficulty == "medium" {
                num1 = Double(Int.random(in: 10...30))
                num2 = Double(Int.random(in: 5...30))
                while num2 > num1 {
                    num2 = Double(Int.random(in: 5...30))
                }
            }
            else if gameModel.difficulty == "hard" {
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
            if gameModel.difficulty == "easy" {
                num1 = Double(Int.random(in: 1...5))
                num2 = Double(Int.random(in: 0...5))
            }
            else if gameModel.difficulty == "medium" {
                num1 = Double(Int.random(in: 1...12))
                num2 = Double(Int.random(in: 0...12))
            }
            else if gameModel.difficulty == "hard" {
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
            if gameModel.difficulty == "easy" {
                num1 = Double(Int.random(in: 10...20))
                num2 = Double(Int.random(in: 1...10))
                
                while Int(num1) % Int(num2) != 0 {
                    num1 = Double(Int.random(in: 10...20))
                    num2 = Double(Int.random(in: 1...10))
                }
            }
            else if gameModel.difficulty == "medium" {
                
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
    
    func randomMode() -> String{
        let modes = ["+", "-", "x", "÷"]
        gameModel.tmpMode = modes.randomElement()!
        return gameModel.tmpMode
    }
    
    var body: some View {
        GeometryReader { screen in
            Button {
                if Int(id) == 10 {
                    input.remove(at: input.index(before: input.endIndex))
                    if input.count == 0 {
                        input = "f"
                    }
                    
                }
                else if Int(id) == 12 {
                    let isCorrect = checkAnswer()
                    
                    if isCorrect {
                        gameModel.score += 1
                    }
                    else {
                        hapticFeedback.impactOccurred()
                        gameModel.missedQuestions.append(MissedQuestion(question: "\(String(format: "%.2f", num1)) \(gameModel.mode == "time" ? gameModel.tmpMode : gameModel.mode) \(String(format: "%.2f", num2))", userAns: "\(input)", correctAns: "\(String(format: "%.2f", answer))"))

                    }
                    
                    gameModel.questionCount += 1
                    
                    if gameModel.mode != "time" && gameModel.questionCount > gameModel.totQuestions {
                        isGameOver = true
                    }
                    
                    if gameModel.mode == "time" {
                        newQuestion(mode: randomMode())
                    }
                    else {
                        newQuestion(mode: gameModel.mode)
                    }
                }
                else if Int(id) == 11 {
                    if gameModel.difficulty != "decimals" {
                        let isCorrect = checkAnswer()
                        
                        if isCorrect {
                            gameModel.score += 1
                        }
                        else {
                            hapticFeedback.impactOccurred()
                            shake()
                            gameModel.missedQuestions.append(MissedQuestion(question: "\(String(format: "%.0f", num1)) \(gameModel.mode == "time" ? gameModel.tmpMode : gameModel.mode) \(String(format: "%.0f", num2))", userAns: "\(input)", correctAns: "\(String(format: "%.0f", answer))"))
                        }
                        
                        gameModel.questionCount += 1
                        
                        if gameModel.mode != "time" && gameModel.questionCount > gameModel.totQuestions {
                            isGameOver = true
                        }
                        
                        if gameModel.mode == "time" {
                            newQuestion(mode: randomMode())
                        }
                        else {
                            newQuestion(mode: gameModel.mode)
                        }
                    }
                    else {
                        if input == "f" {
                            input = "."
                        }
                        else {
                            if input.count < 5 {
                                input.append(".")
                            }
                        }
                    }
                }
                else {
                    if input == "f" {
                        input = id
                    }
                    else {
                        if input.count < (gameModel.difficulty == "decimals" ? 5 : 4) {
                            input.append(id)
                        }
                    }
                    
                    if checkAnswer() {
                        gameModel.score += 1
                        gameModel.questionCount += 1
                        if gameModel.mode != "time" && gameModel.questionCount > gameModel.totQuestions {
                            isGameOver = true
                        }
                        
                        if gameModel.mode == "time" {
                            newQuestion(mode: randomMode())
                        }
                        else {
                            newQuestion(mode: gameModel.mode)
                        }
                    }
                }
                
                softImpact.impactOccurred()
            } label: {
                
                if Int(id) == 10 {
                    Image(systemName: "delete.left")
                        .font(isIpad ? .title : .title3)
                        .bold()
                        .foregroundColor(Color.red)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if Int(id) == 12 {
                    Image(systemName: "checkmark")
                        .font(isIpad ? .title : .title3)
                        .bold()
                        .foregroundColor(Color.green)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if Int(id) == 11 {
                    if gameModel.difficulty != "decimals" {
                        Image(systemName: "checkmark")
                            .font(isIpad ? .title : .title3)
                            .bold()
                            .foregroundColor(Color.green)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else {
                        Text(".")
                            .font(isIpad ? .title : .title3)
                            .bold()
                            .foregroundColor(Color("darkPurple"))
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                }
                else {
                    Text(id)
                        .font(isIpad ? .title : .title3)
                        .bold()
                        .foregroundColor(Color("darkPurple"))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .disabled((input == "f" || input == ".") && (Int(id) == 10 || (Int(id) == 11 && gameModel.difficulty != "decimals") || Int(id) == 12) ? true : false)
            .opacity((input == "f" || input == ".") && (Int(id) == 10 || (Int(id) == 11 && gameModel.difficulty != "decimals") || Int(id) == 12) ? 0.4 : 1)
            .onAppear {
                if gameModel.mode == "time" {
                    newQuestion(mode: randomMode())
                }
                else {
                    newQuestion(mode: gameModel.mode)
                }
            }
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameModel())
        .environmentObject(AppModel(path: NavigationPath()))
}



