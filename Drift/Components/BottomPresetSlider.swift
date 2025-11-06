//
//  BottomPresetSlider.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI
import FamilyControls

struct BottomPresetSlider: View {
    @State private var scrollPosition: String?
    @State private var showNameAlert = false
    @State private var newPresetName = ""
    @State private var showPresetSheet = false
    @State private var editingPreset: FocusPreset?
    @StateObject private var presetManager = PresetManager.shared

    var displayItems: [DisplayItem] {
        var items = presetManager.presets.map { DisplayItem.preset($0) }
        items.append(.add)
        return items
    }

    enum DisplayItem: Identifiable {
        case preset(FocusPreset)
        case add

        var id: String {
            switch self {
            case .preset(let preset):
                return preset.id
            case .add:
                return "add"
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vertical gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        DesignTokens.Colors.background,
                        DesignTokens.Colors.accent
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Scrollable carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.large) {
                        ForEach(displayItems) { item in
                            switch item {
                            case .add:
                                Button(action: { showNameAlert = true }) {
                                    AddPresetCard()
                                }
                                .buttonStyle(.plain)
                                .containerRelativeFrame(.horizontal, count: 1, spacing: DesignTokens.Spacing.large)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.75)
                                        .opacity(phase.isIdentity ? 1.0 : 0.3)
                                }
                                .shadow(
                                    color: DesignTokens.Shadow.color,
                                    radius: DesignTokens.Shadow.radius,
                                    x: DesignTokens.Shadow.x,
                                    y: DesignTokens.Shadow.y
                                )
                                .id(item.id)

                            case .preset(let preset):
                                PresetCard(title: preset.name)
                                    .containerRelativeFrame(.horizontal, count: 1, spacing: DesignTokens.Spacing.large)
                                    .scrollTransition { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1.0 : 0.75)
                                            .opacity(phase.isIdentity ? 1.0 : 0.3)
                                    }
                                    .shadow(
                                        color: DesignTokens.Shadow.color,
                                        radius: DesignTokens.Shadow.radius,
                                        x: DesignTokens.Shadow.x,
                                        y: DesignTokens.Shadow.y
                                    )
                                    .id(item.id)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollPosition)
                .onChange(of: scrollPosition) { oldValue, newValue in
                    // Don't process selection if user scrolled to the "add" card
                    guard newValue != "add" else {
                        print("ℹ️ [BottomPresetSlider] Scrolled to Add card - no preset selection")
                        return
                    }
                    handlePresetSelection(newValue)
                }
                .safeAreaPadding(.horizontal, (geometry.size.width * 0.8) / 2 - 40)
                .frame(width: geometry.size.width * 0.8)
                .mask(
                    HStack(spacing: 0) {
                        // Left fade
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 60)

                        // Center (no fade)
                        Rectangle()

                        // Right fade
                        LinearGradient(
                            colors: [.black, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 60)
                    }
                )
            }
        }
        .frame(height: 80)
        .onAppear {
            // Initialize scroll position to first preset or stored selection
            if let storedPresetId = UserDefaults.standard.string(forKey: "currentSelectedPresetId"),
               presetManager.getPreset(id: storedPresetId) != nil {
                scrollPosition = storedPresetId
            } else if let firstPreset = presetManager.presets.first {
                scrollPosition = firstPreset.id
                UserDefaults.standard.set(firstPreset.id, forKey: "currentSelectedPresetId")
            }
        }
        .alert("New Mode", isPresented: $showNameAlert) {
            TextField("Mode name", text: $newPresetName)
            Button("Cancel", role: .cancel) {
                newPresetName = ""
            }
            Button("Create") {
                createPreset()
            }
        } message: {
            Text("Enter a name for your new focus mode")
        }
        .sheet(isPresented: $showPresetSheet) {
            if let preset = editingPreset,
               let index = presetManager.presets.firstIndex(where: { $0.id == preset.id }) {
                PresetEditSheet(
                    preset: Binding(
                        get: { presetManager.presets[index] },
                        set: { presetManager.presets[index] = $0 }
                    ),
                    isPresented: $showPresetSheet
                )
            }
        }
    }

    private func createPreset() {
        guard !newPresetName.isEmpty else { return }

        do {
            let preset = try presetManager.createPreset(name: newPresetName, selection: FamilyActivitySelection(), blocksAllApps: false)
            editingPreset = preset
            showPresetSheet = true
            newPresetName = ""

            // Scroll to the newly created preset
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                scrollPosition = preset.id
            }
        } catch {
            print("❌ [BottomPresetSlider] Error creating preset: \(error)")
        }
    }

    private func handlePresetSelection(_ presetId: String?) {
        guard let presetId = presetId,
              presetId != "add",
              presetManager.getPreset(id: presetId) != nil else {
            return
        }

        // Store the selected preset ID in UserDefaults for app-wide access
        UserDefaults.standard.set(presetId, forKey: "currentSelectedPresetId")
        print("✅ [BottomPresetSlider] Selected preset: \(presetId)")
    }
}

// MARK: - Preset Card Component

struct PresetCard: View {
    let title: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.Radii.radiusStandard)
                .fill(DesignTokens.Colors.whiteText)
                .frame(width: 80, height: 80)

            Text(title)
                .bodySmall()
                .foregroundColor(DesignTokens.Colors.textPrimary)
        }
    }
}

// MARK: - Add Preset Card Component

struct AddPresetCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.Radii.radiusStandard)
                .fill(DesignTokens.Colors.whiteText)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .frame(width: 80, height: 80)


            Image(systemName: "plus")
                .font(.system(size: 24))
                .foregroundColor(DesignTokens.Colors.textPrimary)
        }
    }
}

#Preview {
    BottomPresetSlider()
}
