//
//  AnalyticsPage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct AnalyticsPage: View {
    // Placeholder data
    let tapData: [(date: String, taps: Int)] = [
        ("25th Oct", 12),
        ("26th Oct", 8),
        ("27th Oct", 15),
        ("28th Oct", 10),
        ("29th Oct", 20),
        ("30th Oct", 7)
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: DesignTokens.Spacing.xxLarge) {
                    // Page Title
                    Text("Your Analytics")
                        .heading1()
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DesignTokens.Padding.large)
                        .padding(.top, DesignTokens.Spacing.xxLarge)

                    // Grid Layout (60% of available space)
                    HStack(spacing: DesignTokens.Spacing.xLarge) {
                        // Left Column - Two stacked cards
                        VStack(spacing: DesignTokens.Spacing.xLarge) {
                            // Current Streak Card
                            StatCard(icon: "flame.fill", title: "Current Streak") {
                                Text("7 days")
                                    .body()
                                    .foregroundColor(DesignTokens.Colors.textPrimary)
                            }

                            // Today Card
                            StatCard(icon: "clock.fill", title: "Today") {
                                Text("45 minutes")
                                    .body()
                                    .foregroundColor(DesignTokens.Colors.textPrimary)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // Right Column - Taps per day (full height)
                        StatCard(icon: "hand.tap.fill", title: "Taps per day") {
                            VStack(spacing: DesignTokens.Spacing.large) {
                                // List of days
                                ForEach(tapData, id: \.date) { item in
                                    HStack {
                                        Text(item.date)
                                            .bodySmall()
                                            .foregroundColor(DesignTokens.Colors.textPrimary)

                                        Spacer()

                                        Text("\(item.taps)")
                                            .bodySmall()
                                            .foregroundColor(DesignTokens.Colors.primary)
                                    }
                                }

                                Spacer()

                                // View All Button
                                ViewAllButton {
                                    // Action placeholder
                                    print("View All tapped")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: geometry.size.height * 0.6)
                    .padding(.horizontal, DesignTokens.Padding.large)

                    // Full Width Card Below (40% of remaining space)
                    VStack {
                        Text("Placeholder Content")
                            .body()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(DesignTokens.Padding.large)
                    .background(DesignTokens.Colors.whiteText)
                    .cornerRadius(DesignTokens.Radii.radiusStandard)
                    .shadow(
                        color: DesignTokens.Shadow.color,
                        radius: DesignTokens.Shadow.radius,
                        x: DesignTokens.Shadow.x,
                        y: DesignTokens.Shadow.y
                    )
                    .padding(.horizontal, DesignTokens.Padding.large)
                    .padding(.bottom, DesignTokens.Spacing.xxLarge)

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    AnalyticsPage()
}
