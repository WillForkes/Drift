//
//  Typography.swift
//  Drift
//
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
    func headingXL() -> some View {
        modifier(HeadingXLModifier())
    }

    func heading1() -> some View {
        modifier(Heading1Modifier())
    }

    func heading2() -> some View {
        modifier(Heading2Modifier())
    }

    func body() -> some View {
        modifier(BodyModifier())
    }

    func bodySmall() -> some View {
        modifier(BodySmallModifier())
    }

    func subtextColor() -> some View {
        foregroundColor(DesignTokens.Colors.subtext)
    }

    func extraSubtextColor() -> some View {
        foregroundColor(DesignTokens.Colors.extraSubtext)
    }
}
