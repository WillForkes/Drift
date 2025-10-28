//
//  DesignTokens.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

/// Central design system tokens for Drift
enum DesignTokens {

    // MARK: - Colors

    enum Colors {
        static let background = Color(hex: "F7F0E9")
        static let accent = Color(hex: "E2B899")
        static let primary = Color(hex: "C86A1C")
        static let textPrimary = Color(hex: "000000")
        static let subtext = Color(hex: "000000").opacity(0.8)
        static let extraSubtext = Color(hex: "000000").opacity(0.5)
        static let whiteText = Color(hex: "FFFFFF")
    }
    
    // MARK: - Radii
    enum Radii {
        static let radiusStandard: CGFloat = 16
        static let radiusSmall: CGFloat = 8
    }
    
    // MARK: - Typography
    enum Typography {
        /// Futura PT Book - fallback to system if not available
        static let fontFamily = "Futura PT"

        enum Size {
            static let heading1: CGFloat = 28
            static let heading2: CGFloat = 22
            static let body: CGFloat = 20
            static let bodySmall: CGFloat = 18
        }

        enum Tracking {
            static let heading1: CGFloat = -0.04
            static let heading2: CGFloat = -0.02
            static let body: CGFloat = 0
            static let bodySmall: CGFloat = 0
        }

        enum LineHeight {
            static let heading: CGFloat = 1.4
            static let body: CGFloat = 1.6
            static let bodySmall: CGFloat = 1.4
        }
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxxLarge: CGFloat = 32
        static let xxLarge: CGFloat = 24
        static let xLarge: CGFloat = 16
        static let large: CGFloat = 8
        static let medium: CGFloat = 4
    }

    // MARK: - Padding

    enum Padding {
        static let large: CGFloat = 16
        static let medium: CGFloat = 8
        static let small: CGFloat = 4
    }

    // MARK: - Shadow

    enum Shadow {
        static let color = Color.black.opacity(0.12)
        static let radius: CGFloat = 6
        static let x: CGFloat = 0
        static let y: CGFloat = 3
    }
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
