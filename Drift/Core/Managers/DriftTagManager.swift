//
//  DriftTagManager.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import Foundation

struct DriftTag: Codable, Identifiable {
    let id: String // Unique identifier from URL (e.g., "1234")
    var label: String // User-given name (e.g., "Kitchen")
    var presetId: String
    let dateAdded: Date

    init(id: String, label: String, presetId: String) {
        self.id = id
        self.label = label
        self.presetId = presetId
        self.dateAdded = Date()
    }
}

@MainActor
class DriftTagManager: ObservableObject {
    static let shared = DriftTagManager()

    @Published var tags: [DriftTag] = []

    private enum Constants {
        static let tagsKey = "drift.tags"
    }

    private init() {
        loadTags()
    }

    // MARK: - Public Methods

    func registerTag(id: String, label: String, presetId: String) {
        let tag = DriftTag(id: id, label: label, presetId: presetId)
        tags.append(tag)
        saveTags()
    }

    func updateTag(id: String, label: String, presetId: String) {
        guard let index = tags.firstIndex(where: { $0.id == id }) else { return }
        tags[index].label = label
        tags[index].presetId = presetId
        saveTags()
    }

    func updateDriftPreset(driftId: String, presetId: String) {
        guard let index = tags.firstIndex(where: { $0.id == driftId }) else {
            print("⚠️ [DriftTagManager] Cannot update preset - drift not found: \(driftId)")
            return
        }

        tags[index].presetId = presetId
        saveTags()
        print("✅ [DriftTagManager] Updated drift '\(tags[index].label)' to preset: \(presetId)")
    }

    func deleteTag(id: String) {
        tags.removeAll(where: { $0.id == id })
        saveTags()
    }

    func getTag(by id: String) -> DriftTag? {
        return tags.first(where: { $0.id == id })
    }

    func isRegistered(id: String) -> Bool {
        return tags.contains(where: { $0.id == id })
    }

    /// Reassign drifts from one preset to another (used when deleting presets)
    func reassignPreset(from oldId: String, to newId: String?) {
        var updated = false
        for index in tags.indices {
            if tags[index].presetId == oldId {
                tags[index].presetId = newId ?? ""
                updated = true
            }
        }

        if updated {
            saveTags()
            print("✅ [DriftTagManager] Reassigned drifts from preset \(oldId) to \(newId ?? "none")")
        }
    }

    // MARK: - Persistence

    private func saveTags() {
        if let data = try? JSONEncoder().encode(tags) {
            UserDefaults.standard.set(data, forKey: Constants.tagsKey)
        }
    }

    private func loadTags() {
        guard let data = UserDefaults.standard.data(forKey: Constants.tagsKey),
              let loadedTags = try? JSONDecoder().decode([DriftTag].self, from: data) else {
            return
        }
        tags = loadedTags
    }

    // MARK: - Debug/Reset

    func resetAllData() {
        tags = []
        UserDefaults.standard.removeObject(forKey: Constants.tagsKey)
    }
}
