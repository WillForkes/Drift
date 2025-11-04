//
//  TapToStartPage.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct TapToStartPage: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxxLarge) {
            Spacer()

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

            Spacer()

            // Drift device in perspective view
            Image("above")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)

            Spacer()

            PillBadge(
                text: "Waiting for tap",
                icon: .circle(color: .red, size: 12),
                style: .light
            )

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TapToStartPage()
}
