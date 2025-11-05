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
                // Start analytics tracking
                let presetName = currentPreset?.name ?? "Unknown"
                AnalyticsManager.shared.startSession(presetName: presetName)
            } else {
                removeAppBlocking()
                // Stop analytics tracking
                AnalyticsManager.shared.stopSession()
            }
        }
    }

    @Published private(set) var isAuthorized: Bool = false
    @Published var currentPreset: FocusPreset?

    // MARK: - Private Properties
    private let store = ManagedSettingsStore()
    private let authCenter = AuthorizationCenter.shared

    // MARK: - Constants
    private enum Constants {
        static let sessionActiveKey = "drift.session.active"
        static let currentPresetKey = "drift.current.preset"
    }

    // MARK: - Initialization
    private init() {
        // Restore session state from UserDefaults
        self.isSessionActive = UserDefaults.standard.bool(forKey: Constants.sessionActiveKey)

        // Load current preset
        self.currentPreset = Self.loadCurrentPresetStatic()

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

    private static func loadCurrentPresetStatic() -> FocusPreset? {
        guard let data = UserDefaults.standard.data(forKey: Constants.currentPresetKey),
              let preset = try? JSONDecoder().decode(FocusPreset.self, from: data) else {
            // Default to first preset from PresetManager if none saved
            return PresetManager.shared.presets.first
        }
        return preset
    }

    private func saveCurrentPreset(_ preset: FocusPreset) {
        if let data = try? JSONEncoder().encode(preset) {
            UserDefaults.standard.set(data, forKey: Constants.currentPresetKey)
        }
    }

    // MARK: - Debug/Reset

    /// Clear all session data and reset to defaults (for development/testing)
    func resetAllData() {
        // Stop any active session
        if isSessionActive {
            stopSession()
        }

        // Clear app blocking
        removeAppBlocking()

        // Reset current preset to first available
        currentPreset = PresetManager.shared.presets.first

        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: Constants.sessionActiveKey)
        UserDefaults.standard.removeObject(forKey: Constants.currentPresetKey)
    }
}
