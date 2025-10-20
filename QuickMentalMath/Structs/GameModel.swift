//
//  GameModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

struct GameModel: Hashable, Codable {
    var id = UUID()
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
}
