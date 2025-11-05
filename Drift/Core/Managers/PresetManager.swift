//
//  PresetManager.swift
//  Drift
//
//  Created by Claude Code on 05/11/2025.
//

import Foundation
import FamilyControls

/// Manages focus presets
@MainActor
class PresetManager: ObservableObject {
    static let shared = PresetManager()

    @Published var presets: [FocusPreset] = []

    private enum Constants {
        static let presetsKey = "drift.presets"
        static let maxNameLength = 30
    }

    private init() {
        loadPresets()
    }

    // MARK: - Public Methods

    /// Create a new preset
    func createPreset(name: String, selection: FamilyActivitySelection = FamilyActivitySelection(), blocksAllApps: Bool = false) throws -> FocusPreset {
        try validateName(name, excludingId: nil)

        let preset = FocusPreset(
            id: UUID().uuidString,
            name: name,
            selection: selection,
            blocksAllApps: blocksAllApps
        )

        presets.append(preset)
        savePresets()

        print("✅ [PresetManager] Created preset: '\(name)' (id: \(preset.id))")
        return preset
    }

    /// Update an existing preset
    func updatePreset(id: String, name: String? = nil, selection: FamilyActivitySelection? = nil) throws {
        guard let index = presets.firstIndex(where: { $0.id == id }) else {
            throw PresetError.presetNotFound
        }

        // Validate name if provided
        if let newName = name {
            try validateName(newName, excludingId: id)
            presets[index] = FocusPreset(
                id: presets[index].id,
                name: newName,
                selection: selection ?? presets[index].selection,
                blocksAllApps: presets[index].blocksAllApps
            )
        } else if let newSelection = selection {
            presets[index] = FocusPreset(
                id: presets[index].id,
                name: presets[index].name,
                selection: newSelection,
                blocksAllApps: presets[index].blocksAllApps
            )
        }

        savePresets()
        print("✅ [PresetManager] Updated preset: \(id)")
    }

    /// Rename a preset (convenience method)
    func renamePreset(id: String, newName: String) throws {
        try updatePreset(id: id, name: newName)
    }

    /// Delete a preset
    func deletePreset(id: String) throws {
        guard presets.contains(where: { $0.id == id }) else {
            throw PresetError.presetNotFound
        }

        // Get first remaining preset (if any) for reassignment
        let remainingPresets = presets.filter { $0.id != id }
        let reassignToId = remainingPresets.first?.id

        // Reassign drifts using this preset
        DriftTagManager.shared.reassignPreset(from: id, to: reassignToId)

        // Remove preset
        presets.removeAll(where: { $0.id == id })
        savePresets()

        print("✅ [PresetManager] Deleted preset: \(id)")
    }

    /// Get a preset by ID
    func getPreset(id: String) -> FocusPreset? {
        return presets.first(where: { $0.id == id })
    }

    // MARK: - Validation

    private func validateName(_ name: String, excludingId: String?) throws {
        // Check if empty
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if trimmedName.isEmpty {
            throw PresetError.emptyName
        }

        // Check length
        if trimmedName.count > Constants.maxNameLength {
            throw PresetError.nameTooLong
        }

        // Check for duplicates (case-insensitive)
        let isDuplicate = presets.contains { preset in
            guard preset.id != excludingId else { return false }
            return preset.name.lowercased() == trimmedName.lowercased()
        }

        if isDuplicate {
            throw PresetError.duplicateName
        }
    }

    // MARK: - Persistence

    private func savePresets() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: Constants.presetsKey)
        }
    }

    private func loadPresets() {
        guard let data = UserDefaults.standard.data(forKey: Constants.presetsKey),
              let loadedPresets = try? JSONDecoder().decode([FocusPreset].self, from: data) else {
            return
        }
        presets = loadedPresets
    }

    // MARK: - Debug/Reset

    /// Clear all presets (for development/testing)
    func resetAllData() {
        presets = []
        UserDefaults.standard.removeObject(forKey: Constants.presetsKey)
    }
}

// MARK: - Errors

enum PresetError: LocalizedError {
    case emptyName
    case nameTooLong
    case duplicateName
    case presetNotFound

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Preset name cannot be empty"
        case .nameTooLong:
            return "Preset name is too long (max 30 characters)"
        case .duplicateName:
            return "A preset with this name already exists"
        case .presetNotFound:
            return "Preset not found"
        }
    }
}
