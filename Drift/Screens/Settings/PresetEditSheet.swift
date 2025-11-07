//
//  PresetEditSheet.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI
import FamilyControls

struct PresetEditSheet: View {
    let presetId: String
    let onDismiss: () -> Void

    @ObservedObject private var presetManager = PresetManager.shared
    @ObservedObject private var driftManager = DriftTagManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var editingName: String = ""
    @State private var editingEmoji: String = "⚡️"
    @State private var previousValidEmoji: String = "⚡️"
    @State private var editingSelection: FamilyActivitySelection = FamilyActivitySelection()
    @State private var showError = false
    @State private var errorMessage = ""

    init(presetId: String, onDismiss: @escaping () -> Void) {
        self.presetId = presetId
        self.onDismiss = onDismiss
    }

    var assignedDriftName: String {
        let drifts = driftManager.tags.filter { $0.presetId == presetId }
        if let firstDrift = drifts.first {
            return firstDrift.label
        }
        return "Not assigned"
    }

    var selectedCountText: String {
        // Use the shared extension method by creating a temporary preset
        FocusPreset(
            id: presetId,
            name: editingName,
            selection: editingSelection,
            blocksAllApps: false
        ).appCountText
    }
    
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle bar
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.black)
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)

                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xxxLarge) {
                        // Header Section
                        VStack(spacing: DesignTokens.Spacing.xLarge) {
                            HStack {
                                // Emoji selector
                                TextField("", text: $editingEmoji)
                                    .font(.system(size: 40))
                                    .multilineTextAlignment(.center)
                                    .frame(width: 60, height: 60)
                                    .background(DesignTokens.Colors.whiteText)
                                    .cornerRadius(DesignTokens.Radii.radiusSmall)
                                    .onChange(of: editingEmoji) { newValue in
                                        // Filter to only allow emojis and limit to 1 character
                                        let emojis = newValue.filter { $0.isEmoji }
                                        if let firstEmoji = emojis.first {
                                            // Keep only the first emoji
                                            let singleEmoji = String(firstEmoji)
                                            if newValue != singleEmoji {
                                                editingEmoji = singleEmoji
                                            }
                                            previousValidEmoji = singleEmoji
                                        } else if !newValue.isEmpty {
                                            // No valid emoji found, revert to previous valid value
                                            DispatchQueue.main.async {
                                                editingEmoji = previousValidEmoji
                                            }
                                        }
                                    }

                                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                                    Text("Editing Mode")
                                        .bodySmall()
                                        .extraSubtextColor()

                                    TextField("Mode name", text: $editingName)
                                        .font(.custom(DesignTokens.Typography.fontFamily, size: DesignTokens.Typography.Size.heading1))
                                        .foregroundColor(DesignTokens.Colors.textPrimary)
                                }

                                Spacer()

                                DriftButton(title: "Save", style: .pill) {
                                    savePreset()
                                }
                            }
                            .padding(.horizontal, DesignTokens.Padding.large)

                            // Device Assignment Card
                            DeviceAssignmentCard(
                                driftName: assignedDriftName,
                                selectedCountText: selectedCountText
                            )
                            .padding(.horizontal, DesignTokens.Padding.large)
                        }
                        
                        // Select Apps Section
                        VStack(spacing: DesignTokens.Spacing.xLarge) {
                            // Section Header
                            HStack {
                                Text("Select Apps")
                                    .heading1()
                                    .foregroundColor(DesignTokens.Colors.textPrimary)

                                Spacer()
                            }
                            .padding(.horizontal, DesignTokens.Padding.large)

                            // FamilyActivityPicker
                            FamilyActivityPicker(selection: $editingSelection)
                                .preferredColorScheme(.light)
                                .frame(height: 400)
                                .padding(.horizontal, DesignTokens.Padding.large)

                            // Bottom spacing
                            Spacer()
                                .frame(height: DesignTokens.Spacing.xxxLarge)
                        }
                    }
                    .padding(.top, DesignTokens.Spacing.xLarge)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadPreset()
        }
    }

    private func loadPreset() {
        if let preset = presetManager.getPreset(id: presetId) {
            editingName = preset.name
            editingEmoji = preset.emoji
            previousValidEmoji = preset.emoji
            editingSelection = preset.selection
            print("✅ [PresetEditSheet] Loaded preset: \(preset.name) \(preset.emoji)")
        } else {
            print("❌ [PresetEditSheet] Failed to load preset with ID: \(presetId)")
            errorMessage = "Preset not found"
            showError = true
        }
    }

    private func savePreset() {
        do {
            // Update preset with name, emoji, and selection
            try presetManager.updatePreset(
                id: presetId,
                name: editingName,
                emoji: editingEmoji,
                selection: editingSelection
            )

            print("✅ [PresetEditSheet] Saved preset: \(editingName) \(editingEmoji)")
            onDismiss()
            dismiss()

        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Supporting Views

struct DeviceAssignmentCard: View {
    let driftName: String
    let selectedCountText: String

    var body: some View {
        HStack {
            Text(driftName)
                .body()
                .foregroundColor(DesignTokens.Colors.textPrimary)

            Spacer()

            Text(selectedCountText)
                .bodySmall()
                .extraSubtextColor()
        }
        .padding(DesignTokens.Padding.large)
        .cardBackground()
    }
}

// MARK: - Character Extension

extension Character {
    /// Check if character is an emoji
    var isEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && (firstScalar.value >= 0x1F000 || unicodeScalars.count > 1)
    }
}
