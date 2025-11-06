//
//  ActiveSessionScreen.swift
//  Drift
//
//  Created by Claude Code on 06/11/2025.
//

import SwiftUI

struct ActiveSessionScreen: View {
    @ObservedObject private var sessionManager = FocusSessionManager.shared
    @ObservedObject private var presetManager = PresetManager.shared
    @ObservedObject private var driftManager = DriftTagManager.shared
    @ObservedObject private var nfcReader = NFCReaderManager.shared
    @ObservedObject private var coordinator = NFCFocusCoordinator.shared

    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.xxxLarge) {
                Spacer()

                // Session info
                VStack(spacing: DesignTokens.Spacing.xLarge) {
                    Text("Active Session")
                        .heading1()
                        .foregroundColor(DesignTokens.Colors.textPrimary)

                    if let driftTagId = sessionManager.activeDriftTagId,
                       let drift = driftManager.getTag(by: driftTagId) {
                        Text(drift.label)
                            .heading2()
                            .foregroundColor(DesignTokens.Colors.subtext)
                    }

                    if let preset = presetManager.currentPreset {
                        Text(preset.name)
                            .body()
                            .subtextColor()
                    }

                    Text(nfcReader.isScanning ? "Hold drift near phone" : "Tap button to stop")
                        .bodySmall()
                        .extraSubtextColor()
                        .padding(.top, DesignTokens.Spacing.large)
                }

                Spacer()

                // Stop button
                DriftButton(title: "Stop Session", icon: "stop.fill", style: .primary) {
                    startStopScan()
                }
                .padding(.bottom, DesignTokens.Spacing.xxLarge)
            }
            .padding(DesignTokens.Padding.large)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Methods

    private func startStopScan() {
        print("📱 [ActiveSessionScreen] Starting NFC scan to stop session")

        nfcReader.startScanning { result in
            switch result {
            case .success(let tagId):
                print("✅ [ActiveSessionScreen] Tag detected: \(tagId)")
                handleTagDetection(tagId: tagId)

            case .failure(let error):
                print("❌ [ActiveSessionScreen] Scan failed: \(error.localizedDescription)")
                if case .userCancelled = error {
                    return
                }
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func handleTagDetection(tagId: String) {
        let result = coordinator.handleTagDetection(tagId: tagId)

        switch result {
        case .success(let action):
            switch action {
            case .started:
                print("⚠️ [ActiveSessionScreen] Unexpected - session started from active screen")

            case .stopped:
                print("⏹️ [ActiveSessionScreen] Session stopped successfully")
            }

        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    ActiveSessionScreen()
}
