//
//  PresetManager.swift
//  Drift
//
//

import Foundation
import FamilyControls
import ManagedSettings

@MainActor
class PresetManager: ObservableObject {
    static let shared = PresetManager()

    @Published var presets: [FocusPreset] = []
    @Published var currentPresetId: String?

    private var cachedCurrentPreset: FocusPreset?

    private enum Constants {
        static let presetsKey = "drift.presets"
        static let selectionPrefix = "drift.preset.selection."
        static let currentPresetKey = "drift.currentPresetId"
        static let maxNameLength = 30
    }

    private init() {
        loadPresets()
        loadCurrentPresetId()
    }

    // MARK: - Public Methods

    func createPreset(name: String, emoji: String = "⚡️", selection: FamilyActivitySelection = FamilyActivitySelection(), blocksAllApps: Bool = false) throws -> FocusPreset {
        try validateName(name, excludingId: nil)

        let preset = FocusPreset(
            id: UUID().uuidString,
            name: name,
            emoji: emoji,
            selection: selection,
            blocksAllApps: blocksAllApps
        )

        presets.append(preset)
        saveSelection(for: preset.id, selection: selection)
        savePresets()

        print("✅ [PresetManager] Created preset: '\(name)' with emoji: \(emoji)")
        return preset
    }

    func updatePreset(id: String, name: String? = nil, emoji: String? = nil, selection: FamilyActivitySelection? = nil) throws {
        guard let index = presets.firstIndex(where: { $0.id == id }) else {
            throw PresetError.presetNotFound
        }

        let currentPreset = presets[index]
        let newName = name ?? currentPreset.name
        let newEmoji = emoji ?? currentPreset.emoji
        let newSelection = selection ?? currentPreset.selection

        if let name = name, name != currentPreset.name {
            try validateName(name, excludingId: id)
        }

        presets[index] = FocusPreset(
            id: id,
            name: newName,
            emoji: newEmoji,
            selection: newSelection,
            blocksAllApps: currentPreset.blocksAllApps
        )

        // Save selection separately
        if let selection = selection {
            saveSelection(for: id, selection: selection)
        }

        savePresets()

        // Update cache if this is the current preset
        if id == currentPresetId {
            cachedCurrentPreset = presets[index]
        }

        print("✅ [PresetManager] Updated preset: \(id)")
    }

    func deletePreset(id: String) throws {
        guard presets.contains(where: { $0.id == id }) else {
            throw PresetError.presetNotFound
        }

        let reassignToId = presets.first(where: { $0.id != id })?.id
        DriftTagManager.shared.reassignPreset(from: id, to: reassignToId)

        presets.removeAll(where: { $0.id == id })
        UserDefaults.standard.removeObject(forKey: Constants.selectionPrefix + id)
        savePresets()

        // Clear current preset if deleted
        if currentPresetId == id {
            currentPresetId = presets.first?.id
            cachedCurrentPreset = presets.first
            saveCurrentPresetId()
        }

        print("✅ [PresetManager] Deleted preset: \(id)")
    }

    func getPreset(id: String) -> FocusPreset? {
        return presets.first(where: { $0.id == id })
    }

    var currentPreset: FocusPreset? {
        guard let id = currentPresetId else {
            cachedCurrentPreset = nil
            return nil
        }

        if cachedCurrentPreset?.id == id {
            return cachedCurrentPreset
        }

        cachedCurrentPreset = getPreset(id: id)
        return cachedCurrentPreset
    }

    func setCurrentPreset(_ presetId: String?) {
        currentPresetId = presetId
        // Update cache immediately
        cachedCurrentPreset = presetId.flatMap { getPreset(id: $0) }
        saveCurrentPresetId()
        print("✅ [PresetManager] Current preset set to: \(presetId ?? "none")")
    }

    // MARK: - Validation

    private func validateName(_ name: String, excludingId: String?) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        if trimmedName.isEmpty {
            throw PresetError.emptyName
        }

        if trimmedName.count > Constants.maxNameLength {
            throw PresetError.nameTooLong
        }

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
        } catch {
            print("❌ [PresetManager] Failed to encode presets: \(error)")
        }
    }

    private func loadPresets() {
        guard let data = UserDefaults.standard.data(forKey: Constants.presetsKey) else {
            return
        }

        do {
            var loadedPresets = try JSONDecoder().decode([FocusPreset].self, from: data)

            // Load selections separately for each preset
            for i in 0..<loadedPresets.count {
                if let selection = loadSelection(for: loadedPresets[i].id) {
                    loadedPresets[i].selection = selection
                }
            }

            presets = loadedPresets
            print("✅ [PresetManager] Loaded \(presets.count) preset(s)")
        } catch {
            print("❌ [PresetManager] Failed to decode presets: \(error)")
        }
    }

    private func saveSelection(for presetId: String, selection: FamilyActivitySelection) {
        let key = Constants.selectionPrefix + presetId

        // Extract tokens (which ARE Codable) from selection
        let wrapper = SelectionTokenWrapper(
            applicationTokens: Array(selection.applicationTokens),
            categoryTokens: Array(selection.categoryTokens),
            webDomainTokens: Array(selection.webDomainTokens)
        )

        do {
            let data = try JSONEncoder().encode(wrapper)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("❌ [PresetManager] Failed to encode selection tokens: \(error)")
        }
    }

    private func loadSelection(for presetId: String) -> FamilyActivitySelection? {
        let key = Constants.selectionPrefix + presetId

        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        do {
            let wrapper = try JSONDecoder().decode(SelectionTokenWrapper.self, from: data)

            // Reconstruct FamilyActivitySelection from tokens
            var selection = FamilyActivitySelection()
            selection.applicationTokens = Set(wrapper.applicationTokens)
            selection.categoryTokens = Set(wrapper.categoryTokens)
            selection.webDomainTokens = Set(wrapper.webDomainTokens)

            return selection
        } catch {
            print("❌ [PresetManager] Failed to decode selection tokens: \(error)")
            return nil
        }
    }

    private func saveCurrentPresetId() {
        if let id = currentPresetId {
            UserDefaults.standard.set(id, forKey: Constants.currentPresetKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Constants.currentPresetKey)
        }
    }

    private func loadCurrentPresetId() {
        currentPresetId = UserDefaults.standard.string(forKey: Constants.currentPresetKey)
    }

    // MARK: - Debug/Reset

    func resetAllData() {
        presets = []
        currentPresetId = nil
        UserDefaults.standard.removeObject(forKey: Constants.presetsKey)
        UserDefaults.standard.removeObject(forKey: Constants.currentPresetKey)
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            if key.hasPrefix(Constants.selectionPrefix) {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}

// MARK: - Selection Token Storage

/// Codable wrapper for FamilyActivitySelection tokens
private struct SelectionTokenWrapper: Codable {
    let applicationTokens: [ApplicationToken]
    let categoryTokens: [ActivityCategoryToken]
    let webDomainTokens: [WebDomainToken]
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
