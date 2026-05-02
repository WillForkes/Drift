//
//  PillBadge.swift
//  Drift
//
//

import SwiftUI

struct PillBadge: View {
    let text: String
    let iconColor: Color
    let iconSize: CGFloat

    init(text: String, iconColor: Color = .red, iconSize: CGFloat = 5) {
        self.text = text
        self.iconColor = iconColor
        self.iconSize = iconSize
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.large) {
            Circle()
                .fill(iconColor)
                .frame(width: iconSize, height: iconSize)

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
    VStack(spacing: 20) {
        PillBadge(text: "Drift Name")
        PillBadge(text: "Synced", iconColor: .green, iconSize: 8)
        PillBadge(text: "Warning", iconColor: .yellow, iconSize: 8)
    }
    .padding()
    .background(DesignTokens.Colors.background)
}
