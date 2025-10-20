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
        // Expected URL format: https://drift.app/focus
        guard url.host == "drift.app",
              url.path == "/focus" else {
            return
        }

        // Toggle the focus session when NFC tag is tapped
        Task { @MainActor in
            sessionManager.toggleSession()
        }
    }
}
