//
//  AuthInfo.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 10/1/25.
//

import SwiftUI

class AuthInfoModel: ObservableObject {
    @Published var user: User? = nil
    @Published var authState: AuthState = .UNAUTHORIZED
    
    init() {}
    
    init(user: User) {
        self.user = user
    }
    
    @MainActor
    func signUp(email: String, username: String, password: String) async -> String {
        
        var response = ""
        
        (user, response) = await AuthService.signUp(email: email, username: username, password: password)
        
        if response == "USER_CREATED" && user != nil {
            authState = .AUTHORIZED
        }
        
        return response
    }
    
    @MainActor
    func login(email: String, password: String) async -> String {
        var response = ""
        
        (user, response) = await AuthService.login(email: email, password: password)
        
        if response == "LOGGED_IN" && user != nil {
            authState = .AUTHORIZED
        }
        
        return response
    }
    
    @MainActor
    func loadUserStats() async {
        let stats = await AuthService.loadUserStats(userId: user!.id, jwtToken: user!.jwtToken)
        user?.stats = stats
    }
    
    @MainActor
    func createUserStats(statsRequest: UserStatsRequest) async -> Bool {
        return await AuthService.createUserStats(userId: user!.id, jwtToken: user!.jwtToken, statsRequest: statsRequest)
    }
    
    @MainActor
    func updateUserStats(statsRequest: UserStatsRequest) async -> Bool {
        return await AuthService.updateUserStats(userId: user!.id, statId: user!.stats!.id, jwtToken: user!.jwtToken, statsRequest: statsRequest)
    }
    
    @MainActor
    func getLeaderboard(topN: Int) async -> [LeaderboardResponse]? {
        return await AuthService.getLeaderboard(topN: topN, jwtToken: user!.jwtToken)
    }
    
    @MainActor
    func sendEmail(email: String) async -> Bool {
        return await AuthService.sendForgetPasswordEmail(body: ForgetPasswordRequest(email: email))
    }
    
    @MainActor
    func verifyToken(token: String) async -> Bool {
        return await AuthService.verifyForgetPasswordToken(token: token)
    }
    
    @MainActor
    func resetPassword(token: String, password: String) async -> String {
        let body = ResetPasswordRequest(password: password, token: token)
        
        return await AuthService.resetPassword(body: body)
    }
    
    @MainActor 
    func deleteAccount() async -> Bool {
        let success = await AuthService.deleteStats(userId: user!.id, statId: user!.stats!.id, jwtToken: user!.jwtToken)
        if success {
            return await AuthService.deleteUser(userId: user!.id, jwtToken: user!.jwtToken)
        }
        
        return false
    }
}
