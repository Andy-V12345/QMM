//
//  RegularMultiplayerEndGameModel.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/30/25.
//

import Foundation

class RegularMultiplayerEndGameModel: MultiplayerEndGameModel {
    override func loadInitialData(authInfo: AuthInfoModel) {
        Task {
            // Fetch game session first (needed for opponent listener)
            await fetchGameSession(authInfo: authInfo)

            // Fetch user progress first (needed for bot simulation)
            await fetchUserProgress(authInfo: authInfo)

            // Fetch opponent progress (needed for bot simulation delay calculation)
            await fetchOpponentProgress(authInfo: authInfo)

            // Fetch user stats
            await fetchUserStats(authInfo: authInfo)

            // Calculate and update stats after all data loaded
            await calculateAndUpdateStats(authInfo: authInfo)

            // All initial data loaded
            await MainActor.run {
                isLoading = false
            }

            await startOpponentProgressListener(authInfo: authInfo)
        }
    }
    
    override func handlePlayAgain(appModel: AppModel, authInfo: AuthInfoModel) {
        appModel.findingGame = true
        appModel.path.removeLast()
        appModel.path.removeLast()
    }
}
