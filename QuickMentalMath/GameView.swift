//
//  GameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/15/23.
//

import SwiftUI

struct GameView: View {
    
    @State var timeLeft: CGFloat = 60
    
    @State var startTime: CGFloat = 60
    
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    @State var topSize = 0.65
    
    @State var input: String = "f"
    
    @State var num1: Double = 0
    @State var num2: Double = 0
    
    @State var answer: Double = 0
    
    @State var questionCount: Int = 1
    
    @State var correctCount: Int = 0
    
    @State var isGameOver = false
    @State var isGoHome = false
    
    var keyColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0, alignment: .center), count: 3)
    
    var keyNums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 11, 12]
    
    @State var missedQuestions: [MissedQuestion] = []
    
    @State var isMuted = UserDefaults.standard.bool(forKey: "isMuted")
    
    @EnvironmentObject private var game: GameModel
    
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
                            .overlay(alignment: .topLeading, content: {
                                
                                Image(systemName: "figure.walk.departure")
                                    .font(screen.size.width > 500 ? .title : .title3)
                                    .bold()
                                    .foregroundColor(Color("darkPurple"))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, screen.size.width > 500 ? 20 : 10)
                                    .onTapGesture {
                                        isGoHome = true
                                    }
                                    .fullScreenCover(isPresented: $isGoHome, content: {
                                        ContentView()
                                    })
                                
                            })
                        
                        VStack {
                            VStack(spacing: screen.size.height < 736 && screen.size.width < 390 ? 20 : 25) {
                                HStack {
                                    Spacer()
                                    
                                    // timer
                                    
                                    ZStack {
                                        Circle()
                                            .stroke(Color.gray.opacity(0.2),
                                                    style: StrokeStyle(lineWidth: screen.size.width > 500 ? screen.size.width * 0.015 : screen.size.width * 0.021))
                                            .overlay() {
                                                Text(startTime <= 180 ? convertTime(seconds: timeLeft) : "∞")
                                                    .font(.system(size: (screen.size.width > 500 || screen.size.height < 736) ? screen.size.width * 0.057 : screen.size.width * 0.065, weight: .bold))
                                                    .foregroundColor(Color("darkPurple"))
                                            }
                                        if self.startTime <= 180 {
                                            Circle()
                                                .trim(from: 0, to: ((startTime - timeLeft) / startTime))
                                                .stroke(Color("lightGreen"),
                                                        style: StrokeStyle(lineWidth: screen.size.width > 500 ? screen.size.width * 0.015 : screen.size.width * 0.021, lineCap: .round)
                                                )
                                                .rotationEffect(Angle(degrees: -90))
                                                .animation(.easeIn, value: timeLeft)
                                        }
                                    }
                                    .onReceive(timer) { time in
                                        if timeLeft > 0 {
                                            timeLeft -= 1
                                        }
                                        else {
                                            timer.upstream.connect().cancel()
                                            isGameOver = true
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                } // HStack
                                .frame(maxHeight: screen.size.height * (topSize / 3.85))
                                
                                
                                
                                HStack(spacing: 10) {
                                    
                                    VStack(spacing: 5) {
                                        Text("\(questionCount > game.totQuestions ? game.totQuestions : questionCount) / \(game.totQuestions)")
                                            .font(.system(size: screen.size.width * 0.054, weight: .bold))
                                            .foregroundColor(Color("darkPurple"))
                                        Text("Question")
                                            .font(screen.size.width > 500 ? .title : .headline)
                                            .foregroundColor(Color("darkPurple"))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, screen.size.height < 736 && screen.size.width < 390 ? 15 : 20)
                                    .frame(maxWidth: .infinity)
                                    .background(.white)
                                    .roundedCorner(15, corners: .allCorners)
                                    .clipped()
                                    .shadow(radius: 5)
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 5) {
                                        Text("\(correctCount)")
                                            .font(.system(size: screen.size.width * 0.054, weight: .bold))
                                            .foregroundColor(Color("darkPurple"))
                                        Text("Correct")
                                            .font(screen.size.width > 500 ? .title : .headline)
                                            .foregroundColor(Color("darkPurple"))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, screen.size.height < 736 && screen.size.width < 390 ? 15 : 20)
                                    .frame(maxWidth: .infinity)
                                    .background(.white)
                                    .roundedCorner(15, corners: .allCorners)
                                    .clipped()
                                    .shadow(radius: 5)
                                    
                                }
                                
                                
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer()
                            
                            // numbers display
                            
                            VStack(spacing: 10) {
                                
                                if game.difficulty != "decimals" {
                                    Text(num1 > num2 ? String(Int(num1)) : String(Int(num2)))
                                        .font(.system(size: screen.size.width * 0.08, weight: .bold, design: .rounded))
                                        .foregroundColor(Color("darkPurple"))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                }
                                else {
                                    Text(num1 > num2 ? String(format: "%.2f", num1) : String(format: "%.2f", num2))
                                        .font(.system(size: screen.size.width * 0.08, weight: .bold, design: .rounded))
                                        .foregroundColor(Color("darkPurple"))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                }
                                
                                HStack {
                                    Text("\(game.mode)")
                                        .font(.system(size: screen.size.width * 0.08, weight: .bold, design: .rounded))
                                        .bold()
                                        .foregroundColor(Color("darkPurple"))
                                    
                                    Spacer()
                                    
                                    if game.difficulty != "decimals" {
                                        Text(num1 < num2 ? String(Int(num1)) : String(Int(num2)))
                                            .font(.system(size: screen.size.width * 0.08, weight: .bold, design: .rounded))
                                            .bold()
                                            .foregroundColor(Color("darkPurple"))
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                            .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                    }
                                    else {
                                        Text(num1 < num2 ? String(format: "%.2f", num1) : String(format: "%.2f", num2))
                                            .font(.system(size: screen.size.width * 0.08, weight: .bold, design: .rounded))
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
                                    .font(.system(size: screen.size.width * 0.08, weight: .bold, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color("darkPurple"))
                                    .opacity(input == "f" ? 0 : 1)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .tracking(screen.size.height < 736 && screen.size.width < 390 ? 5 : 8)
                                
                                
                                
                            } // VStack
                            .frame(maxWidth: screen.size.width * (game.difficulty == "decimals" ? 0.5 : 0.45))
                            
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
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, questionCount: $questionCount, correctCount: $correctCount, isGameOver: $isGameOver, missedQuestions: $missedQuestions, isIpad: screen.size.width > 500, isMuted: $isMuted, mode: game.mode, difficulty: game.difficulty, totalQuestions: game.totQuestions)
                            }
                        }
                        HStack {
                            ForEach(4...6, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, questionCount: $questionCount, correctCount: $correctCount, isGameOver: $isGameOver, missedQuestions: $missedQuestions, isIpad: screen.size.width > 500, isMuted: $isMuted, mode: game.mode, difficulty: game.difficulty, totalQuestions: game.totQuestions)
                            }
                        }
                        HStack {
                            ForEach(7...9, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, questionCount: $questionCount, correctCount: $correctCount, isGameOver: $isGameOver, missedQuestions: $missedQuestions, isIpad: screen.size.width > 500, isMuted: $isMuted, mode: game.mode, difficulty: game.difficulty, totalQuestions: game.totQuestions)
                            }
                        }
                        HStack {
                            ForEach(10...12, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, questionCount: $questionCount, correctCount: $correctCount, isGameOver: $isGameOver, missedQuestions: $missedQuestions, isIpad: screen.size.width > 500, isMuted: $isMuted, mode: game.mode, difficulty: game.difficulty, totalQuestions: game.totQuestions)
                            }
                        }
                        
                        if game.difficulty == "decimals" {
                            KeyPadButton(id: String(keyNums[12]), input: $input, num1: $num1, num2: $num2, answer: $answer, questionCount: $questionCount, correctCount: $correctCount, isGameOver: $isGameOver, missedQuestions: $missedQuestions, isIpad: screen.size.width > 500, isMuted: $isMuted, mode: game.mode, difficulty: game.difficulty, totalQuestions: game.totQuestions)
                        }
                    }
                    .frame(height: screen.size.height * (1 - topSize))
                    
                    Spacer()
                    
                } // VStack
                .frame(maxHeight: .infinity)
                
            } // ZStack
            .frame(maxHeight: .infinity)
            .fullScreenCover(isPresented: $isGameOver, content: {
                EndGameView(score: correctCount, missedQuestions: missedQuestions)
            })
            .onAppear() {
                startTime = game.time
                timeLeft = game.time
                topSize = game.difficulty == "decimals" ? 0.6 : 0.65
            }
            .onChange(of: isGameOver, perform: { new in
                timer.upstream.connect().cancel()
            })
            .onChange(of: isGoHome, perform: { new in
                timer.upstream.connect().cancel()
            })
            
            Spacer()
            
        } // GeometryReader
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
    @Binding var questionCount: Int
    @Binding var correctCount: Int
    @Binding var isGameOver: Bool
    @Binding var missedQuestions: [MissedQuestion]
    
    @State var isIpad: Bool
    
    @Binding var isMuted: Bool
    
    var mode: String
    var difficulty: String
    var totalQuestions: Int
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    
    func checkAnswer() -> Bool {
        return answer.isEqual(to: Double(input)!)
    }
    
    func newQuestion() {
        
        input = "f"
        
        if mode == "+" {
            if difficulty == "easy" {
                num1 = Double(Int.random(in: 0...10))
                num2 = Double(Int.random(in: 0...10))
            }
            else if difficulty == "medium" {
                num1 = Double(Int.random(in: 5...20))
                num2 = Double(Int.random(in: 5...20))
            }
            else if difficulty == "hard" {
                num1 = Double(Int.random(in: 10...40))
                num2 = Double(Int.random(in: 10...40))
            }
            else {
                num1 = round(100.0 * Double.random(in: 0.01...10)) / 100.0
                num2 = round(100.0 * Double.random(in: 0.01...10)) / 100.0
            }
            answer = num1 + num2
        }
        else if mode == "-" {
            if difficulty == "easy" {
                num1 = Double(Int.random(in: 5...10))
                num2 = Double(Int.random(in: 0...10))
                while num2 > num1 {
                    num2 = Double(Int.random(in: 0...10))
                }
            }
            else if difficulty == "medium" {
                num1 = Double(Int.random(in: 10...30))
                num2 = Double(Int.random(in: 0...30))
                while num2 > num1 {
                    num2 = Double(Int.random(in: 0...30))
                }
            }
            else if difficulty == "hard" {
                num1 = Double(Int.random(in: 10...60))
                num2 = Double(Int.random(in: 5...60))
                while num2 > num1 {
                    num2 = Double(Int.random(in: 5...60))
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
            if difficulty == "easy" {
                num1 = Double(Int.random(in: 1...5))
                num2 = Double(Int.random(in: 0...5))
            }
            else if difficulty == "medium" {
                num1 = Double(Int.random(in: 1...12))
                num2 = Double(Int.random(in: 0...12))
            }
            else if difficulty == "hard" {
                num1 = Double(Int.random(in: 1...20))
                num2 = Double(Int.random(in: 1...20))
            }
            else {
                num1 = round(100.0 * Double.random(in: 0.01...20)) / 100.0
                num2 = Double(Int.random(in: 1...20))
            }
            answer = num1 * num2
        }
        else {
            if difficulty == "easy" {
                num1 = Double(Int.random(in: 10...20))
                num2 = Double(Int.random(in: 1...10))
                
                while Int(num1) % Int(num2) != 0 {
                    num1 = Double(Int.random(in: 10...20))
                    num2 = Double(Int.random(in: 1...10))
                }
            }
            else if difficulty == "medium" {
                
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
                        correctCount += 1
                        
                    }
                    else {
                        hapticFeedback.impactOccurred()
                        missedQuestions.append(MissedQuestion(question: "\(String(format: "%.2f", num1)) \(mode) \(String(format: "%.2f", num2))", userAns: "\(input)", correctAns: "\(String(format: "%.2f", answer))"))

                    }
                    
                    questionCount += 1
                    
                    if questionCount > totalQuestions {
                        isGameOver = true
                    }
                    newQuestion()
                }
                else if Int(id) == 11 {
                    if difficulty != "decimals" {
                        let isCorrect = checkAnswer()
                        
                        if isCorrect {
                            correctCount += 1
                            
                        }
                        else {
                            
                            hapticFeedback.impactOccurred()
                            missedQuestions.append(MissedQuestion(question: "\(String(format: "%.0f", num1)) \(mode) \(String(format: "%.0f", num2))", userAns: "\(input)", correctAns: "\(String(format: "%.0f", answer))"))
                        }
                        
                        questionCount += 1
                        
                        if questionCount > totalQuestions {
                            isGameOver = true
                        }
                        newQuestion()
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
                        if input.count < (difficulty == "decimals" ? 5 : 4) {
                            input.append(id)
                        }
                    }
                    
                    if checkAnswer() {
                        correctCount += 1
                        questionCount += 1
                        if questionCount > totalQuestions {
                            isGameOver = true
                        }
                        newQuestion()
                    }
                }
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
                    if difficulty != "decimals" {
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
            .disabled((input == "f" || input == ".") && (Int(id) == 10 || (Int(id) == 11 && difficulty != "decimals") || Int(id) == 12) ? true : false)
            .opacity((input == "f" || input == ".") && (Int(id) == 10 || (Int(id) == 11 && difficulty != "decimals") || Int(id) == 12) ? 0.4 : 1)
            .onAppear {
                
                newQuestion()
                
            }
        }
    }
}



