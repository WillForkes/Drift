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
    @StateObject private var parentalControls = ParentalControlsManager.shared
    @StateObject private var tagManager = DriftTagManager.shared

    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .onOpenURL { url in
                    handleUniversalLink(url)
                }
        }
    }

    /// Handle Universal Links from NFC tags
    private func handleUniversalLink(_ url: URL) {
        // Expected URL format: https://get-drift.app/focus?id=1234
        guard url.host == "get-drift.app",
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
        // Get the preset for this tag
        guard let preset = sessionManager.presets.first(where: { $0.id == tag.presetId }) else {
            // Preset not found - use first available preset
            if let firstPreset = sessionManager.presets.first {
                sessionManager.selectPreset(firstPreset)
            }
            return
        }

        // If stopping session and parental controls enabled, post notification
        if sessionManager.isSessionActive && parentalControls.isEnabled {
            NotificationCenter.default.post(name: .nfcStopRequested, object: nil)
        } else {
            // Switch to tag's preset and toggle session
            if !sessionManager.isSessionActive {
                sessionManager.selectPreset(preset)
            }
            sessionManager.toggleSession()
        }
    }
}

extension Notification.Name {
    static let nfcStopRequested = Notification.Name("nfcStopRequested")
    static let nfcTagNeedsSetup = Notification.Name("nfcTagNeedsSetup")
    static let nfcTagMissingId = Notification.Name("nfcTagMissingId")
}
