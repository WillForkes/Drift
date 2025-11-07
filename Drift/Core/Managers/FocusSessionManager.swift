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
import ActivityKit

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
                // Start Live Activity
                startLiveActivity()
            } else {
                removeAppBlocking()
                // Stop analytics tracking
                AnalyticsManager.shared.stopSession()
                // Clear active drift tag when stopping
                activeDriftTagId = nil
                // End Live Activity
                endLiveActivity()
            }
        }
    }

    @Published private(set) var isAuthorized: Bool = false
    @Published var activeDriftTagId: String?

    // MARK: - Private Properties
    private let store = ManagedSettingsStore()
    private let authCenter = AuthorizationCenter.shared
    private var currentActivity: Activity<DriftWidgetAttributes>?

    // Current preset comes from PresetManager
    var currentPreset: FocusPreset? {
        return PresetManager.shared.currentPreset
    }

    // MARK: - Constants
    private enum Constants {
        static let sessionActiveKey = "drift.session.active"
    }

    // MARK: - Initialization
    private init() {
        // Restore session state from UserDefaults
        self.isSessionActive = UserDefaults.standard.bool(forKey: Constants.sessionActiveKey)

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

    /// Start a focus session with a specific drift tag
    func startSession(withDriftTagId driftTagId: String) {
        guard !isSessionActive else { return }
        activeDriftTagId = driftTagId
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
        PresetManager.shared.setCurrentPreset(preset.id)

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
        print("🛡️ [FocusSessionManager] applyAppBlocking called")
        print("🛡️ [FocusSessionManager] Authorization status: \(authCenter.authorizationStatus)")

        guard let preset = currentPreset else {
            print("❌ [FocusSessionManager] No current preset - cannot apply blocking")
            return
        }

        print("🛡️ [FocusSessionManager] Using preset: \(preset.name)")
        print("🛡️ [FocusSessionManager] Blocks all apps: \(preset.blocksAllApps)")

        if preset.blocksAllApps {
            // Block all applications for "All" preset
            print("🛡️ [FocusSessionManager] Blocking ALL applications")
            store.shield.applicationCategories = .all()
        } else {
            // Block specific apps from preset selection
            let selection = preset.selection
            print("🛡️ [FocusSessionManager] Blocking \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories, \(selection.webDomainTokens.count) web domains")
            store.shield.applications = selection.applicationTokens
            store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(
                selection.categoryTokens
            )
            store.shield.webDomains = selection.webDomainTokens
        }

        print("✅ [FocusSessionManager] App blocking applied")
    }

    private func removeAppBlocking() {
        // Clear all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }

    // MARK: - Live Activity Management

    private func startLiveActivity() {
        // Check if Live Activities are supported
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ [FocusSessionManager] Live Activities are not enabled")
            return
        }

        // End any existing activity first
        endLiveActivity()

        do {
            let attributes = DriftWidgetAttributes(sessionStartDate: Date())
            let contentState = DriftWidgetAttributes.ContentState()

            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )

            currentActivity = activity
            print("✅ [FocusSessionManager] Live Activity started with ID: \(activity.id)")
        } catch {
            print("❌ [FocusSessionManager] Failed to start Live Activity: \(error)")
        }
    }

    private func endLiveActivity() {
        guard let activity = currentActivity else {
            return
        }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            print("✅ [FocusSessionManager] Live Activity ended")
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
        PresetManager.shared.setCurrentPreset(PresetManager.shared.presets.first?.id)

        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: Constants.sessionActiveKey)
    }
}
