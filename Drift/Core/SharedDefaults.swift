//
//  SharedDefaults.swift
//  Drift
//
//  Created by William Forkes on 07/11/2025.
//

import Foundation

/// Constants and helpers for accessing shared data via App Groups
enum SharedDefaults {
    /// The App Group identifier shared between the main app and extensions
    static let appGroupIdentifier = "group.williamforkes.Drift"

    /// Shared UserDefaults suite for communication between app and extensions
    static var shared: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
}

// MARK: - Convenience Extension

extension UserDefaults {
    /// Access the shared UserDefaults suite for App Groups
    static var appGroup: UserDefaults? {
        return SharedDefaults.shared
    }
}

// MARK: - Future Keys (for reference)
// Uncomment and use these keys when adding features to the Live Activity:
//
// extension SharedDefaults {
//     enum Keys {
//         static let currentPresetName = "drift.shared.currentPresetName"
//         static let currentPresetEmoji = "drift.shared.currentPresetEmoji"
//         static let sessionProgress = "drift.shared.sessionProgress"
//         static let sessionDuration = "drift.shared.sessionDuration"
//     }
// }
