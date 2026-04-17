//
//  ViewAllButton.swift
//  Drift
//
//  Created by William Forkes on 28/10/2025.
//

import SwiftUI

struct ViewAllButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.large) {
                Text("View All")
                    .bodySmall()
                    .foregroundColor(DesignTokens.Colors.whiteText)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(DesignTokens.Colors.whiteText)
            }
            .padding(.horizontal, DesignTokens.Padding.large)
            .padding(.vertical, DesignTokens.Padding.medium)
            .background(DesignTokens.Colors.textPrimary)
            .cornerRadius(DesignTokens.Radii.radiusStandard)
        }
    }
}

#Preview {
    ViewAllButton {
        print("View All tapped")
    }
}
