//
//  HomeTest.swift
//  Drift
//
//  Created by Claude Code on 27/10/2025.
//

import SwiftUI

struct HomeTest: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                // Main Content - Centered in screen
                VStack(spacing: DesignTokens.Spacing.xLarge) {
                    // Pill Badge with "drifting" text
                    PillBadge(text: "drifting")

                    // Heading text
                    Text("Tap drift to activate")
                        .heading1()
                        .foregroundColor(DesignTokens.Colors.textPrimary)

                    // Square Image (60% of screen width)
                    PlaceholderImage()
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                }
                .padding(.large) // Large padding from edges

                // Slide Indicator - Fixed at top
                VStack {
                    SlideIndicator(currentPage: 1) // Middle page (0-indexed: 0, 1, 2)
                        .padding(.top, DesignTokens.Spacing.xxLarge)

                    Spacer()
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

#Preview {
    HomeTest()
}
