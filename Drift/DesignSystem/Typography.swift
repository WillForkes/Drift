//
//  Typography.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

// MARK: - Typography View Modifiers

struct HeadingXLModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(DesignTokens.Typography.fontFamily, size: DesignTokens.Typography.Size.headingXL))
            .fontWeight(.semibold)
            .tracking(DesignTokens.Typography.Tracking.headingXL)
            .lineSpacing(DesignTokens.Typography.Size.headingXL * (DesignTokens.Typography.LineHeight.heading - 1))
    }
}

struct Heading1Modifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(DesignTokens.Typography.fontFamily, size: DesignTokens.Typography.Size.heading1))
            .tracking(DesignTokens.Typography.Tracking.heading1)
            .lineSpacing(DesignTokens.Typography.Size.heading1 * (DesignTokens.Typography.LineHeight.heading - 1))
    }
}

struct Heading2Modifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(DesignTokens.Typography.fontFamily, size: DesignTokens.Typography.Size.heading2))
            .tracking(DesignTokens.Typography.Tracking.heading2)
            .lineSpacing(DesignTokens.Typography.Size.heading2 * (DesignTokens.Typography.LineHeight.heading - 1))
    }
}

struct BodyModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(DesignTokens.Typography.fontFamily, size: DesignTokens.Typography.Size.body))
            .tracking(DesignTokens.Typography.Tracking.body)
            .lineSpacing(DesignTokens.Typography.Size.body * (DesignTokens.Typography.LineHeight.body - 1))
    }
}

struct BodySmallModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom(DesignTokens.Typography.fontFamily, size: DesignTokens.Typography.Size.bodySmall))
            .tracking(DesignTokens.Typography.Tracking.bodySmall)
            .lineSpacing(DesignTokens.Typography.Size.bodySmall * (DesignTokens.Typography.LineHeight.bodySmall - 1))
    }
}

// MARK: - View Extensions

extension View {
    /// Apply Heading XL text style (48pt, -0.06 tracking, 1.4 line height)
    func headingXL() -> some View {
        modifier(HeadingXLModifier())
    }

    /// Apply Heading 1 text style (28pt, -0.04 tracking, 1.4 line height)
    func heading1() -> some View {
        modifier(Heading1Modifier())
    }

    /// Apply Heading 2 text style (20pt, -0.02 tracking, 1.4 line height)
    func heading2() -> some View {
        modifier(Heading2Modifier())
    }

    /// Apply Body text style (18pt, 0 tracking, 1.6 line height)
    func body() -> some View {
        modifier(BodyModifier())
    }

    /// Apply Body Small text style (16pt, 0 tracking, 1.4 line height)
    func bodySmall() -> some View {
        modifier(BodySmallModifier())
    }

    /// Apply subtext color (80% opacity black)
    func subtextColor() -> some View {
        foregroundColor(DesignTokens.Colors.subtext)
    }

    /// Apply extra subtext color (50% opacity black)
    func extraSubtextColor() -> some View {
        foregroundColor(DesignTokens.Colors.extraSubtext)
    }
}
