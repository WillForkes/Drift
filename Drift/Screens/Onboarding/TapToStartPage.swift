//
//  TapToStartPage.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct TapToStartPage: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // Heading Section - Fixed 80px from top
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        Text("Let's Get Started")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Start by tapping your phone onto drift")
                            .heading2()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 80)
                    .frame(maxWidth: .infinity)

                    Spacer()
                }

                // Image - Absolute vertical center (dead center)
                Image("above")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                // Pill badge - positioned below center image
                PillBadge(
                    text: "Waiting for tap",
                    icon: .circle(color: .red, size: 12),
                    style: .light
                )
                .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) + 100 + 60)

                // Bottom button - Fixed distance from bottom
                VStack {
                    Spacer()

                    Button(action: {
                        print("I don't have a drift tapped")
                    }) {
                        HStack(spacing: DesignTokens.Spacing.medium) {
                            Text("I don't have a drift")
                                .bodySmall()
                                .foregroundColor(DesignTokens.Colors.extraSubtext)

                            Image(systemName: "questionmark.circle")
                                .font(.system(size: DesignTokens.Typography.Size.bodySmall))
                                .foregroundColor(DesignTokens.Colors.extraSubtext)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    TapToStartPage()
}
