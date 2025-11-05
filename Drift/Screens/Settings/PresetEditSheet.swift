//
//  PresetEditSheet.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI
import FamilyControls

struct PresetEditSheet: View {
    @Binding var preset: FocusPreset
    @Binding var isPresented: Bool

    @StateObject private var presetManager = PresetManager.shared
    @StateObject private var driftManager = DriftTagManager.shared

    @State private var editingName: String
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var includeMode: Bool = true // For future use

    init(preset: Binding<FocusPreset>, isPresented: Binding<Bool>) {
        self._preset = preset
        self._isPresented = isPresented
        self._editingName = State(initialValue: preset.wrappedValue.name)
    }

    var selectedCount: Int {
        return preset.selection.applicationTokens.count
    }

    var assignedDriftName: String {
        let drifts = driftManager.tags.filter { $0.presetId == preset.id }
        if let firstDrift = drifts.first {
            return firstDrift.label
        }
        return "Not assigned"
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
                                selectedCount: selectedCount
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
                            FamilyActivityPicker(selection: $preset.selection)
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
    }

    private func savePreset() {
        do {
            // Update name if changed
            if editingName != preset.name {
                try presetManager.renamePreset(id: preset.id, newName: editingName)
                preset = FocusPreset(
                    id: preset.id,
                    name: editingName,
                    selection: preset.selection,
                    blocksAllApps: preset.blocksAllApps
                )
            }

            // Update selection (already bound to preset.selection, so it's automatically updated)
            try presetManager.updatePreset(
                id: preset.id,
                name: editingName,
                selection: preset.selection
            )

            print("✅ [PresetEditSheet] Saved preset: \(editingName)")
            isPresented = false

        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Supporting Views

struct DeviceAssignmentCard: View {
    let driftName: String
    let selectedCount: Int

    var body: some View {
        HStack {
            Text(driftName)
                .body()
                .foregroundColor(DesignTokens.Colors.textPrimary)

            Spacer()

            Text("\(selectedCount) Selected Apps")
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

// MARK: - Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    PresetEditSheet(
        preset: .constant(FocusPreset(id: "testing", name: "Testing")),
        isPresented: .constant(true)
    )
}
