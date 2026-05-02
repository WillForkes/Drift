//
//  FocusSessionManager.swift
//  Drift
//
//

import Foundation
import Combine
import FamilyControls
import ManagedSettings
import ActivityKit

@MainActor
class FocusSessionManager: ObservableObject {
    static let shared = FocusSessionManager()

    // MARK: - Published Properties
    @Published private(set) var isSessionActive: Bool {
        didSet {
            UserDefaults.standard.set(isSessionActive, forKey: Constants.sessionActiveKey)
            if isSessionActive {
                applyAppBlocking()
                let presetName = currentPreset?.name ?? "Unknown"
                AnalyticsManager.shared.startSession(presetName: presetName)
                startLiveActivity()
            } else {
                removeAppBlocking()
                AnalyticsManager.shared.stopSession()
                activeDriftTagId = nil
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
        self.isSessionActive = UserDefaults.standard.bool(forKey: Constants.sessionActiveKey)
        checkAuthorization()
        if isSessionActive {
            applyAppBlocking()
        }
    }

    // MARK: - Public Methods

    func toggleSession() {
        isSessionActive.toggle()
    }

    func startSession() {
        guard !isSessionActive else { return }
        isSessionActive = true
    }

    func startSession(withDriftTagId driftTagId: String) {
        guard !isSessionActive else { return }
        activeDriftTagId = driftTagId
        isSessionActive = true
    }

    func stopSession() {
        guard isSessionActive else { return }
        isSessionActive = false
    }

    func requestAuthorization() async throws {
        try await authCenter.requestAuthorization(for: .individual)
        await checkAuthorization()
    }

    func selectPreset(_ preset: FocusPreset) {
        PresetManager.shared.setCurrentPreset(preset.id)
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
            print("🛡️ [FocusSessionManager] Blocking ALL applications")
            store.shield.applicationCategories = .all()
        } else {
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
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("⚠️ [FocusSessionManager] Live Activities are not enabled")
            return
        }

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

        // Clear reference immediately to prevent race condition
        currentActivity = nil

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            print("✅ [FocusSessionManager] Live Activity ended")
        }
    }


    // MARK: - Debug/Reset

    func resetAllData() {
        if isSessionActive { stopSession() }
        removeAppBlocking()
        PresetManager.shared.setCurrentPreset(PresetManager.shared.presets.first?.id)
        UserDefaults.standard.removeObject(forKey: Constants.sessionActiveKey)
    }
}
