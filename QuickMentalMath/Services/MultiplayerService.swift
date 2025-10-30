//
//  MultiplayerService.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Common Models

struct FirebaseTimestamp: Codable, Hashable {
    static func == (lhs: FirebaseTimestamp, rhs: FirebaseTimestamp) -> Bool {
        return lhs.seconds == rhs.seconds && lhs.nanos == rhs.nanos
    }
    
    var seconds: Int64
    var nanos: Int

    init(seconds: Int64, nanos: Int = 0) {
        self.seconds = seconds
        self.nanos = nanos
    }
}

enum MatchStatus: String, Codable {
    case WAITING
    case MATCHED
    case ALREADY_MATCHED
}

enum GameState: String, Codable {
    case WAITING
    case READY
    case ACTIVE
    case FINISHED
    case CANCELLED
}

enum ConnectionStatus: String, Codable {
    case ONLINE
    case OFFLINE
}

enum WinDecision: String, Codable {
    case FIRST_TO_FINISH
    case BOTH_FINISHED
    case GRACE_TIMEOUT
    case FORFEIT
}

enum LobbyState: String, Codable, Hashable {
    case WAITING
    case READY
    case STARTED
    case CANCELLED
}

// MARK: - Matchmaking Request/Response Models

struct JoinMatchRequest: Codable {
    var userId: Int
    var username: String
}

struct LeaveMatchRequest: Codable {
    var userId: Int
}

struct JoinMatchResponseWaiting: Codable {
    var status: String  // "WAITING"
}

struct JoinMatchResponseAlreadyMatched: Codable {
    var status: String // "ALREADY_MATCHED"
}

struct JoinMatchResponseMatched: Codable {
    var status: String  // "MATCHED"
    var gameId: String
    var startAt: FirebaseTimestamp
}

enum JoinMatchResponse {
    case waiting(JoinMatchResponseWaiting)
    case matched(JoinMatchResponseMatched)
    case already_matched(JoinMatchResponseAlreadyMatched)
}

// MARK: - Game Request/Response Models

struct SubmitAnswerRequest: Codable {
    var userId: String
    var qIndex: Int
    var answer: Int
    var clientSentAt: Int64?
}

struct SubmitAnswerResponse: Codable {
    var completed: Int
    var state: GameState?
    var result: GameResult?
}

struct PresenceRequest: Codable {
    var userId: Int
    var connection: ConnectionStatus
}

struct ForfeitRequest: Codable {
    var userId: Int
}

struct GameResult: Codable {
    var winnerUid: String
    var p1TimeMs: Int64?
    var p2TimeMs: Int64?
    var finishedAt: FirebaseTimestamp
    var decidedBy: WinDecision
}

struct GenericSuccessResponse: Codable {
    var success: Bool
}

// MARK: - Lobby Request/Response Models

struct CreateLobbyRequest: Codable {
    var userId: Int
    var username: String
}

struct JoinLobbyRequest: Codable {
    var userId: Int
    var username: String
}

struct StartGameRequest: Codable {
    var hostUid: String
}

struct CancelLobbyRequest: Codable {
    var userId: Int
}

struct LeaveLobbyRequest: Codable {
    var userId: Int
}

struct LobbyPlayer: Codable, Hashable {
    static func ==(lhs: LobbyPlayer, rhs: LobbyPlayer) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    var uid: String
    var username: String
    var joinedAt: FirebaseTimestamp
}

struct LobbyDocPlayer: Codable, Hashable {
    static func ==(lhs: LobbyDocPlayer, rhs: LobbyDocPlayer) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    var uid: String
    var username: String
    var joinedAt: Timestamp
    
    func asLobbyPlayer() -> LobbyPlayer {
        return LobbyPlayer(uid: uid, username: username, joinedAt: FirebaseTimestamp(seconds: self.joinedAt.seconds, nanos: Int(self.joinedAt.nanoseconds)))
    }
}

struct LobbyResponse: Codable, Hashable {
    var lobbyId: String
    var code: String
    var players: [LobbyPlayer]
    var hostUid: String
    var minPlayers: Int
    var maxPlayers: Int
    var state: LobbyState
    var gameId: String?
    var createdAt: FirebaseTimestamp
}

