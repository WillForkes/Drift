//
//  ExampleDesignView.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

/// Example view demonstrating the Drift design system
struct ExampleDesignView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.standard) {
                // Typography Examples
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text("Heading 1")
                        .heading1()

                    Text("Heading 2")
                        .heading2()

                    Text("Body text with standard line height and spacing. This demonstrates the body text style at 18pt.")
                        .body()

                    Text("Body Small text for secondary information at 16pt.")
                        .bodySmall()
                        .subtextColor()
                }
                .padding(.large)

                Divider()

                // Color Palette
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text("Color Palette")
                        .heading2()

                    HStack(spacing: DesignTokens.Spacing.compact) {
                        ColorSwatch(name: "Background", color: DesignTokens.Colors.background)
                        ColorSwatch(name: "Accent", color: DesignTokens.Colors.accent)
                        ColorSwatch(name: "Primary", color: DesignTokens.Colors.primary)
                    }
                }
                .padding(.large)

                Divider()

                // Spacing Examples
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text("Padding Examples")
                        .heading2()

                    Text("Small Padding (4px)")
                        .bodySmall()
                        .padding(.small)
                        .background(DesignTokens.Colors.accent)

                    Text("Medium Padding (8px)")
                        .bodySmall()
                        .padding(.medium)
                        .background(DesignTokens.Colors.accent)

                    Text("Large Padding (16px)")
                        .bodySmall()
                        .padding(.large)
                        .background(DesignTokens.Colors.accent)
                }
                .padding(.large)

                Divider()

                // Spacing in Stacks
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.compact) {
                    Text("Vertical Spacing")
                        .heading2()

                    VStack(spacing: DesignTokens.Spacing.tight) {
                        Text("Tight spacing (4px)")
                            .bodySmall()
                        Text("Between items")
                            .bodySmall()
                    }

                    VStack(spacing: DesignTokens.Spacing.compact) {
                        Text("Compact spacing (8px)")
                            .bodySmall()
                        Text("Between items")
                            .bodySmall()
                    }

                    VStack(spacing: DesignTokens.Spacing.standard) {
                        Text("Standard spacing (16px)")
                            .bodySmall()
                        Text("Between items")
                            .bodySmall()
                    }
                }
                .padding(.large)
            }
        }
        .background(DesignTokens.Colors.background)
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.compact) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)

            Text(name)
                .bodySmall()
                .extraSubtextColor()
        }
    }
}

#Preview {
    ExampleDesignView()
}
