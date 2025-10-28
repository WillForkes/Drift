//
//  BottomPresetSlider.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct BottomPresetSlider: View {
    @State private var scrollPosition: Int? = 0
    let presets = ["Work", "Sleep", "Gym", "Poo", "Add"]

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
                        ForEach(Array(presets.enumerated()), id: \.offset) { index, preset in
                            if preset == "Add" {
                                AddPresetCard()
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
                                    .id(index)
                            } else {
                                PresetCard(title: preset)
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
                                    .id(index)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollPosition)
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
