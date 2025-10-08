//
//  EndGameModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/7/25.
//

import SwiftUI

struct EndGameModel: Hashable {
    let id = UUID()
    let game: GameModel
    let gameConfigs: GameConfigsModel
    
    init(game: GameModel) {
        self.game = game
        self.gameConfigs = game.gameConfigs
    }
}


