//
//  SharedDefaults.swift
//  Drift
//
//

import Foundation

enum SharedDefaults {
    static let appGroupIdentifier = "group.williamforkes.Drift"

    static var shared: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
}

// MARK: - Convenience Extension

extension UserDefaults {
    static var appGroup: UserDefaults? {
        return SharedDefaults.shared
    }
}
