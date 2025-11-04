//
//  RegularGameSession.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/30/25.
//

import Foundation

class RegularGameSession: GameSession {
    
    override func handleLeaveGame(authInfo: AuthInfoModel, appModel: AppModel) {
        guard let user = authInfo.user else { return }

        // Show loading overlay
        showLeaveGameOverlay = true

        Task {
            let result = await MultiplayerService.forfeit(
                gameId: self.id,
                userId: user.id,
                jwtToken: user.jwtToken
            )
            
            // Update user stats to account for loss
            if var curStats = try? await AuthService.loadUserStats(userId: user.id, jwtToken: user.jwtToken) {
                
                curStats.losses = curStats.losses == nil ? 1 : curStats.losses! + 1
                let _ = await AuthService.updateUserStats(userId: user.id, statId: curStats.id, jwtToken: user.jwtToken, statsRequest: UserStatsRequest(userStats: curStats))
            }
            
            await MainActor.run {
                switch result {
                case .success:
                    // Navigate back
                    showLeaveGameOverlay = false
                    appModel.path.removeLast()

                case .failure(let error):
                    // Hide overlay and show error alert
                    showLeaveGameOverlay = false
                    leaveGameErrorMessage = error.localizedDescription
                    showLeaveGameError = true
                }
            }
        }
    }
}
