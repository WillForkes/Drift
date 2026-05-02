//
//  DriftButton.swift
//  Drift
//
//

import SwiftUI

struct DriftButton: View {
    let title: String
    let icon: String?
    let style: DriftButtonStyle
    let action: () -> Void

    init(title: String, icon: String? = nil, style: DriftButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.medium) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: style.iconSize))
                }

                Text(title)
                    .font(.custom(DesignTokens.Typography.fontFamily, size: style.fontSize))
                    .fontWeight(style.fontWeight)
            }
            .foregroundColor(style.textColor)
            .padding(.horizontal, DesignTokens.Padding.large)
            .padding(.vertical, style.verticalPadding)
            .background(style.backgroundColor)
            .cornerRadius(style.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Button Styles

enum DriftButtonStyle {
    case primary
    case secondary
    case pill
    case pillSecondary
    case pillTertiary

    var backgroundColor: Color {
        switch self {
        case .primary: return DesignTokens.Colors.primary
        case .secondary, .pillSecondary: return DesignTokens.Colors.whiteText
        case .pillTertiary: return Color.clear
        case .pill: return Color.black
        }
    }

    var textColor: Color {
        switch self {
        case .primary, .pill: return DesignTokens.Colors.whiteText
        case .secondary, .pillSecondary: return DesignTokens.Colors.textPrimary
        case .pillTertiary: return DesignTokens.Colors.extraSubtext
        }
    }

    var borderColor: Color {
        switch self {
        case .primary, .pill: return .clear
        case .secondary, .pillSecondary: return DesignTokens.Colors.textPrimary.opacity(0.2)
        case .pillTertiary: return DesignTokens.Colors.extraSubtext
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .primary, .pill: return 0
        case .secondary, .pillSecondary, .pillTertiary: return 1
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .primary, .secondary: return DesignTokens.Radii.radiusSmall
        case .pill, .pillSecondary, .pillTertiary: return DesignTokens.Radii.radiusStandard
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .primary, .secondary: return DesignTokens.Padding.large
        case .pill, .pillSecondary: return DesignTokens.Padding.medium
        case .pillTertiary: return DesignTokens.Padding.small
        }
    }

    var fontSize: CGFloat {
        switch self {
        case .primary, .secondary: return DesignTokens.Typography.Size.body
        case .pill, .pillSecondary: return DesignTokens.Typography.Size.bodySmall
        case .pillTertiary: return 16
        }
    }

    var fontWeight: Font.Weight {
        self == .primary ? .medium : .regular
    }

    var iconSize: CGFloat {
        switch self {
        case .primary, .secondary: return 20
        case .pill, .pillSecondary: return 12
        case .pillTertiary: return 10
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DriftButton(title: "Primary Button", icon: "heart.fill", style: .primary) {}
        DriftButton(title: "Secondary Button", icon: "gear", style: .secondary) {}
        DriftButton(title: "Pill button", icon: "xmark", style: .pill) {}
        DriftButton(title: "Pill Secondary", icon: "pencil", style: .pillSecondary) {}
        DriftButton(title: "Pill Tertiary", icon: "trash", style: .pillTertiary) {}
        DriftButton(title: "No Icon Button", style: .primary) {}
    }
    .padding()
}
