//
//  KeyPadButton.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/3/25.
//

import SwiftUI

struct KeyPadButton: View {
    
    @State var id: String
    @Binding var input: String
    @Binding var num1: Double
    @Binding var num2: Double
    @Binding var answer: Double
    
    @EnvironmentObject var gameModel: GameModel
    
    @Binding var isGameOver: Bool
    
    @State var isIpad: Bool
    
    let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    let rigidHaptic = UIImpactFeedbackGenerator(style: .rigid)
    let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
        
    func checkAnswer() -> Bool {
        return answer.isEqual(to: Double(input)!)
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
    
    func handleButtonClick() {
        if Int(id) == 10 {
            input.remove(at: input.index(before: input.endIndex))
            if input.count == 0 {
                input = "f"
            }
            
        }
        else if Int(id) == 12 {
            let isCorrect = checkAnswer()
            
            if isCorrect {
                mediumHaptic.impactOccurred()
                gameModel.score += 1
            }
            else {
                heavyHaptic.impactOccurred()
                rigidHaptic.impactOccurred()
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
                    mediumHaptic.impactOccurred()
                    gameModel.score += 1
                }
                else {
                    heavyHaptic.impactOccurred()
                    rigidHaptic.impactOccurred()
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
                mediumHaptic.impactOccurred()
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
    }
    
    var body: some View {
        GeometryReader { screen in
            Button(action: {}, label: {
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
            })
            .raisedButton(impactStrength: .soft, backgroundColor: Color("offWhite"), shadowColor: Color.gray.opacity(0.2), shadowOffset: 2, action: {
                handleButtonClick()
            })
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
