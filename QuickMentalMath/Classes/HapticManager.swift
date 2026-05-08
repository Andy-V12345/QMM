//
//  HapticManager.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import UIKit

/// Unified haptic feedback manager for consistent haptic experiences across the app
class HapticManager {

    // MARK: - Singleton

    static let shared = HapticManager()

    // MARK: - Generators

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)

    // MARK: - Initialization

    private init() {
        // Pre-prepare all generators for optimal performance
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        softGenerator.prepare()
        rigidGenerator.prepare()
    }

    // MARK: - Public Methods

    /// Triggers a single haptic feedback
    /// - Parameter style: The style of haptic feedback to trigger
    func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = getGenerator(for: style)
        generator.impactOccurred()
        generator.prepare() // Re-prepare for next use
    }

    /// Triggers multiple haptic feedbacks in sequence
    /// - Parameters:
    ///   - style: The style of haptic feedback to trigger
    ///   - count: Number of haptic feedbacks to trigger
    ///   - interval: Time interval between each haptic (in seconds). Default is 0.1
    func trigger(_ style: UIImpactFeedbackGenerator.FeedbackStyle, count: Int, interval: TimeInterval = 0.1) {
        guard count > 0 else { return }

        let generator = getGenerator(for: style)
        
        for _ in 0..<count {
            generator.impactOccurred()
            generator.prepare()
        }
    }

    // MARK: - Private Helpers

    private func getGenerator(for style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
        switch style {
        case .light:
            return lightGenerator
        case .medium:
            return mediumGenerator
        case .heavy:
            return heavyGenerator
        case .soft:
            return softGenerator
        case .rigid:
            return rigidGenerator
        @unknown default:
            return mediumGenerator
        }
    }
}
