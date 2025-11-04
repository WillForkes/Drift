//
//  PillBadge.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct PillBadge: View {
    let text: String
    let icon: PillIcon
    let style: PillStyle
    
    // Default initializer for backward compatibility
    init(text: String) {
        self.text = text
        self.icon = .circle(color: .red, size: 5)
        self.style = .light
    }
    
    // Full customization initializer
    init(text: String, icon: PillIcon, style: PillStyle) {
        self.text = text
        self.icon = icon
        self.style = style
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.large) {
            // Icon
            iconView
            
            // Text
            Text(text)
                .bodySmall()
                .foregroundColor(style.textColor)
        }
        .padding(.horizontal, style.horizontalPadding)
        .padding(.vertical, style.verticalPadding)
        .background(style.backgroundColor)
        .cornerRadius(style.cornerRadius)
    }
    
    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .circle(let color, let size):
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        case .systemImage(let name, let color, let size):
            Image(systemName: name)
                .font(.system(size: size, weight: .bold))
                .foregroundColor(color)
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Supporting Types

enum PillIcon {
    case circle(color: Color, size: CGFloat)
    case systemImage(name: String, color: Color, size: CGFloat)
    case none
}

enum PillStyle {
    case light
    case dark
    case transparent
    
    var backgroundColor: Color {
        switch self {
        case .light:
            return DesignTokens.Colors.whiteText
        case .dark:
            return Color.black
        case .transparent:
            return Color.white.opacity(0.2)
        }
    }
    
    var textColor: Color {
        switch self {
        case .light:
            return DesignTokens.Colors.textPrimary
        case .dark, .transparent:
            return .white
        }
    }
    
    var horizontalPadding: CGFloat {
        return DesignTokens.Padding.large
    }
    
    var verticalPadding: CGFloat {
        return DesignTokens.Padding.medium
    }
    
    var cornerRadius: CGFloat {
        return DesignTokens.Radii.radiusStandard
    }
}

#Preview {
    VStack(spacing: 20) {
        // Default style (backward compatibility)
        PillBadge(text: "drifting")
        
        // Sync status examples
        PillBadge(
            text: "NFC Chip valid",
            icon: .systemImage(name: "checkmark", color: .green, size: 14),
            style: .transparent
        )
        
        PillBadge(
            text: "Authorizing",
            icon: .circle(color: .yellow, size: 12),
            style: .transparent
        )
        
        PillBadge(
            text: "Finishing up...",
            icon: .systemImage(name: "arrow.clockwise", color: .white.opacity(0.7), size: 12),
            style: .transparent
        )
    }
    .padding()
    .background(Color.orange) // Orange background to test transparent style
}
