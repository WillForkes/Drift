//
//  FocusPreset.swift
//  Drift
//
//

import Foundation
import FamilyControls

struct FocusPreset: Identifiable, Equatable, Codable {
    let id: String
    let name: String
    var emoji: String
    var selection: FamilyActivitySelection
    let blocksAllApps: Bool

    init(id: String, name: String, emoji: String = "⚡️", selection: FamilyActivitySelection = FamilyActivitySelection(), blocksAllApps: Bool = false) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.selection = selection
        self.blocksAllApps = blocksAllApps
    }

    // Check if preset has apps configured
    var isConfigured: Bool {
        return blocksAllApps || !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty
    }

    // MARK: - Codable
    // Selection is not encoded - stored separately by PresetManager

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, blocksAllApps
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decodeIfPresent(String.self, forKey: .emoji) ?? "⚡️"
        blocksAllApps = try container.decode(Bool.self, forKey: .blocksAllApps)
        selection = FamilyActivitySelection()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(blocksAllApps, forKey: .blocksAllApps)
    }
}
