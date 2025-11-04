//
//  HomePage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct HomePage: View {
    let imageSize = UIScreen.main.bounds.width * 0.6

    var body: some View {
        ZStack {
            // Background
            DesignTokens.Colors.background
                .ignoresSafeArea()

            // Main Content - Image centered, text above (ignores top safe area to stay centered)
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
            .padding(.large)
            .offset(y: -30)
            .ignoresSafeArea(.container, edges: .top)

            // Bottom Preset Slider - Fixed at bottom
            VStack {
                Spacer()
                BottomPresetSlider()
            }
        }
    }
}

#Preview {
    HomePage()
}
