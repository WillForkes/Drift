//
//  PillBadge.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct PillBadge: View {
    let text: String

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.large) {
            // Red circle indicator (5x5)
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

#Preview {
    PillBadge(text: "drifting")
}
