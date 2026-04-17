//
//  DriftSelector.swift
//  Drift
//
//  Created by William Forkes on 06/11/2025.
//

import SwiftUI

struct DriftSelector: View {
    @ObservedObject private var driftManager = DriftTagManager.shared
    @Binding var selectedDriftId: String?

    @State private var showDropdown = false

    var body: some View {
        ZStack {
            pillBadgeView
                .onTapGesture {
                    if driftManager.tags.count > 1 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showDropdown.toggle()
                        }
                    }
                }

            if showDropdown && driftManager.tags.count > 1 {
                dropdownMenu
            }
        }
    }

    // MARK: - Pill Badge View

    private var pillBadgeView: some View {
        HStack(spacing: DesignTokens.Spacing.large) {
            Circle()
                .fill(Color.red)
                .frame(width: 5, height: 5)

            Text(selectedDriftName)
                .bodySmall()
                .foregroundColor(DesignTokens.Colors.textPrimary)

            if driftManager.tags.count > 1 {
                Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                    .bodySmall()
                    .foregroundColor(DesignTokens.Colors.subtext)
            }
        }
        .padding(.horizontal, DesignTokens.Padding.large)
        .padding(.vertical, DesignTokens.Padding.medium)
        .background(DesignTokens.Colors.whiteText)
        .cornerRadius(DesignTokens.Radii.radiusStandard)
    }

    // MARK: - Dropdown Menu

    private var dropdownMenu: some View {
        ZStack(alignment: .top) {
            // nearly-invisible tap target to dismiss
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showDropdown = false
                    }
                }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(driftManager.tags) { drift in
                    dropdownItem(for: drift)
                }
            }
            .background(DesignTokens.Colors.whiteText)
            .cornerRadius(DesignTokens.Radii.radiusStandard)
            .shadow(
                color: DesignTokens.Shadow.color,
                radius: DesignTokens.Shadow.radius * 1.5,
                x: DesignTokens.Shadow.x,
                y: DesignTokens.Shadow.y
            )
            .padding(.top, 50)
        }
    }

    // MARK: - Dropdown Item

    private func dropdownItem(for drift: DriftTag) -> some View {
        HStack {
            Text(drift.label)
                .bodySmall()
                .foregroundColor(DesignTokens.Colors.textPrimary)

            Spacer()

            if drift.id == selectedDriftId {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(DesignTokens.Colors.primary)
            }
        }
        .padding(.horizontal, DesignTokens.Padding.large)
        .padding(.vertical, DesignTokens.Padding.medium)
        .background(
            drift.id == selectedDriftId
                ? DesignTokens.Colors.background.opacity(0.5)
                : Color.clear
        )
        .contentShape(Rectangle())
        .onTapGesture {
            selectedDriftId = drift.id
            withAnimation(.easeInOut(duration: 0.2)) {
                showDropdown = false
            }
        }
    }

    // MARK: - Helpers

    private var selectedDriftName: String {
        guard let id = selectedDriftId,
              let drift = driftManager.getTag(by: id) else {
            return "Drift Name"
        }
        return drift.label
    }
}

#Preview {
    @Previewable @State var selectedId: String? = nil

    VStack(spacing: 40) {
        Text("Preview: DriftSelector")
            .font(.headline)

        DriftSelector(selectedDriftId: $selectedId)

        Text("Selected: \(selectedId ?? "None")")
            .font(.caption)
    }
    .padding()
    .background(DesignTokens.Colors.background)
}
