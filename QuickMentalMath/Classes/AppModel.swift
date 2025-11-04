//
//  AppModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

class AppModel: ObservableObject {
    @Published var path: NavigationPath
    @Published var findingGame: Bool
    @Published var showStats: Bool
    @Published var showLeaderboard: Bool

    init(path: NavigationPath) {
        self.path = path
        self.findingGame = false
        self.showStats = false
        self.showLeaderboard = false
    }

    /// Dismiss all fullscreen sheets
    func dismissAllSheets() {
        showStats = false
        showLeaderboard = false
        findingGame = false
    }
}
