//
//  SettingsPage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct SettingsPage: View {
    @ObservedObject private var driftManager = DriftTagManager.shared
    @ObservedObject private var presetManager = PresetManager.shared
    @State private var editingPresetId: PresetIdentifier?
    @State private var showAddDriftSheet = false

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignTokens.Spacing.xxxLarge) {
                    // Your drift's Section
                    VStack(spacing: DesignTokens.Spacing.xLarge) {
                        HStack {
                            Text("Your drift's")
                                .heading1()
                                .foregroundColor(DesignTokens.Colors.textPrimary)

                            Spacer()

                            DriftButton(title: "New Drift", icon: "plus", style: .pillTertiary) {
                                showAddDriftSheet = true
                            }
                        }
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
                                    appCountText: preset.appCountText,
                                    assignedToText: getDriftCount(for: preset.id),
                                    editingPresetId: $editingPresetId
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
        .sheet(item: $editingPresetId) { identifier in
            PresetEditSheet(
                presetId: identifier.id,
                onDismiss: { editingPresetId = nil }
            )
        }
        .sheet(isPresented: $showAddDriftSheet) {
            OnboardingFlow(isAddingAnotherDrift: true) {
                showAddDriftSheet = false
            }
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
                // Preset info
                HStack(spacing: DesignTokens.Spacing.large) {
                    Circle()
                        .fill(DesignTokens.Colors.primary)
                        .frame(width: 8, height: 8)

                    Text(tag.label)
                        .heading2()
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                }
                
                Spacer()

                Image("above")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
            }



            // Sync status and delete button
            HStack {
                Text("Preset: '\(presetName)'")
                    .bodySmall()
                    .subtextColor()

                Spacer()

                Text("ID: \(tag.id)")
                    .bodySmall()
                    .extraSubtextColor()
                
//                DriftButton(title: "Delete", icon: "xmark", style: .pillTertiary) {
//                    onDelete()
//                }
            }
        }
        .padding(DesignTokens.Padding.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
    }
}

struct PresetModeCard: View {
    let preset: FocusPreset
    let appCountText: String
    let assignedToText: String
    @Binding var editingPresetId: PresetIdentifier?

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
                    editingPresetId = PresetIdentifier(id: preset.id)
                }
            }
        }
        .padding(DesignTokens.Padding.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardBackground()
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
        .cardBackground()
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
    // Setup preview with dummy data
    let tagManager = DriftTagManager.shared
    let presetManager = PresetManager.shared

    // Clear existing data
    tagManager.tags.removeAll()
    presetManager.presets.removeAll()

    // Add 2 dummy drifts
    tagManager.registerTag(id: "0001", label: "Kitchen Drift", presetId: "preset-work")
    tagManager.registerTag(id: "0002", label: "Bedroom Drift", presetId: "preset-deep-focus")

    // Add 3 dummy presets
    let workPreset = FocusPreset(id: "preset-work", name: "Work Mode", blocksAllApps: false)
    let deepFocusPreset = FocusPreset(id: "preset-deep-focus", name: "Deep Focus", blocksAllApps: false)
    let allPreset = FocusPreset(id: "preset-all", name: "All Apps", blocksAllApps: true)

    presetManager.presets = [workPreset, deepFocusPreset, allPreset]

    return SettingsPage()
}
