//
//  FocusSessionManager.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import Foundation
import Combine
import FamilyControls
import ManagedSettings

/// Manages focus session state and app blocking
@MainActor
class FocusSessionManager: ObservableObject {
    static let shared = FocusSessionManager()

    // MARK: - Published Properties
    @Published private(set) var isSessionActive: Bool {
        didSet {
            UserDefaults.standard.set(isSessionActive, forKey: Constants.sessionActiveKey)
            if isSessionActive {
                applyAppBlocking()
            } else {
                removeAppBlocking()
            }
        }
    }

    @Published private(set) var isAuthorized: Bool = false
    @Published var presets: [FocusPreset] = []
    @Published var currentPreset: FocusPreset?

    // MARK: - Private Properties
    private let store = ManagedSettingsStore()
    private let authCenter = AuthorizationCenter.shared

    // MARK: - Constants
    private enum Constants {
        static let sessionActiveKey = "drift.session.active"
        static let presetsKey = "drift.presets"
        static let currentPresetKey = "drift.current.preset"
    }

    // MARK: - Initialization
    private init() {
        // Restore session state from UserDefaults
        self.isSessionActive = UserDefaults.standard.bool(forKey: Constants.sessionActiveKey)

        // Load presets after isSessionActive is initialized
        self.presets = Self.loadPresetsStatic()
        self.currentPreset = Self.loadCurrentPresetStatic(from: self.presets)

        // Check authorization status
        checkAuthorization()

        // If session was active, reapply blocking
        if isSessionActive {
            applyAppBlocking()
        }
    }

    // MARK: - Public Methods

    /// Toggle the focus session on or off
    func toggleSession() {
        isSessionActive.toggle()
    }

    /// Start a focus session
    func startSession() {
        guard !isSessionActive else { return }
        isSessionActive = true
    }

    /// Stop the active focus session
    func stopSession() {
        guard isSessionActive else { return }
        isSessionActive = false
    }

    /// Request Screen Time authorization
    func requestAuthorization() async throws {
        try await authCenter.requestAuthorization(for: .individual)
        await checkAuthorization()
    }

    /// Select a preset to use for sessions
    func selectPreset(_ preset: FocusPreset) {
        currentPreset = preset
        saveCurrentPreset(preset)

        // If session is active, immediately apply new blocking rules
        if isSessionActive {
            applyAppBlocking()
        }
    }

    /// Update a preset's app selection
    func updatePreset(_ preset: FocusPreset, selection: FamilyActivitySelection) {
        var updatedPreset = preset
        updatedPreset.selection = selection

        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index] = updatedPreset
        }

        savePresets()

        // If this is the current preset and session is active, apply changes
        if currentPreset?.id == preset.id {
            currentPreset = updatedPreset
            if isSessionActive {
                applyAppBlocking()
            }
        }
    }

    /// Get a preset by ID
    func getPreset(id: String) -> FocusPreset? {
        return presets.first(where: { $0.id == id })
    }

    // MARK: - Private Methods

    private func checkAuthorization() {
        switch authCenter.authorizationStatus {
        case .approved:
            isAuthorized = true
        case .denied, .notDetermined:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }

    private func applyAppBlocking() {
        guard let preset = currentPreset else { return }

        if preset.blocksAllApps {
            // Block all applications for "All" preset
            store.shield.applicationCategories = .all()
        } else {
            // Block specific apps from preset selection
            let selection = preset.selection
            store.shield.applications = selection.applicationTokens
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(
                selection.categoryTokens
            )
            store.shield.webDomains = selection.webDomainTokens
        }
    }

    private func removeAppBlocking() {
        // Clear all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    private static func loadPresetsStatic() -> [FocusPreset] {
        guard let data = UserDefaults.standard.data(forKey: Constants.presetsKey),
              let presets = try? JSONDecoder().decode([FocusPreset].self, from: data) else {
            // Return default presets if none saved
            return FocusPreset.defaultPresets
        }
        return presets
    }

    private static func loadCurrentPresetStatic(from presets: [FocusPreset]) -> FocusPreset? {
        guard let data = UserDefaults.standard.data(forKey: Constants.currentPresetKey),
              let preset = try? JSONDecoder().decode(FocusPreset.self, from: data) else {
            // Default to first preset if none saved
            return presets.first
        }
        return preset
    }

    private func savePresets() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: Constants.presetsKey)
        }
    }

    private func saveCurrentPreset(_ preset: FocusPreset) {
        if let data = try? JSONEncoder().encode(preset) {
            UserDefaults.standard.set(data, forKey: Constants.currentPresetKey)
        }
    }
}
