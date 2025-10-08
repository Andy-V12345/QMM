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
    @Binding var numCorrect: Int
    @Binding var numIncorrect: Int
    @Binding var isGameOver: Bool
    @Binding var tmpMode: String
    @Binding var missedQuestions: [MissedQuestion]
    @Binding var questionCount: Int
    
    let difficulty: GameDifficulty
    let mode: GameMode
    let numQuestions: Int
    
        
    let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    let rigidHaptic = UIImpactFeedbackGenerator(style: .rigid)
    let heavyHaptic = UIImpactFeedbackGenerator(style: .heavy)
    
    @EnvironmentObject var device: DeviceModel
        
    func checkAnswer() -> Bool {
        return answer.isEqual(to: Double(input)!)
    }
    
    func getBackgroundColor(id: String) -> Color {
        if id == "10" {
            return Color("errorRed")
        }
        else if (Int(id) == 11 && difficulty != .DECIMALS) || Int(id) == 12 {
            return Color("correctGreen")
        }
        else {
            return Color("lighterPurple")
        }
    }
    
    func getShadowColor(id: String) -> Color {
        if id == "10" {
            return Color("darkErrorRed")
        }
        else if (Int(id) == 11 && difficulty != .DECIMALS) || Int(id) == 12 {
            return Color("darkGreen")
        }
        else {
            return Color("lightPurple")
        }
    }
    
    
    func isDeleteOrCheckButton(id: String) -> Bool {
        return id == "10" || ((Int(id) == 11 && difficulty != .DECIMALS) || Int(id) == 12)
    }
    
    func isDisabled(id: String, input: String, difficulty: GameDifficulty) -> Bool {
        if Int(id) == 10 { // delete button
            return input == "f"
        }
        else if (Int(id) == 11 && difficulty != .DECIMALS) || Int(id) == 12 { // check answer button
            let isNumeric = Double(input) != nil
            
            return !isNumeric
        }
        else {
            return false
        }
    }
    
    func newQuestion(mode: String) {
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
    
    func randomMode() -> String{
        let modes = ["+", "-", "x", "÷"]
        tmpMode = modes.randomElement()!
        return tmpMode
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
                numCorrect += 1
            }
            else {
                heavyHaptic.impactOccurred()
                rigidHaptic.impactOccurred()
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
        else if Int(id) == 11 {
            if difficulty != .DECIMALS {
                let isCorrect = checkAnswer()
                
                if isCorrect {
                    mediumHaptic.impactOccurred()
                    numCorrect += 1
                }
                else {
                    heavyHaptic.impactOccurred()
                    rigidHaptic.impactOccurred()
                    missedQuestions.append(MissedQuestion(question: "\(String(format: "%.0f", num1)) \(mode == .TIME ? tmpMode : mode.rawValue) \(String(format: "%.0f", num2))", userAns: "\(input)", correctAns: "\(String(format: "%.0f", answer))"))
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
                if input.count < (difficulty == .DECIMALS ? 5 : 4) {
                    input.append(id)
                }
            }
            
            if checkAnswer() {
                mediumHaptic.impactOccurred()
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
        GeometryReader { screen in
            Button(action: {}, label: {
                if Int(id) == 10 {
                    Image(systemName: "delete.left")
                        .foregroundColor(Color("offWhite"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if Int(id) == 12 {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color("offWhite"))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if Int(id) == 11 {
                    if difficulty != .DECIMALS {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color("offWhite"))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    else {
                        Text(".")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                }
                else {
                    Text(id)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            })
            .font(device.valueByDevice(small: .title2, normal: .title2, ipad: .largeTitle))
            .foregroundColor(Color("darkPurple"))
            .fontWeight(.heavy)
            .raisedButton(impactStrength: .soft, backgroundColor: getBackgroundColor(id: id), shadowColor: getShadowColor(id: id), shadowOffset: device.valueByDevice(small: 5, normal: 5, ipad: 8), action: {
                handleButtonClick()
            })
            .disabled(isDisabled(id: id, input: input, difficulty: difficulty))
            .opacity(isDisabled(id: id, input: input, difficulty: difficulty) ? 0.4 : 1)
            .onAppear {
                if mode == .TIME {
                    newQuestion(mode: randomMode())
                }
                else {
                    newQuestion(mode: mode.rawValue)
                }
            }
        }
    }
}
