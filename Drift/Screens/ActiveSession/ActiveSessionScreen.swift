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

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.xxxLarge) {
                Spacer()

                // Placeholder content
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

                    Text("Tap your drift to stop")
                        .bodySmall()
                        .extraSubtextColor()
                        .padding(.top, DesignTokens.Spacing.large)
                }

                Spacer()
            }
            .padding(DesignTokens.Padding.large)
        }
    }
}

#Preview {
    ActiveSessionScreen()
}
