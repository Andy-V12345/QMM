//
//  GameStorageExtension.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import Foundation

extension UserDefaults {

    private static let lastGameKey = "lastPlayedGame"

    /// Saves the last played game to UserDefaults
    func saveLastGame(_ game: GameModel) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(game)
            set(data, forKey: UserDefaults.lastGameKey)
        } catch {
            print("Failed to save last game: \(error.localizedDescription)")
        }
    }

    /// Loads the last played game from UserDefaults
    func loadLastGame() -> GameModel? {
        guard let data = data(forKey: UserDefaults.lastGameKey) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let game = try decoder.decode(GameModel.self, from: data)
            return game
        } catch {
            print("Failed to load last game: \(error.localizedDescription)")
            return nil
        }
    }

    /// Clears the saved last game
    func clearLastGame() {
        removeObject(forKey: UserDefaults.lastGameKey)
    }
}
