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

    // MARK: - Private Properties
    private let store = ManagedSettingsStore()
    private let authCenter = AuthorizationCenter.shared

    // MARK: - Constants
    private enum Constants {
        static let sessionActiveKey = "drift.session.active"
        static let blockedAppsKey = "drift.blocked.apps"
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

    /// Save the selected apps to block
    func saveBlockedApps(_ selection: FamilyActivitySelection) {
        if let data = try? JSONEncoder().encode(selection) {
            UserDefaults.standard.set(data, forKey: Constants.blockedAppsKey)
        }

        // If session is active, immediately apply new blocking rules
        if isSessionActive {
            applyAppBlocking()
        }
    }

    /// Get the currently saved blocked apps selection
    func getBlockedApps() -> FamilyActivitySelection {
        guard let data = UserDefaults.standard.data(forKey: Constants.blockedAppsKey),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return FamilyActivitySelection()
        }
        return selection
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
        let selection = getBlockedApps()

        // Apply application blocking
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(
            selection.categoryTokens
        )

        // Apply web domain blocking if any
        store.shield.webDomains = selection.webDomainTokens
    }

    private func removeAppBlocking() {
        // Clear all shields
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
    }
}
