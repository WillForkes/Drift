//
//  SyncingPage.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct SyncingPage: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxxLarge) {
            Spacer()
            
            VStack (spacing: DesignTokens.Spacing.medium) {
                Text("Syncing...")
                    .heading1()
                    .foregroundColor(DesignTokens.Colors.whiteText)
                Text("Please wait for the sync to finish")
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.whiteText)
            }
            Spacer()

            // Drift device image
            Image("above")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)

            Spacer()

            VStack(spacing: DesignTokens.Spacing.large) {
                PillBadge(
                    text: "NFC Chip valid",
                    icon: .systemImage(name: "checkmark", color: .green, size: 14),
                    style: .light
                )

                PillBadge(
                    text: "Authorizing",
                    icon: .circle(color: .yellow, size: 12),
                    style: .transparent
                )

                PillBadge(
                    text: "Finishing up...",
                    icon: .systemImage(name: "arrow.clockwise", color: .white.opacity(0.7), size: 12),
                    style: .transparent
                )
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SyncingPage()
        .background(DesignTokens.Colors.primary)
}
