//
//  GameView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 5/15/23.
//

import SwiftUI
import AVKit

struct GameView: View {
    
    @State var timeLeft: CGFloat = 60
    
    @State var startTime: CGFloat = 60
    
    @Binding var timeIndex: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var totalQuestions: Int
    @State var mode: String
    @State var difficulty: String
    
    @State var times: [CGFloat] = [60, 120, 180, 1000]
    
    @State var topSize = 0.65
    
    @State var input: String = "f"
    
    @State var num1: Int = 0
    @State var num2: Int = 0
    
    @State var answer: Int = 0
    
    @State var questionCount: Int = 1
    
    @State var correctCount: Int = 0
    
    @State var isGameOver = false
    @State var isGoHome = false
    
    var keyColumns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0, alignment: .center), count: 3)
    
    var keyNums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0, 11]
    
    @State var missedQuestions: [MissedQuestion] = []
    
    @State var isMuted = false
    
    
    
    var body: some View {
        GeometryReader { screen in
            
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ZStack {
                        Color("textColor")
                            .roundedCorner(25, corners: [.bottomLeft, .bottomRight])
                            .ignoresSafeArea()
                            .frame(maxHeight: .infinity)
                            .overlay(alignment: .topLeading, content: {
                                
                                Image(systemName: "figure.walk.departure")
                                    .font(screen.size.width > 500 ? .title : .title3)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, screen.size.width > 500 ? 20 : 10)
                                    .onTapGesture {
                                        isGoHome = true
                                    }
                                    .fullScreenCover(isPresented: $isGoHome, content: {
                                        ContentView()
                                    })
                                
                            })
                            .overlay(alignment: .topTrailing, content: {
                                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    .font(screen.size.width > 500 ? .title : .title3)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, screen.size.width > 500 ? 20 : 10)
                                    .onTapGesture {
                                        isMuted.toggle()
                                    }
                        
                            })
                        
                        VStack {
                            HStack {
                                
                                Spacer()
                                
                                VStack(spacing: 5) {
                                    Text("\(questionCount > totalQuestions ? totalQuestions : questionCount) / \(totalQuestions)")
                                        .font(.system(size: screen.size.width * 0.055, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Question")
                                        .font(screen.size.width > 500 ? .title : .headline)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                // timer
                                
                                ZStack {
                                    Circle()
                                        .stroke(Color.white.opacity(0.8),
                                                style: StrokeStyle(lineWidth: screen.size.width > 500 ? screen.size.width * 0.015 : screen.size.width * 0.021))
                                        .overlay() {
                                            Text(startTime <= 180 ? convertTime(seconds: timeLeft) : "∞")
                                                .font(.system(size: screen.size.width > 500 ? screen.size.width * 0.06 : screen.size.width * 0.07, weight: .bold))
                                                .foregroundColor(Color.white)
                                        }
                                    if self.startTime <= 180 {
                                        Circle()
                                            .trim(from: 0, to: ((startTime - timeLeft) / startTime))
                                            .stroke(Color("goColor"),
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
                                
                                VStack(spacing: 5) {
                                    Text("\(correctCount)")
                                        .font(.system(size: screen.size.width * 0.055, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("Correct")
                                        .font(screen.size.width > 500 ? .title : .headline)
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                            } // HStack
                            .offset(y: 20)
                            .frame(maxHeight: screen.size.height * (topSize / 3.5))
                            
                            Spacer()
                            
                            VStack(spacing: 10) {
                                
                                Text(num1 > num2 ? String(num1) : String(num2))
                                    .font(.system(size: screen.size.width * 0.1, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .tracking(10)
                                HStack {
                                    Text("\(mode)")
                                        .font(.system(size: screen.size.width * 0.1, weight: .bold, design: .rounded))
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text(num1 < num2 ? String(num1) : String(num2))
                                        .font(.system(size: screen.size.width * 0.1, weight: .bold, design: .rounded))
                                        .bold()
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .tracking(10)
                                }
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(maxWidth: .infinity, maxHeight: 5)
                                    .cornerRadius(5)
                                
                                
                                Text(input)
                                    .font(.system(size: screen.size.width * 0.1, weight: .bold, design: .rounded))
                                    .bold()
                                    .foregroundColor(.white)
                                    .opacity(input == "f" ? 0 : 1)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .tracking(10)
                                
                                
                                
                            } // VStack
                            .frame(maxWidth: screen.size.width * 0.41)
                            
                            Spacer()
                            
                        } // VStack
                        .frame(maxHeight: .infinity)
                        
                    } // ZStack
                    .frame(maxHeight: screen.size.height * topSize)
                    
                    VStack {
                        HStack {
                            ForEach(1...3, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, questionCount: $questionCount, correctCount: $correctCount, isGameOver: $isGameOver, missedQuestions: $missedQuestions, isIpad: screen.size.width > 500, isMuted: $isMuted, mode: mode, difficulty: difficulty, totalQuestions: totalQuestions)
                            }
                        }
                        HStack {
                            ForEach(4...6, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, questionCount: $questionCount, correctCount: $correctCount, isGameOver: $isGameOver, missedQuestions: $missedQuestions, isIpad: screen.size.width > 500, isMuted: $isMuted, mode: mode, difficulty: difficulty, totalQuestions: totalQuestions)
                            }
                        }
                        HStack {
                            ForEach(7...9, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, questionCount: $questionCount, correctCount: $correctCount, isGameOver: $isGameOver, missedQuestions: $missedQuestions, isIpad: screen.size.width > 500, isMuted: $isMuted, mode: mode, difficulty: difficulty, totalQuestions: totalQuestions)
                            }
                        }
                        HStack {
                            ForEach(10...12, id: \.self) { index in
                                KeyPadButton(id: String(keyNums[index-1]), input: $input, num1: $num1, num2: $num2, answer: $answer, questionCount: $questionCount, correctCount: $correctCount, isGameOver: $isGameOver, missedQuestions: $missedQuestions, isIpad: screen.size.width > 500, isMuted: $isMuted, mode: mode, difficulty: difficulty, totalQuestions: totalQuestions)
                            }
                        }
                    }
                    .frame(height: screen.size.height * 0.35)
                    
                    Spacer()
                    
                } // VStack
                .frame(maxHeight: .infinity)
                
            } // ZStack
            .frame(maxHeight: .infinity)
            .fullScreenCover(isPresented: $isGameOver, content: {
                EndGameView(score: correctCount, totalQuestions: totalQuestions, timeIndex: timeIndex, mode: mode, difficulty: difficulty, missedQuestions: self.missedQuestions)
            })
            .onAppear() {
                startTime = times[timeIndex]
                timeLeft = times[timeIndex]
                
                
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
    @Binding var num1: Int
    @Binding var num2: Int
    @Binding var answer: Int
    @Binding var questionCount: Int
    @Binding var correctCount: Int
    @Binding var isGameOver: Bool
    @Binding var missedQuestions: [MissedQuestion]
    
    @State var audioPlayer: AVAudioPlayer!
    @State var audioPlayer2: AVAudioPlayer!
    
    @State var isIpad: Bool
    
    @Binding var isMuted: Bool
    
    var mode: String
    var difficulty: String
    var totalQuestions: Int
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    
    func checkAnswer() -> Bool {
        return Int(input) == answer
    }
    
    func newQuestion() {
        
        input = "f"
        
        if mode == "+" {
            if difficulty == "easy" {
                num1 = Int.random(in: 0...10)
                num2 = Int.random(in: 0...10)
            }
            else if difficulty == "medium" {
                num1 = Int.random(in: 5...20)
                num2 = Int.random(in: 5...20)
            }
            else {
                num1 = Int.random(in: 10...40)
                num2 = Int.random(in: 10...40)
            }
            answer = num1 + num2
        }
        else if mode == "-" {
            if difficulty == "easy" {
                num1 = Int.random(in: 5...10)
                num2 = Int.random(in: 0...10)
                while num2 > num1 {
                    num2 = Int.random(in: 0...10)
                }
            }
            else if difficulty == "medium" {
                num1 = Int.random(in: 10...30)
                num2 = Int.random(in: 0...30)
                while num2 > num1 {
                    num2 = Int.random(in: 0...30)
                }
            }
            else {
                num1 = Int.random(in: 10...60)
                num2 = Int.random(in: 0...60)
                while num2 > num1 {
                    num2 = Int.random(in: 0...60)
                }
            }
            answer = num1 - num2
        }
        else if mode == "x" {
            if difficulty == "easy" {
                num1 = Int.random(in: 0...5)
                num2 = Int.random(in: 0...5)
            }
            else if difficulty == "medium" {
                num1 = Int.random(in: 0...12)
                num2 = Int.random(in: 0...12)
            }
            else {
                num1 = Int.random(in: 0...20)
                num2 = Int.random(in: 0...20)
                
            }
            answer = num1 * num2
        }
        else {
            if difficulty == "easy" {
                num1 = Int.random(in: 10...20)
                num2 = Int.random(in: 1...10)
                
                while num1 % num2 != 0 {
                    num1 = Int.random(in: 10...20)
                    num2 = Int.random(in: 1...10)
                }
            }
            else if difficulty == "medium" {
                
                let choices = Array(1...12)
                
                
                let productNums = [choices.randomElement()!, choices.randomElement()!]
                
                num1 = productNums[0] * productNums[1]
                num2 = productNums.randomElement()!
                
            }
            else {
                
                let choices = Array(5...20)
                
                let productNums = [choices.randomElement()!, choices.randomElement()!]
                
                num1 = productNums[0] * productNums[1]
                num2 = productNums.randomElement()!
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
                else if Int(id) == 11 {
                    let isCorrect = checkAnswer()
                    
                    if isCorrect {
                        correctCount += 1
                        if !isMuted {
                            audioPlayer.play()
                        }
                    }
                    else {
                        if !isMuted {
                            audioPlayer2.play()
                        }
                        hapticFeedback.impactOccurred()
                        missedQuestions.append(MissedQuestion(question: "\(num1) \(mode) \(num2)", userAns: "\(input)", correctAns: "\(answer)"))
                    }
                    
                    questionCount += 1
                    
                    if questionCount > totalQuestions {
                        isGameOver = true
                    }
                    newQuestion()
                }
                else {
                    if input == "f" {
                        input = id
                    }
                    else {
                        if input.count < 3 {
                            input.append(id)
                        }
                    }
                    
                    if checkAnswer() {
                        correctCount += 1
                        if !isMuted {
                            audioPlayer.play()
                        }
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
                else if Int(id) == 11 {
                    Image(systemName: "checkmark")
                        .font(isIpad ? .title : .title3)
                        .bold()
                        .foregroundColor(Color.green)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    Text(id)
                        .font(isIpad ? .title : .title3)
                        .bold()
                        .foregroundColor(Color("textColor"))
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .disabled(input == "f" && (Int(id) == 10 || Int(id) == 11) ? true : false)
            .opacity(input == "f" && (Int(id) == 10 || Int(id) == 11) ? 0.4 : 1)
            .onAppear {
                
                newQuestion()
                
                let sound = Bundle.main.path(forResource: "brightButton", ofType: "mp3")
                let sound2 = Bundle.main.path(forResource: "wrongSound", ofType: "mp3")
                
                self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound!))
                self.audioPlayer2 = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound2!))
                
        }
        }
    }
}



