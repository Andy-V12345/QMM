//
//  GameModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

class GameModel: ObservableObject {
    @Published var mode = ""
    @Published var difficulty = ""
    @Published var startTime: CGFloat = 0
    @Published var timeLeft: CGFloat = 0
    @Published var totQuestions = 0
    @Published var score = 0
    @Published var missedQuestions: [MissedQuestion] = []
    @Published var questionCount = 1
    @Published var tmpMode = ""
    
    init() {}
    
    init(mode: String, difficulty: String, totQuestions: Int, score: Int, missedQuestions: [MissedQuestion] = []) {
        self.mode = mode
        self.difficulty = difficulty
        self.score = score
        self.totQuestions = totQuestions
        self.missedQuestions = missedQuestions
    }
    
    var modes: [String] = ["+", "-", "x", "÷", "time"]
    var difficulties: [String] = ["easy", "medium", "hard", "decimals"]
    var times: [CGFloat] = [60, 120, 180, 1000]
    
    func setMode(modeIndex: Int) {
        mode = modes[modeIndex]
    }
    
    func setDifficulty(difficultyIndex: Int) {
        difficulty = difficulties[difficultyIndex]
    }
    
    func setTime(timeIndex: Int) {
        startTime = times[timeIndex]
        timeLeft = times[timeIndex]
    }
    
    func reset() {
        score = 0
        missedQuestions.removeAll()
        questionCount = 1
        mode = ""
        startTime = 0
        timeLeft = 0
        totQuestions = 0
        difficulty = ""
    }
    
    func playAgain() {
        score = 0
        missedQuestions.removeAll()
        timeLeft = startTime
        questionCount = 1
    }
    
}
