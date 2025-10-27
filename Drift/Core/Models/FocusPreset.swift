//
//  FocusPreset.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import Foundation
import FamilyControls

/// Represents a focus preset with a name and app selection
struct FocusPreset: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    var selection: FamilyActivitySelection
    let blocksAllApps: Bool

    init(id: String, name: String, selection: FamilyActivitySelection = FamilyActivitySelection(), blocksAllApps: Bool = false) {
        self.id = id
        self.name = name
        self.selection = selection
        self.blocksAllApps = blocksAllApps
    }

    // Default presets
    static let socialMedia = FocusPreset(id: "social-media", name: "Social Media")
    static let work = FocusPreset(id: "work", name: "Work")
    static let all = FocusPreset(id: "all", name: "All", blocksAllApps: true)

    static let defaultPresets: [FocusPreset] = [.socialMedia, .work, .all]

    // Check if preset has apps configured
    var isConfigured: Bool {
        return blocksAllApps || !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }
}
