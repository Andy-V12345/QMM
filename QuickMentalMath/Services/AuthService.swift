//
//  AuthService.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/7/24.
//

import Foundation
import SwiftUI

struct User {
    var id: Int
    var username: String
    var jwtToken: String
    var stats: UserStats?
}

struct UserStats: Codable {
    var id: Int
    var additionScore: Int
    var additionTot: Int
    var subtractionScore: Int
    var subtractionTot: Int
    var multiplicationScore: Int
    var multiplicationTot: Int
    var divisionScore: Int
    var divisionTot: Int
    var highScore: Int
    var ttHighScore: Int
    var wins: Int?
    var losses: Int?
    var bestTime: Int?
}

enum AuthState: String, Hashable {
    case UNAUTHORIZED, AUTHORIZED, NO_ACCOUNT, UNKNOWN
}

struct AuthResponse: Decodable {
    var status: String
    var username: String?
    var id: Int?
    var jwtToken: String?
}

struct RegisterRequest: Encodable {
    var email: String
    var username: String
    var password: String
}

struct LoginRequest: Codable {
    var email: String
    var password: String
}

struct UserStatsRequest: Encodable {
    var additionScore: Int
    var additionTot: Int
    var subtractionScore: Int
    var subtractionTot: Int
    var multiplicationScore: Int
    var multiplicationTot: Int
    var divisionScore: Int
    var divisionTot: Int
    var highScore: Int
    var ttHighScore: Int
    var wins: Int?
    var losses: Int?
    var bestTime: Int?
    
    init() {
        self.additionScore = 0
        self.additionTot = 0
        self.subtractionScore = 0
        self.subtractionTot = 0
        self.multiplicationScore = 0
        self.multiplicationTot = 0
        self.divisionScore = 0
        self.divisionTot = 0
        self.highScore = 0
        self.ttHighScore = 0
    }
    
    init(userStats: UserStats) {
        self.additionScore = userStats.additionScore
        self.additionTot = userStats.additionTot
        self.subtractionScore = userStats.subtractionScore
        self.subtractionTot = userStats.subtractionTot
        self.multiplicationScore = userStats.multiplicationScore
        self.multiplicationTot = userStats.multiplicationTot
        self.divisionScore = userStats.divisionScore
        self.divisionTot = userStats.divisionTot
        self.highScore = userStats.highScore
        self.ttHighScore = userStats.ttHighScore
        self.wins = userStats.wins
        self.losses = userStats.losses
        self.bestTime = userStats.bestTime
    }
}

struct LeaderboardResponse: Codable {
    var ttHighScore: Int
    var username: String
}

struct ForgetPasswordRequest: Codable {
    var email: String
}

struct ResetPasswordRequest: Codable {
    var password: String
    var token: String
}

class AuthService {
    
    static let baseUrl = "https://qmm.andy-vu.com/api/v1"
    
    static func login(email: String, password: String) async -> (User?, String) {
        var request = URLRequest(url: URL(string: baseUrl + "/auth/login")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(LoginRequest(email: email, password: password))
            guard let (data, httpResponse) = try await URLSession.shared.data(for: request) as? (Data?, HTTPURLResponse?) else {
                return (nil, "UNKNOWN_ERROR")
            }
            
            if httpResponse?.statusCode == 403 {
                print(httpResponse)
                return (nil, "INVALID_CREDS")
            }
            else {
                if let res = try? JSONDecoder().decode(AuthResponse.self, from: data!) {
                    var user = User(id: res.id!, username: res.username!, jwtToken: res.jwtToken!)
                    user.stats = await loadUserStats(userId: user.id, jwtToken: user.jwtToken)
                    
                    return (user, res.status)
                }
                else {
                    return (nil, "ERROR_DECODING")
                }
            }
        }
        catch {
            print(error)
            return (nil, "UNKNOWN_ERROR")
        }
    }
    
