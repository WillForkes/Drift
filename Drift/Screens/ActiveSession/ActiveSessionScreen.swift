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
                // Session info
                VStack(spacing: DesignTokens.Spacing.xLarge) {
                    Text("drift")
                        .headingXL()
                        .foregroundColor(DesignTokens.Colors.primary)
                        .padding(.top, DesignTokens.Spacing.xLarge)
                    
                    Spacer()
                    
                    // Lock icon
                    Image(systemName: "lock.fill")
                        .font(.system(size: 80))
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                        .frame(width: 80, height: 80)

                    
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        Text("You are now focused.")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                        
                        Text(nfcReader.isScanning ? "Hold drift near phone" : "Tap your phone on drift to stop")
                            .bodySmall()
                            .extraSubtextColor()
                            .padding(.top, DesignTokens.Spacing.large)
                    }
                    
                    VStack {
                        if let preset = presetManager.currentPreset {
                            PillBadge(text: "\(preset.emoji) \(preset.name)", iconColor: .green, iconSize: 5)
                        }
                    }.padding(.top, DesignTokens.Padding.large)
                    
                    Spacer()
                }


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
    let presetManager = PresetManager.shared

    // Set up dummy preset for preview
    if presetManager.presets.isEmpty {
        try? presetManager.createPreset(name: "Deep Work", emoji: "🎯")
    }
    if presetManager.currentPresetId == nil, let firstPreset = presetManager.presets.first {
        presetManager.setCurrentPreset(firstPreset.id)
    }

    return ActiveSessionScreen()
}
