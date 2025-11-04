//
//  DriftButton.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
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
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .background(style.backgroundColor)
            .cornerRadius(style.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button styling from interfering
    }
}

// MARK: - Button Styles

enum DriftButtonStyle {
    case primary
    case secondary
    case pill
    case pillSecondary
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return DesignTokens.Colors.primary
        case .secondary:
            return DesignTokens.Colors.whiteText
        case .pill, .pillSecondary:
            return self == .pill ? Color.black : DesignTokens.Colors.whiteText
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary:
            return DesignTokens.Colors.whiteText
        case .secondary, .pillSecondary:
            return DesignTokens.Colors.textPrimary
        case .pill:
            return DesignTokens.Colors.whiteText
        }
    }
    
    var borderColor: Color {
        switch self {
        case .primary, .pill:
            return Color.clear
        case .secondary, .pillSecondary:
            return DesignTokens.Colors.textPrimary.opacity(0.2)
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .primary, .pill:
            return 0
        case .secondary, .pillSecondary:
            return 1
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .primary, .secondary:
            return DesignTokens.Radii.radiusStandard
        case .pill, .pillSecondary:
            return 20
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .primary, .secondary:
            return DesignTokens.Padding.large
        case .pill, .pillSecondary:
            return DesignTokens.Padding.large
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .primary, .secondary:
            return DesignTokens.Padding.large
        case .pill, .pillSecondary:
            return DesignTokens.Padding.medium
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .primary, .secondary:
            return DesignTokens.Typography.Size.body
        case .pill, .pillSecondary:
            return DesignTokens.Typography.Size.bodySmall
        }
    }
    
    var fontWeight: Font.Weight {
        switch self {
        case .primary:
            return .medium
        case .secondary, .pill, .pillSecondary:
            return .regular
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .primary, .secondary:
            return 20
        case .pill, .pillSecondary:
            return 12
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        DriftButton(title: "Primary Button", icon: "heart.fill", style: .primary) {
            print("Primary tapped")
        }
        
        DriftButton(title: "Secondary Button", icon: "gear", style: .secondary) {
            print("Secondary tapped")
        }
        
        DriftButton(title: "Delete", icon: "xmark", style: .pill) {
            print("Delete tapped")
        }
        
        DriftButton(title: "Edit", icon: "pencil", style: .pillSecondary) {
            print("Edit tapped")
        }
        
        DriftButton(title: "No Icon Button", style: .primary) {
            print("No icon tapped")
        }
    }
    .padding()
}