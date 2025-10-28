//
//  SlideIndicator.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct SlideIndicator: View {
    let currentPage: Int
    let totalPages: Int = 3
    let inactiveWidth: CGFloat = 32
    let activeWidthMultiplier: CGFloat = 2.0
    let height: CGFloat = 6

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.large) {
            ForEach(0..<totalPages, id: \.self) { index in
                RoundedRectangle(cornerRadius: DesignTokens.Radii.radiusStandard)
                    .fill(index == currentPage ?
                          DesignTokens.Colors.accent :
                          DesignTokens.Colors.accent.opacity(0.5))
                    .frame(
                        width: index == currentPage ? inactiveWidth * activeWidthMultiplier : inactiveWidth,
                        height: height
                    )
            }
        }
    }
}

#Preview {
    SlideIndicator(currentPage: 1)
}
