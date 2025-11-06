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
    @Binding var isPresented: Bool
    let onDismiss: () -> Void

    @StateObject private var presetManager = PresetManager.shared
    @StateObject private var driftManager = DriftTagManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var editingName: String = ""
    @State private var editingSelection: FamilyActivitySelection = FamilyActivitySelection()
    @State private var showError = false
    @State private var errorMessage = ""

    init(presetId: String, isPresented: Binding<Bool>, onDismiss: @escaping () -> Void = {}) {
        self.presetId = presetId
        self._isPresented = isPresented
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
        let appCount = editingSelection.applicationTokens.count
        let categoryCount = editingSelection.categoryTokens.count

        if appCount > 0 && categoryCount > 0 {
            let appText = appCount == 1 ? "app" : "apps"
            let categoryText = categoryCount == 1 ? "category" : "categories"
            return "\(appCount) \(appText), \(categoryCount) \(categoryText)"
        } else if categoryCount > 0 {
            let categoryText = categoryCount == 1 ? "category" : "categories"
            return "\(categoryCount) \(categoryText)"
        } else if appCount > 0 {
            let appText = appCount == 1 ? "app" : "apps"
            return "\(appCount) \(appText)"
        } else {
            return "No apps"
        }
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
            editingSelection = preset.selection
            print("✅ [PresetEditSheet] Loaded preset: \(preset.name)")
        } else {
            print("❌ [PresetEditSheet] Failed to load preset with ID: \(presetId)")
            errorMessage = "Preset not found"
            showError = true
        }
    }

    private func savePreset() {
        do {
            // Update preset with both name and selection
            try presetManager.updatePreset(
                id: presetId,
                name: editingName,
                selection: editingSelection
            )

            print("✅ [PresetEditSheet] Saved preset: \(editingName)")
            dismiss()
            onDismiss()

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

#Preview {
    PresetEditSheet(
        presetId: "testing",
        isPresented: .constant(true)
    )
}
