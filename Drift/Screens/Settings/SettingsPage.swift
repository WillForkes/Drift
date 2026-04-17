//
//  SettingsPage.swift
//  Drift
//
//  Created by William Forkes on 28/10/2025.
//

import SwiftUI

struct SettingsPage: View {
    @ObservedObject private var driftManager = DriftTagManager.shared
    @ObservedObject private var presetManager = PresetManager.shared
    @State private var editingPresetId: PresetIdentifier?
    @State private var showAddDriftSheet = false
    @State private var activeSettingsSheet: SettingsSheetType?
    @Environment(\.openURL) var openURL

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignTokens.Spacing.xxxLarge) {
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

                    VStack(spacing: DesignTokens.Spacing.xLarge) {
                        Text("Presets")
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

                    VStack(spacing: DesignTokens.Spacing.xLarge) {
                        Text("Privacy & Settings")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignTokens.Padding.large)

                        VStack(spacing: DesignTokens.Spacing.large) {
                            SettingsRow(
                                title: "Privacy Policy",
                                icon: "hand.raised.fill",
                                action: openPrivacyPolicy
                            )
                            SettingsRow(
                                title: "Terms of Service",
                                icon: "doc.text.fill",
                                action: openTermsOfService
                            )
                            SettingsRow(
                                title: "Notifications",
                                icon: "bell.fill",
                                action: { activeSettingsSheet = .notifications }
                            )
                            SettingsRow(
                                title: "Troubleshooting",
                                icon: "wrench.and.screwdriver.fill",
                                action: { activeSettingsSheet = .troubleshooting }
                            )
                            SettingsRow(
                                title: "About Drift",
                                icon: "info.circle.fill",
                                action: { activeSettingsSheet = .about }
                            )
                            SettingsRow(
                                title: "Contact Support",
                                icon: "questionmark.circle.fill",
                                action: { activeSettingsSheet = .contactSupport }
                            )
                            SettingsRow(
                                title: "Get a new drift",
                                icon: "cart.fill",
                                action: openGetNewDrift
                            )
                        }
                        .padding(.horizontal, DesignTokens.Padding.large)
                    }

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
        .sheet(item: $activeSettingsSheet) { sheetType in
            SettingsDetailSheet(
                sheetType: sheetType,
                onDismiss: { activeSettingsSheet = nil }
            )
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

    // MARK: - URL Actions

    private func openPrivacyPolicy() {
        if let url = URL(string: "https://example.com/privacy") {
            openURL(url)
        }
    }

    private func openTermsOfService() {
        if let url = URL(string: "https://example.com/terms") {
            openURL(url)
        }
    }

    private func openGetNewDrift() {
        if let url = URL(string: "https://get-drift.app") {
            openURL(url)
        }
    }

    // MARK: - Debug Methods

    private func performHardReset() {
        NotificationCenter.default.post(name: .hardResetRequested, object: nil)
    }
}

// MARK: - Supporting Views

struct DriftCard: View {
    let tag: DriftTag
    let presetName: String
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xLarge) {
            HStack {
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
            HStack {
                Text(preset.emoji)
                    .heading2()
            
                Text(preset.name)
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                Spacer()

                Text(appCountText)
                    .bodySmall()
                    .extraSubtextColor()
            }

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
                print("\(title) tapped")
            }
        }
    }
}

#Preview {
    let tagManager = DriftTagManager.shared
    let presetManager = PresetManager.shared

    tagManager.tags.removeAll()
    presetManager.presets.removeAll()

    tagManager.registerTag(id: "0001", label: "Kitchen Drift", presetId: "preset-work")
    tagManager.registerTag(id: "0002", label: "Bedroom Drift", presetId: "preset-deep-focus")

    let workPreset = FocusPreset(id: "preset-work", name: "Work Mode", emoji: "💼", blocksAllApps: false)
    let deepFocusPreset = FocusPreset(id: "preset-deep-focus", name: "Deep Focus", emoji: "🧠", blocksAllApps: false)
    let allPreset = FocusPreset(id: "preset-all", name: "All Apps", emoji: "🚫", blocksAllApps: true)

    presetManager.presets = [workPreset, deepFocusPreset, allPreset]

    return SettingsPage()
}
