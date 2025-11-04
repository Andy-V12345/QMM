//
//  DeepLinkHandler.swift
//  QuickMentalMath
//
//  Created by Claude Code
//

import Foundation

enum DeepLink {
    case lobby(code: String)
    case invalid
}

class DeepLinkHandler {

    /// Parse a deep link URL and return the appropriate DeepLink enum
    /// Supports format: qmm://lobby/{CODE}
    /// - Parameter url: The URL to parse
    /// - Returns: DeepLink enum (.lobby with code, or .invalid)
    static func parse(_ url: URL) -> DeepLink {
        // Check if scheme is qmm
        guard url.scheme == "qmm" else {
            return .invalid
        }

        // Check if host is "lobby"
        guard url.host() == "lobby" else {
            return .invalid
        }

        // Extract code from path (remove leading slash)
        let path = url.path()
        let code = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        // Validate code format: 6 characters, alphanumeric
        guard code.count == 6,
              code.allSatisfy({ $0.isLetter || $0.isNumber }) else {
            return .invalid
        }

        // Return lobby deep link with uppercased code
        return .lobby(code: code.uppercased())
    }
}