    static func signUp(email: String, username: String, password: String) async -> (User?, String) {
        var request = URLRequest(url: URL(string: baseUrl + "/auth/register")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(RegisterRequest(email: email, username: username, password: password))
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let response = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                if response.status == "USER_CREATED" {
                    var user = User(id: response.id!, username: response.username!, jwtToken: response.jwtToken!)
                    let statsRequest = UserStatsRequest()
                    let success = await createUserStats(userId: user.id, jwtToken: user.jwtToken, statsRequest: statsRequest)
                    
                    if success {
                        let stats = await loadUserStats(userId: user.id, jwtToken: user.jwtToken)
                        user.stats = stats
                    }
                    else {
                        print("couldn't create stats")
                    }
                                                            
                    return (user, response.status)
                }
                else {
                    return (nil, response.status)
                }
            }
            else {
                return (nil, "UNKNOWN_ERROR")
            }
            
        }
        catch {
            return (nil, "UNKNOWN_ERROR")
        }
        
    }
    
    static func loadUserStats(userId: Int, jwtToken: String) async -> UserStats? {
        var request = URLRequest(url: URL(string: baseUrl + "/stats/\(userId)")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let stats = try? JSONDecoder().decode(UserStats.self, from: data) {
                return stats
            }
            else {
                print("no stats")
                return nil
            }
        }
        catch {
            print(error)
            return nil
        }
    }
    
    static func createUserStats(userId: Int, jwtToken: String, statsRequest: UserStatsRequest) async -> Bool {
        var request = URLRequest(url: URL(string: baseUrl + "/stats/\(userId)")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(statsRequest)
            guard let (_, httpResponse) = try await URLSession.shared.data(for: request) as? (Data?, HTTPURLResponse?) else {
                return false
            }
            
            if httpResponse?.statusCode == 201 {
                return true
            }
            else {
                print(httpResponse?.statusCode)
                return false
            }
        }
        catch {
            print(error)
            return false
        }
    }
    
    static func updateUserStats(userId: Int, statId: Int, jwtToken: String, statsRequest: UserStatsRequest) async -> Bool {
        var request = URLRequest(url: URL(string: baseUrl + "/stats/\(userId)/\(statId)")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONEncoder().encode(statsRequest)
            guard let (_, httpResponse) = try await URLSession.shared.data(for: request) as? (Data?, HTTPURLResponse?) else {
                return false
            }
            
            if httpResponse?.statusCode == 201 {
                return true
            }
            else {
                print(httpResponse?.statusCode)
                return false
            }
        }
        catch {
            print(error)
            return false
        }
    }
    
    static func getLeaderboard(topN: Int, jwtToken: String) async -> [LeaderboardResponse]? {
        var request = URLRequest(url: URL(string: baseUrl + "/leaderboard/\(topN)")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let entries = try JSONDecoder().decode([LeaderboardResponse].self, from: data)
            
            return entries
        }
        catch {
            print(error)
            return nil
        }
    }
    
    static func sendForgetPasswordEmail(body: ForgetPasswordRequest) async -> Bool {
        var request = URLRequest(url: URL(string: baseUrl + "/auth/forgot_password")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            guard let (_, httpResponse) = try? await URLSession.shared.data(for: request) as? (Data?, HTTPURLResponse?) else {
                return false
            }
            
            if httpResponse?.statusCode == 200 {
                return true
            }
            
            return false
        }
        catch {
            print(error)
            return false
        }
    }
    
    static func verifyForgetPasswordToken(token: String) async -> Bool {
        var request = URLRequest(url: URL(string: baseUrl + "/auth/reset_password?token=\(token)")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            guard let (_, httpResponse) = try await URLSession.shared.data(for: request) as? (Data?, HTTPURLResponse?) else {
                return false
            }
            if httpResponse?.statusCode == 200 {
                return true
            }
            
            return false
        }
        catch {
            print(error)
            return false
        }
    }
    
    static func resetPassword(body: ResetPasswordRequest) async -> String {
        var request = URLRequest(url: URL(string: baseUrl + "/auth/reset_password")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            guard let (_, httpResponse) = try await URLSession.shared.data(for: request) as? (Data?, HTTPURLResponse?) else {
                return "UNKNOWN_ERROR"
            }
            if httpResponse?.statusCode == 200 {
                return "PASSWORD_UPDATED"
            }
            else if httpResponse?.statusCode == 404 {
                return "NOT_FOUND"
            }
            else if httpResponse?.statusCode == 403 {
                return "INVALID_PASSWORD_LENGTH"
            }
            
            return "UNKNOWN_ERROR"
        }
        catch {
            print(error)
            return "UNKNOWN_ERROR"
        }
    }
    
    static func deleteUser(userId: Int, jwtToken: String) async -> Bool {
        var request = URLRequest(url: URL(string: baseUrl + "/deleteAccount/\(userId)")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        do {
            guard let (_, httpResponse) = try await URLSession.shared.data(for: request) as? (Data?, HTTPURLResponse?) else {
                return false
            }
            if httpResponse?.statusCode == 200 {
                UserDefaults.standard.clearLastGame()
                return true
            }
            
            return false
        }
        catch {
            print(error)
            return false
        }
    }
    
    
    static func deleteStats(userId: Int, statId: Int, jwtToken: String) async -> Bool {
        var request = URLRequest(url: URL(string: baseUrl + "/stats/\(userId)/\(statId)")!)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        do {
            guard let (_, httpResponse) = try await URLSession.shared.data(for: request) as? (Data?, HTTPURLResponse?) else {
                return false
            }
            if httpResponse?.statusCode == 403 {
                return false
            }
            
            return true
        }
        catch {
            print(error)
            return false
        }
    }
    
}
