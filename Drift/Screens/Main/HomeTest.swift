//
//  HomeTest.swift
//  Drift
//
//  Created by Claude Code on 27/10/2025.
//

import SwiftUI

struct HomeTest: View {
    let imageSize = UIScreen.main.bounds.width * 0.6
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                // Main Content - Image centered, text above
                VStack(spacing: DesignTokens.Spacing.xLarge) {
                    // Pill Badge with "drifting" text
                    PillBadge(text: "drifting")

                    // Heading text
                    Text("Tap drift to activate")
                        .heading1()
                        .foregroundColor(DesignTokens.Colors.textPrimary)

                    Spacer()
                        .frame(height: DesignTokens.Spacing.xxxLarge)

                    // Square Image - Centered
                    Image("above")
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                }
                .padding(.large) // Large padding from edges
                .offset(y: -30) // Adjust to center the image on screen

                // Slide Indicator - Fixed at top
                VStack {
                    SlideIndicator(currentPage: 1) // Middle page (0-indexed: 0, 1, 2)
                        .padding(.top, DesignTokens.Spacing.xxLarge)

                    Spacer()
                }

                // Bottom Preset Slider - Fixed at bottom
                VStack {
                    Spacer()
                    BottomPresetSlider()
                }
            }
        }
    }
}

// MARK: - Pill Badge Component

struct PillBadge: View {
    let text: String

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.large) {
            // Red circle indicator (4x4)
            Circle()
                .fill(Color.red)
                .frame(width: 5, height: 5)

            // Text
            Text(text)
                .bodySmall()
                .foregroundColor(DesignTokens.Colors.textPrimary)
        }
        .padding(.horizontal, DesignTokens.Padding.large)
        .padding(.vertical, DesignTokens.Padding.medium)
        .background(DesignTokens.Colors.whiteText)
        .cornerRadius(DesignTokens.Radii.radiusStandard)
    }
}

// MARK: - Placeholder Image

struct PlaceholderImage: View {
    var body: some View {
        // Placeholder for the actual image
        RoundedRectangle(cornerRadius: DesignTokens.Radii.radiusStandard)
            .fill(DesignTokens.Colors.accent.opacity(0.3))
            .overlay(
                Text("Image")
                    .body()
                    .subtextColor()
            )
    }
}

// MARK: - Slide Indicator Component

struct SlideIndicator: View {
    let currentPage: Int
    let totalPages: Int = 3
    let inactiveWidth: CGFloat = 32
    let activeWidthMultiplier: CGFloat = 2.0
    let height: CGFloat = 6

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.large) {
            ForEach(0..<totalPages, id: \.self) { index in
                RoundedRectangle(cornerRadius: DesignTokens.Radii.radiusStandard)
                    .fill(index == currentPage ?
                          DesignTokens.Colors.accent :
                          DesignTokens.Colors.accent.opacity(0.5))
                    .frame(
                        width: index == currentPage ? inactiveWidth * activeWidthMultiplier : inactiveWidth,
                        height: height
                    )
            }
        }
    }
}

// MARK: - Bottom Preset Slider Component

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
    HomeTest()
}
