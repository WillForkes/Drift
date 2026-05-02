//
//  WelcomePage.swift
//  Drift
//
//

import SwiftUI

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxxLarge) {
            Spacer()

            VStack(spacing: DesignTokens.Spacing.large) {
                Text("Welcome to")
                    .heading1()
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                Text("drift")
                    .headingXL()
                    .foregroundColor(DesignTokens.Colors.primary)
            }

            Spacer()

            HStack(spacing: DesignTokens.Spacing.medium) {
                Text("Swipe to get started")
                    .bodySmall()
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                Image(systemName: "arrow.right")
                    .font(.system(size: DesignTokens.Typography.Size.bodySmall))
                    .foregroundColor(DesignTokens.Colors.textPrimary)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WelcomePage()
}
