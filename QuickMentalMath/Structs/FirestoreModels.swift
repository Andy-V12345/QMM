//
//  FirestoreModels.swift
//  QuickMentalMath
//
//  Created by Claude Code
//
//  Firestore data models for real-time multiplayer game sessions
//

import Foundation
import FirebaseFirestore
import FirebaseCore

// MARK: - User Match Status
// Path: /users/{uid}/matchStatus/current

struct UserMatchStatus: Codable {
    var matched: Bool
    var gameId: String?
    var timestamp: Timestamp

    init(matched: Bool, gameId: String? = nil, timestamp: Timestamp = Timestamp()) {
        self.matched = matched
        self.gameId = gameId
        self.timestamp = timestamp
    }
}

// MARK: - Game Session
// Path: /games/{gameId}

class GameSession: Codable, Hashable, ObservableObject {
    static func == (lhs: GameSession, rhs: GameSession) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    @Published var showLeaveGameOverlay: Bool = false
    @Published var leaveGameErrorMessage: String = ""
    @Published var showLeaveGameError = false
    
    var id: String
    var mode: String           // "MIXED"
    var difficulty: String     // "MEDIUM"
    var targetCount: Int       // 25
    var players: [GamePlayer]
    var questionSet: QuestionSet
    var startAt: Timestamp
    var createdAt: Timestamp
    var schemaVersion: Int
    var lobbyId: String?       // Lobby ID if game was created from custom lobby (null for matchmaking)
    var state: String          // WAITING, READY, ACTIVE, FINISHED, CANCELLED
    var result: GameResultFirestore?
    var playAgainReady: [String: Bool]?  // Map of player uid -> ready status for play again (custom lobbies)
    var postgame: GamePostgame

    enum CodingKeys : String, CodingKey {
        case id
        case mode
        case difficulty
        case targetCount
        case players
        case questionSet
        case startAt
        case createdAt
        case schemaVersion
        case lobbyId
        case state
        case result
        case playAgainReady
        case postgame
    }

    init(id: String, mode: String = "MIXED", difficulty: String = "MEDIUM", targetCount: Int = 25,
         players: [GamePlayer], questionSet: QuestionSet, startAt: Timestamp,
         createdAt: Timestamp = Timestamp(), schemaVersion: Int = 1, lobbyId: String? = nil,
         state: String = "WAITING", result: GameResultFirestore? = nil,
         playAgainReady: [String: Bool]? = nil, postgame: GamePostgame) {
        self.id = id
        self.mode = mode
        self.difficulty = difficulty
        self.targetCount = targetCount
        self.players = players
        self.questionSet = questionSet
        self.startAt = startAt
        self.createdAt = createdAt
        self.schemaVersion = schemaVersion
        self.lobbyId = lobbyId
        self.state = state
        self.result = result
        self.playAgainReady = playAgainReady
        self.postgame = postgame
    }
    
    func handleLeaveGame(authInfo: AuthInfoModel, appModel: AppModel) {}
}

struct GamePlayer: Codable, Hashable {
    var uid: String
    var displayName: String

    init(uid: String, displayName: String) {
        self.uid = uid
        self.displayName = displayName
    }
}

struct QuestionSet: Codable, Hashable {
    static func == (lhs: QuestionSet, rhs: QuestionSet) -> Bool {
        return lhs.mode == rhs.mode && lhs.difficulty == rhs.difficulty && lhs.targetCount == rhs.targetCount
    }
    
    var mode: String           // "MIXED"
    var difficulty: String     // "MEDIUM"
    var targetCount: Int       // 25
    var questions: [QuestionItem]
    var hash: String?
    var schemaVersion: Int

    init(mode: String = "MIXED", difficulty: String = "MEDIUM", targetCount: Int = 25,
         questions: [QuestionItem], hash: String? = nil, schemaVersion: Int = 1) {
        self.mode = mode
        self.difficulty = difficulty
        self.targetCount = targetCount
        self.questions = questions
        self.hash = hash
        self.schemaVersion = schemaVersion
    }
}

struct QuestionItem: Codable, Hashable {
    var a: Int
    var b: Int
    var op: String  // "+", "-", "×", "÷"
    var correct: Int

    init(a: Int, b: Int, op: String, correct: Int) {
        self.a = a
        self.b = b
        self.op = op
        self.correct = correct
    }
}

struct GameResultFirestore: Codable, Hashable {
    var winnerUid: String
    
    init(winnerUid: String) {
        self.winnerUid = winnerUid
    }
}

struct GamePostgame: Codable, Hashable {
    var acceptingSubmissions: Bool
    var lockedAt: Timestamp?

    init(acceptingSubmissions: Bool, lockedAt: Timestamp? = nil) {
        self.acceptingSubmissions = acceptingSubmissions
        self.lockedAt = lockedAt
    }
}

// MARK: - Player Progress
// Path: /games/{gameId}/progress/{uid}

struct PlayerProgress: Codable {
    var completed: Int             // 0-25
    var status: String             // PLAYING, FINISHED, FORFEIT, POSTGAME
    var lastAnswerAt: Timestamp?
    var finishedAt: Timestamp?
    var elapsedMs: Int64?

    init(completed: Int = 0, status: String = "PLAYING", lastAnswerAt: Timestamp? = nil,
         finishedAt: Timestamp? = nil, elapsedMs: Int64? = nil) {
        self.completed = completed
        self.status = status
        self.lastAnswerAt = lastAnswerAt
        self.finishedAt = finishedAt
        self.elapsedMs = elapsedMs
    }
}
