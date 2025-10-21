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

struct GameSession: Codable {
    var id: String
    var mode: String           // "MIXED"
    var difficulty: String     // "MEDIUM"
    var targetCount: Int       // 25
    var players: [GamePlayer]
    var questionSet: QuestionSet
    var startAt: Timestamp
    var createdAt: Timestamp
    var schemaVersion: Int
    var state: String          // WAITING, READY, ACTIVE, FINISHED, CANCELLED
    var result: GameResultFirestore?
    var postgame: GamePostgame

    init(id: String, mode: String = "MIXED", difficulty: String = "MEDIUM", targetCount: Int = 25,
         players: [GamePlayer], questionSet: QuestionSet, startAt: Timestamp,
         createdAt: Timestamp = Timestamp(), schemaVersion: Int = 1, state: String = "WAITING",
         result: GameResultFirestore? = nil, postgame: GamePostgame) {
        self.id = id
        self.mode = mode
        self.difficulty = difficulty
        self.targetCount = targetCount
        self.players = players
        self.questionSet = questionSet
        self.startAt = startAt
        self.createdAt = createdAt
        self.schemaVersion = schemaVersion
        self.state = state
        self.result = result
        self.postgame = postgame
    }
}

struct GamePlayer: Codable, Hashable {
    var uid: String
    var displayName: String

    init(uid: String, displayName: String) {
        self.uid = uid
        self.displayName = displayName
    }
}

struct QuestionSet: Codable {
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

struct QuestionItem: Codable {
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

struct GameResultFirestore: Codable {
    var winnerUid: String
    var p1TimeMs: Int64?
    var p2TimeMs: Int64?
    var finishedAt: Timestamp
    var decidedBy: String  // FIRST_TO_FINISH, BOTH_FINISHED, GRACE_TIMEOUT, FORFEIT

    init(winnerUid: String, p1TimeMs: Int64? = nil, p2TimeMs: Int64? = nil,
         finishedAt: Timestamp, decidedBy: String) {
        self.winnerUid = winnerUid
        self.p1TimeMs = p1TimeMs
        self.p2TimeMs = p2TimeMs
        self.finishedAt = finishedAt
        self.decidedBy = decidedBy
    }
}

struct GamePostgame: Codable {
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
