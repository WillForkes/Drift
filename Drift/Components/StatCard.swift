//
//  StatCard.swift
//  Drift
//
//

import SwiftUI

struct StatCard<Content: View>: View {
    let icon: String
    let title: String
    let content: Content

    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xLarge) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(DesignTokens.Colors.primary)

            content

            Text(title)
                .body()
                .foregroundColor(DesignTokens.Colors.textPrimary)

        }
        .padding(DesignTokens.Padding.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cardBackground()
    }
}

#Preview {
    StatCard(icon: "flame.fill", title: "Current Streak") {
        Text("7 days")
            .body()
            .foregroundColor(DesignTokens.Colors.textPrimary)
    }
    .frame(width: 150, height: 150)
    .padding()
}
