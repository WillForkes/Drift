//
//  SettingsPage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct SettingsPage: View {
    // Mock data for drifts
    let mockDrifts = [
        DriftDevice(id: "0x13304", name: "Living Room", preset: "All", isSynced: true),
        DriftDevice(id: "0x13304", name: "Bedroom", preset: "All", isSynced: true)
    ]

    // Mock data for presets/modes
    let mockPresets = [
        PresetMode(name: "Work", appsSelected: 31, assignedTo: "Bedroom"),
        PresetMode(name: "Sleep", appsSelected: 5, assignedTo: "Bedroom"),
        PresetMode(name: "Gym", appsSelected: 31, assignedTo: "Bedroom")
    ]

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

                        ForEach(mockDrifts, id: \.id) { drift in
                            DriftCard(drift: drift)
                                .padding(.horizontal, DesignTokens.Padding.large)
                        }
                    }

                    // Modes Section
                    VStack(spacing: DesignTokens.Spacing.xLarge) {
                        Text("Modes")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignTokens.Padding.large)

                        ForEach(Array(mockPresets.enumerated()), id: \.offset) { index, preset in
                            PresetModeCard(
                                preset: preset,
                                presentedPreset: $presentedPreset
                            )
                            .padding(.horizontal, DesignTokens.Padding.large)
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

    // MARK: - Debug Methods

    private func performHardReset() {
        // Post notification to trigger app-level hard reset
        NotificationCenter.default.post(name: .hardResetRequested, object: nil)
    }
}

/// MARK: - Supporting Views

struct DriftCard: View {
    let drift: DriftDevice
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xLarge) {
            // Header with name and ID
            HStack {
                Text(drift.name)
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
                
                Text("ID: \(drift.id)")
                    .bodySmall()
                    .extraSubtextColor()
            }
            
            // Preset info
            Text("Preset: \(drift.preset)")
                .body()
                .subtextColor()
            
            // Sync status and delete button
            HStack {
                HStack(spacing: DesignTokens.Spacing.medium) {
                    Circle()
                        .fill(drift.isSynced ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(drift.isSynced ? "Synced" : "Not Synced")
                        .bodySmall()
                        .subtextColor()
                }
                
                Spacer()
                
                DriftButton(title: "Delete", icon: "xmark", style: .pill) {
                    // TODO: Implement delete drift functionality
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
    let preset: PresetMode
    @Binding var presentedPreset: FocusPreset?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xLarge) {
            // Header with name and apps count
            HStack {
                Text(preset.name)
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Spacer()
                
                Text("\(preset.appsSelected) Apps Selected")
                    .bodySmall()
                    .extraSubtextColor()
            }
            
            // Assignment info and edit button
            HStack {
                Text("Assigned to: \(preset.assignedTo)")
                    .body()
                    .subtextColor()
                
                Spacer()
                
                DriftButton(title: "Edit", icon: "pencil", style: .pill) {
                    // Edit action - open sheet
                    let focusPreset = FocusPreset(id: preset.name.lowercased(), name: preset.name)
                    presentedPreset = focusPreset
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

// MARK: - Data Models

struct DriftDevice {
    let id: String
    let name: String
    let preset: String
    let isSynced: Bool
}

struct PresetMode {
    let name: String
    let appsSelected: Int
    let assignedTo: String
}

#Preview {
    SettingsPage()
}