struct LobbyDocument: Codable {
    var id: String
    var code: String
    var players: [LobbyDocPlayer]
    var hostUid: String
    var minPlayers: Int
    var maxPlayers: Int
    var state: LobbyState
    var gameId: String?
    var createdAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case players
        case hostUid
        case minPlayers
        case maxPlayers
        case state
        case gameId
        case createdAt
    }
}

struct StartGameResponse: Codable {
    var gameId: String
    var startAt: FirebaseTimestamp
}

// MARK: - Multiplayer Service

class MultiplayerService {

    static let baseUrl = "https://qmm.andy-vu.com/api/v1"

    // MARK: - Retry Helper

    private static func withRetry<T>(maxAttempts: Int = 3, delay: UInt64 = 500_000_000, operation: @escaping () async -> Result<T, Error>) async -> Result<T, Error> {
        var lastError: Error?

        for attempt in 1...maxAttempts {
            let result = await operation()

            switch result {
            case .success:
                return result
            case .failure(let error):
                lastError = error
                if attempt < maxAttempts {
                    try? await Task.sleep(nanoseconds: delay)
                }
            }
        }

        return .failure(lastError ?? NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "All retry attempts failed"]))
    }

    // MARK: - Matchmaking

    static func joinMatch(userId: Int, username: String, jwtToken: String) async -> Result<JoinMatchResponse, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/match/join")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(JoinMatchRequest(userId: userId, username: username))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }
                

                if response.statusCode == 200 {
                    // Try to decode as waiting response first
                    if let waitingResponse = try? JSONDecoder().decode(JoinMatchResponseWaiting.self, from: data) {
                        return .success(.waiting(waitingResponse))
                    }
                    // Try to decode as matched response
                    else if let matchedResponse = try? JSONDecoder().decode(JoinMatchResponseMatched.self, from: data) {
                        return .success(.matched(matchedResponse))
                    }
                    else if let alreadyMatchedResponse = try? JSONDecoder().decode(JoinMatchResponseAlreadyMatched.self, from: data) {
                        return .success(.already_matched(alreadyMatchedResponse))
                    }
                    else {
                        return .failure(NSError(domain: "MultiplayerService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response"]))
                    }
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    static func leaveMatch(userId: Int, jwtToken: String) async -> Result<Bool, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/match/leave")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(LeaveMatchRequest(userId: userId))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    if let successResponse = try? JSONDecoder().decode(GenericSuccessResponse.self, from: data) {
                        return .success(successResponse.success)
                    }
                    return .success(true)
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    static func playBot(userId: Int, username: String, jwtToken: String) async -> Result<JoinMatchResponseMatched, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/match/playBot")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(JoinMatchRequest(userId: userId, username: username))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    let matchedResponse = try JSONDecoder().decode(JoinMatchResponseMatched.self, from: data)
                    return .success(matchedResponse)
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    // MARK: - Game Actions

    static func submitAnswer(gameId: String, userId: String, qIndex: Int, answer: Int, clientSentAt: Int64? = nil, jwtToken: String) async -> Result<SubmitAnswerResponse, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/games/\(gameId)/submit")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(SubmitAnswerRequest(userId: userId, qIndex: qIndex, answer: answer, clientSentAt: clientSentAt))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    let submitResponse = try JSONDecoder().decode(SubmitAnswerResponse.self, from: data)
                    return .success(submitResponse)
                }
                else if response.statusCode == 404 {
                    return .failure(NSError(domain: "MultiplayerService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"]))
                }
                else if response.statusCode == 403 {
                    return .failure(NSError(domain: "MultiplayerService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Not a player in this game"]))
                }
                else if response.statusCode == 409 {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Out of order submission or incorrect answer"
                    return .failure(NSError(domain: "MultiplayerService", code: 409, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    static func updatePresence(gameId: String, userId: Int, connection: ConnectionStatus, jwtToken: String) async -> Result<Bool, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/games/\(gameId)/presence")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(PresenceRequest(userId: userId, connection: connection))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    if let successResponse = try? JSONDecoder().decode(GenericSuccessResponse.self, from: data) {
                        return .success(successResponse.success)
                    }
                    return .success(true)
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    static func forfeit(gameId: String, userId: Int, jwtToken: String) async -> Result<Bool, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/games/\(gameId)/forfeit")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(ForfeitRequest(userId: userId))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    if let successResponse = try? JSONDecoder().decode(GenericSuccessResponse.self, from: data) {
                        return .success(successResponse.success)
                    }
                    return .success(true)
                }
                else if response.statusCode == 404 {
                    return .failure(NSError(domain: "MultiplayerService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Game not found"]))
                }
                else if response.statusCode == 403 {
                    return .failure(NSError(domain: "MultiplayerService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Not a player in this game"]))
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    // MARK: - Lobbies

    static func createLobby(userId: Int, username: String, jwtToken: String) async -> Result<LobbyResponse, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/lobbies/create")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(CreateLobbyRequest(userId: userId, username: username))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    let lobbyResponse = try JSONDecoder().decode(LobbyResponse.self, from: data)
                    return .success(lobbyResponse)
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Failed to create lobby"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    static func joinLobby(code: String, userId: Int, username: String, jwtToken: String) async -> Result<LobbyResponse, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/lobbies/\(code)/join")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(JoinLobbyRequest(userId: userId, username: username))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    let lobbyResponse = try JSONDecoder().decode(LobbyResponse.self, from: data)
                    return .success(lobbyResponse)
                }

                // Parse error from response body
                let errorBody = String(data: data, encoding: .utf8) ?? ""

                // Extract actual error code and message from Spring exception format
                if errorBody.contains("409") || errorBody.contains("Lobby is already full") {
                    return .failure(NSError(domain: "MultiplayerService", code: 409, userInfo: [NSLocalizedDescriptionKey: "Lobby is already full"]))
                }
                else if errorBody.contains("404") || errorBody.contains("Lobby not found or already started") {
                    return .failure(NSError(domain: "MultiplayerService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Lobby not found or already started"]))
                }
                else if errorBody.contains("400") || errorBody.contains("Already in this lobby") {
                    return .failure(NSError(domain: "MultiplayerService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Already in this lobby"]))
                }
                else {
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: "Failed to join lobby"]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    static func startGame(lobbyId: String, hostUid: String, jwtToken: String) async -> Result<StartGameResponse, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/lobbies/\(lobbyId)/start")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(StartGameRequest(hostUid: hostUid))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    let startGameResponse = try JSONDecoder().decode(StartGameResponse.self, from: data)
                    return .success(startGameResponse)
                }
                else if response.statusCode == 404 {
                    return .failure(NSError(domain: "MultiplayerService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Lobby not found"]))
                }
                else if response.statusCode == 403 {
                    return .failure(NSError(domain: "MultiplayerService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Only the host can start the game"]))
                }
                else if response.statusCode == 400 {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Lobby is not ready to start"
                    return .failure(NSError(domain: "MultiplayerService", code: 400, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Failed to start game"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    static func leaveLobby(lobbyId: String, userId: Int, jwtToken: String) async -> Result<LobbyResponse, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/lobbies/\(lobbyId)/leave")!)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(LeaveLobbyRequest(userId: userId))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    let lobbyResponse = try JSONDecoder().decode(LobbyResponse.self, from: data)
                    return .success(lobbyResponse)
                }
                else if response.statusCode == 404 {
                    return .failure(NSError(domain: "MultiplayerService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Lobby not found or user not in lobby"]))
                }
                else if response.statusCode == 400 {
                    return .failure(NSError(domain: "MultiplayerService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Cannot leave lobby after game has started"]))
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Failed to leave lobby"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }

    static func cancelLobby(lobbyId: String, userId: Int, jwtToken: String) async -> Result<Bool, Error> {
        return await withRetry {
            var request = URLRequest(url: URL(string: baseUrl + "/lobbies/\(lobbyId)")!)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

            do {
                request.httpBody = try JSONEncoder().encode(CancelLobbyRequest(userId: userId))
                let (data, httpResponse) = try await URLSession.shared.data(for: request)

                guard let response = httpResponse as? HTTPURLResponse else {
                    return .failure(NSError(domain: "MultiplayerService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
                }

                if response.statusCode == 200 {
                    return .success(true)
                }
                else if response.statusCode == 404 {
                    return .failure(NSError(domain: "MultiplayerService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Lobby not found"]))
                }
                else if response.statusCode == 403 {
                    return .failure(NSError(domain: "MultiplayerService", code: 403, userInfo: [NSLocalizedDescriptionKey: "Not authorized to cancel this lobby"]))
                }
                else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Failed to cancel lobby"
                    return .failure(NSError(domain: "MultiplayerService", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
            catch {
                return .failure(error)
            }
        }
    }
}
