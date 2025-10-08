//
//  GameModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

struct GameModel: Hashable {
    let id = UUID()
    var numCorrect = 0
    var numIncorrect = 0
    var missedQuestions: [MissedQuestion] = []
    var questionCount = 1
    
    let gameConfigs: GameConfigsModel
    
    init(gameConfigs: GameConfigsModel) {
        self.gameConfigs = gameConfigs
    }
    
    init(numCorrect: Int, numIncorrect: Int, missedQuestions: [MissedQuestion], questionCount: Int, gameConfigs: GameConfigsModel) {
        self.numCorrect = numCorrect
        self.numIncorrect = numIncorrect
        self.missedQuestions = missedQuestions
        self.gameConfigs = gameConfigs
        self.questionCount = questionCount
    }
    
    init(gameConfigs: GameConfigsModel, missedQuestions: [MissedQuestion]) {
        self.gameConfigs = gameConfigs
        self.missedQuestions = missedQuestions
    }
    
//    func reset() {
//        score = 0
//        numIncorrect = 0
//        missedQuestions.removeAll()
//        questionCount = 1
//        mode = ""
//        startTime = 0
//        timeLeft = 0
//        totQuestions = 0
//        difficulty = ""
//    }
//    
//    func playAgain() {
//        score = 0
//        numIncorrect = 0
//        missedQuestions.removeAll()
//        timeLeft = startTime
//        questionCount = 1
//    }
}
