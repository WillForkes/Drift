//
//  AnalyticsPage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct AnalyticsPage: View {
    @StateObject private var analyticsManager = AnalyticsManager.shared

    // Computed properties for real-time data
    private var currentStreak: Int {
        analyticsManager.getCurrentStreak()
    }

    private var todaysFocusedTime: String {
        let time = analyticsManager.getTodaysFocusedTime()
        let hours = Int(time) / 3600
        let minutes = Int(time) % 3600 / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }

    private var sessionsThisWeek: [(date: String, count: Int)] {
        let stats = analyticsManager.getDailyStats(days: 7)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"

        return stats.reversed().map { stat in
            (formatter.string(from: stat.date), stat.sessionCount)
        }
    }

    private var weeklyGraphData: [(date: Date, minutes: Double)] {
        let stats = analyticsManager.getDailyStats(days: 7)
        return stats.reversed().map { stat in
            (stat.date, stat.totalFocusedTime / 60.0) // Convert seconds to minutes
        }
    }

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

                    // Grid Layout (60% of available space)
                    HStack(spacing: DesignTokens.Spacing.xLarge) {
                        // Left Column - Two stacked cards
                        VStack(spacing: DesignTokens.Spacing.xLarge) {
                            // Current Streak Card
                            StatCard(icon: "flame.fill", title: "Streak") {
                                Text(currentStreak == 0 ? "No streak" : "\(currentStreak) \(currentStreak == 1 ? "day" : "days")")
                                    .body()
                                    .foregroundColor(DesignTokens.Colors.textPrimary)
                            }

                            // Today Card
                            StatCard(icon: "clock.fill", title: "Today") {
                                Text(todaysFocusedTime)
                                    .body()
                                    .foregroundColor(DesignTokens.Colors.textPrimary)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // Right Column - Sessions per day (full height)
                        StatCard(icon: "chart.bar.fill", title: "Sessions per day") {
                            VStack(spacing: DesignTokens.Spacing.large) {
                                // List of days
                                ForEach(sessionsThisWeek, id: \.date) { item in
                                    HStack {
                                        Text(item.date)
                                            .bodySmall()
                                            .foregroundColor(DesignTokens.Colors.textPrimary)

                                        Spacer()

                                        Text("\(item.count)")
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
                    VStack(spacing: DesignTokens.Spacing.xLarge) {
                        // Header
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 24))
                                .foregroundColor(DesignTokens.Colors.primary)

                            Text("This Week")
                                .heading1()
                                .foregroundColor(DesignTokens.Colors.textPrimary)

                            Spacer()
                        }

                        // Graph
                        WeeklyFocusGraph(data: weeklyGraphData)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(DesignTokens.Padding.large)
                    .cardBackground()
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
