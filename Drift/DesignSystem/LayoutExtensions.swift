//
//  LayoutExtensions.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

// MARK: - Semantic Padding Sizes

enum PaddingSize {
    case small   // 4px
    case medium  // 8px
    case large   // 16px

    var value: CGFloat {
        switch self {
        case .small: return DesignTokens.Padding.small
        case .medium: return DesignTokens.Padding.medium
        case .large: return DesignTokens.Padding.large
        }
    }
}

// MARK: - View Extensions for Layout

extension View {
    /// Apply semantic padding
    func padding(_ size: PaddingSize) -> some View {
        self.padding(size.value)
    }

    /// Apply semantic horizontal padding
    func paddingHorizontal(_ size: PaddingSize) -> some View {
        self.padding(.horizontal, size.value)
    }

    /// Apply semantic vertical padding
    func paddingVertical(_ size: PaddingSize) -> some View {
        self.padding(.vertical, size.value)
    }
}

// MARK: - Spacing Constants (for VStack/HStack)

extension DesignTokens.Spacing {
    /// Use these directly in VStack/HStack spacing parameters
    /// Example: VStack(spacing: DesignTokens.Spacing.standard) { ... }

    /// 32px spacing
    static let huge = xxxLarge

    /// 16px spacing - most common
    static let standard = xLarge

    /// 8px spacing - compact
    static let compact = large

    /// 4px spacing - tight
    static let tight = medium
}
