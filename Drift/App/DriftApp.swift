//
//  DriftApp.swift
//  Drift
//
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
    @State private var urlHandlingTask: Task<Void, Never>?

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainContainerView()
                    .onOpenURL { url in
                        print("🔗 [DriftApp] onOpenURL called with: \(url.absoluteString)")
                        print("🔗 [DriftApp] Scheme: \(url.scheme ?? "nil"), Host: \(url.host ?? "nil"), Path: \(url.path)")
                        handleURL(url)
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

    private func handleURL(_ url: URL) {
        let tagId: String?

        // Handle custom URL scheme: drift://focus?id=0001
        if url.scheme == "drift" {
            print("📱 [DriftApp] Handling custom URL scheme")
            guard url.host == "focus" || url.path == "/focus" else {
                print("❌ [DriftApp] Invalid drift:// URL - expected focus path")
                return
            }

            // Parse tag ID from query parameters
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let id = components.queryItems?.first(where: { $0.name == "id" })?.value else {
                print("❌ [DriftApp] No ID parameter in drift:// URL")
                NotificationCenter.default.post(name: .nfcTagMissingId, object: nil)
                return
            }
            tagId = id
        }
        // Handle universal link: https://links.get-drift.app/focus?id=0001
        else if url.scheme == "https" {
            print("🌐 [DriftApp] Handling universal link")
            guard url.host == "links.get-drift.app",
                  url.path == "/focus" else {
                print("❌ [DriftApp] Invalid universal link - expected links.get-drift.app/focus")
                return
            }

            // Parse tag ID from URL
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let id = components.queryItems?.first(where: { $0.name == "id" })?.value else {
                print("❌ [DriftApp] No ID parameter in universal link")
                NotificationCenter.default.post(name: .nfcTagMissingId, object: nil)
                return
            }
            tagId = id
        } else {
            print("❌ [DriftApp] Unsupported URL scheme: \(url.scheme ?? "nil")")
            return
        }

        // Handle the tag detection
        guard let tagId = tagId else { return }
        print("✅ [DriftApp] Parsed tag ID: \(tagId)")

        urlHandlingTask?.cancel()

        urlHandlingTask = Task { @MainActor in
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
