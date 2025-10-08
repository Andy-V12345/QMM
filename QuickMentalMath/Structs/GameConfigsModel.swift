//
//  GameConfigsModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/7/25.
//

import SwiftUI

enum GameMode: String {
    case ADDITION = "+", SUBTRACTION = "-", MULTIPLICATION = "x", DIVISION = "÷", TIME = "time"
}

enum GameDifficulty: String {
    case EASY = "easy", MEDIUM = "medium", HARD = "hard", DECIMALS = "decimals"
}

enum TimeLimit: CGFloat {
    case ONE_MIN = 60, TWO_MIN = 120, THREE_MIN = 180, NO_LIMIT = 1000
}

struct GameConfigsModel: Hashable {
    let id = UUID()
    var mode: GameMode = .ADDITION
    var difficulty: GameDifficulty = .EASY
    var timeLimit: TimeLimit = .ONE_MIN
    var numQuestions: Int = 10
    
    init(mode: GameMode, difficulty: GameDifficulty, timeLimit: TimeLimit, numQuestions: Int) {
        self.mode = mode
        self.difficulty = difficulty
        self.timeLimit = timeLimit
        self.numQuestions = numQuestions
    }
}
