//
//  BottomPresetSlider.swift
//  Drift
//
//

import SwiftUI
import FamilyControls

struct BottomPresetSlider: View {
    @Binding var selectedDriftId: String?
    @State private var scrollPosition: String?
    @State private var scrollWorkItem: DispatchWorkItem?
    @State private var showNameAlert = false
    @State private var newPresetName = ""
    @State private var editingPresetId: PresetIdentifier?
    @ObservedObject private var presetManager = PresetManager.shared
    @ObservedObject private var driftManager = DriftTagManager.shared

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
                LinearGradient(
                    gradient: Gradient(colors: [
                        DesignTokens.Colors.background,
                        DesignTokens.Colors.accent
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

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
                                .cardShadow()
                                .id(item.id)

                            case .preset(let preset):
                                PresetCard(
                                    title: preset.name,
                                    isActive: isPresetActive(preset)
                                )
                                .containerRelativeFrame(.horizontal, count: 1, spacing: DesignTokens.Spacing.large)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1.0 : 0.75)
                                        .opacity(phase.isIdentity ? 1.0 : 0.3)
                                }
                                .cardShadow()
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
                .onChange(of: selectedDriftId) { oldValue, newValue in
                    guard let driftId = newValue,
                          let drift = driftManager.getTag(by: driftId),
                          presetManager.getPreset(id: drift.presetId) != nil else {
                        return
                    }

                    withAnimation(.easeInOut(duration: 0.3)) {
                        scrollPosition = drift.presetId
                    }
                }
                .safeAreaPadding(.horizontal, (geometry.size.width * 0.8) / 2 - 40)
                .frame(width: geometry.size.width * 0.8)
                .mask(
                    HStack(spacing: 0) {
                        LinearGradient(colors: [.clear, .black], startPoint: .leading, endPoint: .trailing)
                            .frame(width: 60)
                        Rectangle()
                        LinearGradient(colors: [.black, .clear], startPoint: .leading, endPoint: .trailing)
                            .frame(width: 60)
                    }
                )
            }
        }
        .frame(height: 80)
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
        .sheet(item: $editingPresetId) { identifier in
            PresetEditSheet(
                presetId: identifier.id,
                onDismiss: { editingPresetId = nil }
            )
        }
        .onDisappear {
            scrollWorkItem?.cancel()
        }
    }

    private func createPreset() {
        guard !newPresetName.isEmpty else { return }

        do {
            let preset = try presetManager.createPreset(name: newPresetName, selection: FamilyActivitySelection(), blocksAllApps: false)
            editingPresetId = PresetIdentifier(id: preset.id)
            newPresetName = ""

            scrollWorkItem?.cancel()
            let workItem = DispatchWorkItem {
                scrollPosition = preset.id
            }
            scrollWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        } catch {
            print("❌ [BottomPresetSlider] Error creating preset: \(error)")
        }
    }

    private func handlePresetSelection(_ presetId: String?) {
        guard let presetId = presetId,
              presetManager.getPreset(id: presetId) != nil else {
            return
        }

        presetManager.setCurrentPreset(presetId)

        // auto-link to the currently selected drift
        if let driftId = selectedDriftId {
            driftManager.updateDriftPreset(driftId: driftId, presetId: presetId)
        }
    }

    private func isPresetActive(_ preset: FocusPreset) -> Bool {
        guard let driftId = selectedDriftId,
              let drift = driftManager.getTag(by: driftId) else {
            return false
        }
        return drift.presetId == preset.id
    }
}

// MARK: - Preset Card Component

struct PresetCard: View {
    let title: String
    let isActive: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.Radii.radiusStandard)
                .fill(DesignTokens.Colors.whiteText)
                .frame(width: 80, height: 80)

            Text(title)
                .bodySmall()
                .foregroundColor(DesignTokens.Colors.textPrimary)
        }
        .overlay(alignment: .topTrailing) {
            if isActive {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .offset(x: -6, y: 6)
            }
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
    @Previewable @State var selectedDriftId: String? = nil
    BottomPresetSlider(selectedDriftId: $selectedDriftId)
}
