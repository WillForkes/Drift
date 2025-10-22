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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleUniversalLink(url)
                }
        }
    }

    /// Handle Universal Links from NFC tags
    private func handleUniversalLink(_ url: URL) {
        // Expected URL format: https://get-drift.app/focus
        guard url.host == "get-drift.app",
              url.path == "/focus" else {
            return
        }

        // Toggle the focus session when NFC tag is tapped
        Task { @MainActor in
            // If stopping session and parental controls enabled, post notification
            if sessionManager.isSessionActive && parentalControls.isEnabled {
                NotificationCenter.default.post(name: .nfcStopRequested, object: nil)
            } else {
                sessionManager.toggleSession()
            }
        }
    }
}

extension Notification.Name {
    static let nfcStopRequested = Notification.Name("nfcStopRequested")
}
