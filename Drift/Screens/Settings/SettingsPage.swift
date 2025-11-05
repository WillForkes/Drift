//
//  SettingsPage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct SettingsPage: View {
    @StateObject private var driftManager = DriftTagManager.shared
    @StateObject private var presetManager = PresetManager.shared
    @State private var presentedPreset: FocusPreset?

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignTokens.Spacing.xxxLarge) {
                    // Your drift's Section
                    VStack(spacing: DesignTokens.Spacing.xLarge) {
                        Text("Your drift's")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignTokens.Padding.large)

                        if driftManager.tags.isEmpty {
                            Text("No drifts")
                                .body()
                                .subtextColor()
                                .padding(.horizontal, DesignTokens.Padding.large)
                        } else {
                            ForEach(driftManager.tags) { tag in
                                DriftCard(
                                    tag: tag,
                                    presetName: getPresetName(for: tag.presetId),
                                    onDelete: {
                                        driftManager.deleteTag(id: tag.id)
                                    }
                                )
                                .padding(.horizontal, DesignTokens.Padding.large)
                            }
                        }
                    }

                    // Modes Section
                    VStack(spacing: DesignTokens.Spacing.xLarge) {
                        Text("Modes")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignTokens.Padding.large)

                        if presetManager.presets.isEmpty {
                            Text("No modes")
                                .body()
                                .subtextColor()
                                .padding(.horizontal, DesignTokens.Padding.large)
                        } else {
                            ForEach(presetManager.presets) { preset in
                                PresetModeCard(
                                    preset: preset,
                                    appCountText: getAppCountText(for: preset),
                                    assignedToText: getDriftCount(for: preset.id),
                                    presentedPreset: $presentedPreset
                                )
                                .padding(.horizontal, DesignTokens.Padding.large)
                            }
                        }
                    }

                    // Privacy & Settings Section
                    VStack(spacing: DesignTokens.Spacing.xLarge) {
                        Text("Privacy & Settings")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignTokens.Padding.large)

                        VStack(spacing: DesignTokens.Spacing.large) {
                            SettingsRow(title: "Privacy Policy", icon: "hand.raised.fill")
                            SettingsRow(title: "Terms of Service", icon: "doc.text.fill")
                            SettingsRow(title: "Notifications", icon: "bell.fill")
                            SettingsRow(title: "Data & Storage", icon: "externaldrive.fill")
                            SettingsRow(title: "About Drift", icon: "info.circle.fill")
                            SettingsRow(title: "Contact Support", icon: "questionmark.circle.fill")
                        }
                        .padding(.horizontal, DesignTokens.Padding.large)
                    }

                    // Debug Section (only in DEBUG builds)
                    #if DEBUG
                    VStack(spacing: DesignTokens.Spacing.xLarge) {
                        Text("Debug")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignTokens.Padding.large)

                        VStack(spacing: DesignTokens.Spacing.large) {
                            SettingsRow(
                                title: "Hard Reset (Clear All Data)",
                                icon: "exclamationmark.triangle.fill",
                                action: performHardReset
                            )
                        }
                        .padding(.horizontal, DesignTokens.Padding.large)
                    }
                    #endif

                    // Bottom spacing
                    Spacer()
                        .frame(height: DesignTokens.Spacing.xxxLarge)
                }
            }
        }
        .sheet(item: $presentedPreset) { preset in
            PresetEditSheet(preset: preset, isPresented: .constant(true))
        }
    }

    // MARK: - Helper Functions

    private func getPresetName(for presetId: String) -> String {
        guard !presetId.isEmpty,
              let preset = presetManager.getPreset(id: presetId) else {
            return "None"
        }
        return preset.name
    }

    private func getDriftCount(for presetId: String) -> String {
        let count = driftManager.tags.filter { $0.presetId == presetId }.count
        if count == 0 {
            return "Not assigned"
        } else if count == 1 {
            return "1 drift"
        } else {
            return "\(count) drifts"
        }
    }

    private func getAppCountText(for preset: FocusPreset) -> String {
        if preset.blocksAllApps {
            return "All apps"
        } else {
            let count = preset.selection.applicationTokens.count
            return "\(count) apps"
        }
    }

    // MARK: - Debug Methods

    private func performHardReset() {
        // Post notification to trigger app-level hard reset
        NotificationCenter.default.post(name: .hardResetRequested, object: nil)
    }
}

/// MARK: - Supporting Views

struct DriftCard: View {
    let tag: DriftTag
    let presetName: String
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xLarge) {
            // Header with name and ID
            HStack {
                Text(tag.label)
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                Spacer()

                Text("ID: \(tag.id)")
                    .bodySmall()
                    .extraSubtextColor()
            }

            // Preset info
            Text("Preset: \(presetName)")
                .body()
                .subtextColor()

            // Sync status and delete button
            HStack {
                HStack(spacing: DesignTokens.Spacing.medium) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)

                    Text("Synced")
                        .bodySmall()
                        .subtextColor()
                }

                Spacer()

                DriftButton(title: "Delete", icon: "xmark", style: .pill) {
                    onDelete()
                }
            }
        }
        .padding(DesignTokens.Padding.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Colors.whiteText)
        .cornerRadius(DesignTokens.Radii.radiusStandard)
        .shadow(
            color: DesignTokens.Shadow.color,
            radius: DesignTokens.Shadow.radius,
            x: DesignTokens.Shadow.x,
            y: DesignTokens.Shadow.y
        )
    }
}

struct PresetModeCard: View {
    let preset: FocusPreset
    let appCountText: String
    let assignedToText: String
    @Binding var presentedPreset: FocusPreset?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xLarge) {
            // Header with name and apps count
            HStack {
                Text(preset.name)
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                Spacer()

                Text(appCountText)
                    .bodySmall()
                    .extraSubtextColor()
            }

            // Assignment info and edit button
            HStack {
                Text("Assigned to: \(assignedToText)")
                    .body()
                    .subtextColor()

                Spacer()

                DriftButton(title: "Edit", icon: "pencil", style: .pill) {
                    presentedPreset = preset
                }
            }
        }
        .padding(DesignTokens.Padding.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Colors.whiteText)
        .cornerRadius(DesignTokens.Radii.radiusStandard)
        .shadow(
            color: DesignTokens.Shadow.color,
            radius: DesignTokens.Shadow.radius,
            x: DesignTokens.Shadow.x,
            y: DesignTokens.Shadow.y
        )
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xLarge) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(DesignTokens.Colors.primary)
                .frame(width: 24)
            
            Text(title)
                .body()
                .foregroundColor(DesignTokens.Colors.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .extraSubtextColor()
        }
        .padding(DesignTokens.Padding.large)
        .background(DesignTokens.Colors.whiteText)
        .cornerRadius(DesignTokens.Radii.radiusStandard)
        .shadow(
            color: DesignTokens.Shadow.color,
            radius: DesignTokens.Shadow.radius,
            x: DesignTokens.Shadow.x,
            y: DesignTokens.Shadow.y
        )
        .onTapGesture {
            if let action = action {
                action()
            } else {
                // Settings row tap placeholder
                print("\(title) tapped")
            }
        }
    }
}

#Preview {
    SettingsPage()
}
