//
//  SyncedWelcomePage.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct SyncedWelcomePage: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxxLarge) {
            Spacer()

            VStack(spacing: DesignTokens.Spacing.large) {
                Text("Synced!")
                    .heading1()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Let's start focusing.")
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.subtext)
            }

            Spacer()

            // Drift device image
            Image("above")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)

            Spacer()

            DriftButton(title: "Get Started", style: .primary) {
                print("Get Started tapped")
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SyncedWelcomePage()
}
