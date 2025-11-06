//
//  DriftApp.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

@main
struct DriftApp: App {
    @StateObject private var sessionManager = FocusSessionManager.shared
    @StateObject private var presetManager = PresetManager.shared
    @StateObject private var parentalControls = ParentalControlsManager.shared
    @StateObject private var tagManager = DriftTagManager.shared
    @StateObject private var coordinator = NFCFocusCoordinator.shared
    @AppStorage("drift.onboarding.completed") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainContainerView()
                    .onOpenURL { url in
                        print("🔗 [DriftApp] onOpenURL called with: \(url.absoluteString)")
                        print("🔗 [DriftApp] Host: \(url.host ?? "nil"), Path: \(url.path)")
                        handleUniversalLink(url)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .hardResetRequested)) { _ in
                        performHardReset()
                    }
            } else {
                OnboardingFlow(onComplete: {
                    hasCompletedOnboarding = true
                })
            }
        }
    }

    /// Handle Universal Links from NFC tags
    private func handleUniversalLink(_ url: URL) {
        // Expected URL format: https://links.get-drift.app/focus?id=0001
        guard url.host == "links.get-drift.app",
              url.path == "/focus" else {
            return
        }

        // Parse tag ID from URL
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let tagId = components.queryItems?.first(where: { $0.name == "id" })?.value else {
            // No ID parameter - show error
            NotificationCenter.default.post(name: .nfcTagMissingId, object: nil)
            return
        }

        Task { @MainActor in
            // Check if tag is registered
            if let tag = tagManager.getTag(by: tagId) {
                // Tag is registered - handle session toggle
                handleRegisteredTag(tag)
            } else {
                // Tag not registered - show setup flow
                NotificationCenter.default.post(name: .nfcTagNeedsSetup, object: tagId)
            }
        }
    }

    private func handleRegisteredTag(_ tag: DriftTag) {
        // Use coordinator to handle session toggle
        let result = coordinator.handleTagDetection(tagId: tag.id)

        switch result {
        case .success(let action):
            switch action {
            case .started(let driftName, let presetName):
                print("▶️ [DriftApp] Session started from universal link: \(driftName) - \(presetName)")

            case .stopped:
                print("⏹️ [DriftApp] Session stopped from universal link")
            }

        case .failure(let error):
            print("❌ [DriftApp] Failed to handle tag: \(error.localizedDescription)")
            // Could post a notification here to show error in UI if needed
        }
    }

    /// Perform hard reset of all app data (for development/testing)
    private func performHardReset() {
        print("🗑️ [Debug] Hard reset - clearing all data")

        // Clear all manager data
        sessionManager.resetAllData()
        presetManager.resetAllData()
        tagManager.resetAllData()
        parentalControls.resetAllData()
        AnalyticsManager.shared.resetAllData()

        // Explicitly remove onboarding flag from UserDefaults
        UserDefaults.standard.removeObject(forKey: "drift.onboarding.completed")

        // Reset the @AppStorage property to trigger view update
        hasCompletedOnboarding = false

        print("✅ [Debug] Reset complete")
    }
}

extension Notification.Name {
    static let nfcStopRequested = Notification.Name("nfcStopRequested")
    static let nfcTagNeedsSetup = Notification.Name("nfcTagNeedsSetup")
    static let nfcTagMissingId = Notification.Name("nfcTagMissingId")
    static let hardResetRequested = Notification.Name("hardResetRequested")
}
