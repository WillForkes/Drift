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
    func padding(_ size: PaddingSize) -> some View {
        self.padding(size.value)
    }

    func paddingHorizontal(_ size: PaddingSize) -> some View {
        self.padding(.horizontal, size.value)
    }

    func paddingVertical(_ size: PaddingSize) -> some View {
        self.padding(.vertical, size.value)
    }
}

// MARK: - Spacing Constants (for VStack/HStack)

extension DesignTokens.Spacing {
    static let huge = xxxLarge     // 32px
    static let standard = xLarge   // 16px
    static let compact = large     // 8px
    static let tight = medium      // 4px
}
