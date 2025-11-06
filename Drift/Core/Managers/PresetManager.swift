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
        static let selectionPrefix = "drift.preset.selection."
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

        // Store selection separately
        saveSelection(for: preset.id, selection: selection)

        // Add to presets array and save metadata
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

        // Update selection separately if provided
        if let newSelection = selection {
            saveSelection(for: id, selection: newSelection)
        }

        // Validate and update name if provided
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

        // Remove preset and its selection
        presets.removeAll(where: { $0.id == id })
        UserDefaults.standard.removeObject(forKey: Constants.selectionPrefix + id)
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
        do {
            let data = try JSONEncoder().encode(presets)
            UserDefaults.standard.set(data, forKey: Constants.presetsKey)
            print("✅ [PresetManager] Saved \(presets.count) preset(s) to UserDefaults")

            // Log app counts for debugging
            for preset in presets {
                let appCount = preset.selection.applicationTokens.count
                let categoryCount = preset.selection.categoryTokens.count
                print("   - \(preset.name): \(appCount) apps, \(categoryCount) categories")
            }
        } catch {
            print("❌ [PresetManager] Failed to encode presets: \(error)")
        }
    }

    private func loadPresets() {
        guard let data = UserDefaults.standard.data(forKey: Constants.presetsKey) else {
            print("ℹ️ [PresetManager] No saved presets found")
            return
        }

        do {
            var loadedPresets = try JSONDecoder().decode([FocusPreset].self, from: data)

            // Load selections separately for each preset
            for i in 0..<loadedPresets.count {
                let id = loadedPresets[i].id
                if let selection = loadSelection(for: id) {
                    loadedPresets[i] = FocusPreset(
                        id: id,
                        name: loadedPresets[i].name,
                        selection: selection,
                        blocksAllApps: loadedPresets[i].blocksAllApps
                    )
                }
            }

            presets = loadedPresets

            print("✅ [PresetManager] Loaded \(presets.count) preset(s) from UserDefaults")

            // Log app counts for debugging
            for preset in presets {
                let appCount = preset.selection.applicationTokens.count
                let categoryCount = preset.selection.categoryTokens.count
                print("   - \(preset.name): \(appCount) apps, \(categoryCount) categories")
            }
        } catch {
            print("❌ [PresetManager] Failed to decode presets: \(error)")
        }
    }

    // MARK: - FamilyActivitySelection Storage
    // Store selections using UserDefaults (supports FamilyActivitySelection via property wrapper)

    private func saveSelection(for presetId: String, selection: FamilyActivitySelection) {
        let key = Constants.selectionPrefix + presetId
        // Use UserDefaults to store the selection - this works with FamilyActivitySelection
        UserDefaults.standard.set(try? NSKeyedArchiver.archivedData(withRootObject: selection, requiringSecureCoding: false), forKey: key)
        print("💾 [PresetManager] Saved selection for preset \(presetId): \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories")
    }

    private func loadSelection(for presetId: String) -> FamilyActivitySelection? {
        let key = Constants.selectionPrefix + presetId
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        guard let selection = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? FamilyActivitySelection else {
            return nil
        }

        print("📂 [PresetManager] Loaded selection for preset \(presetId): \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories")
        return selection
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
