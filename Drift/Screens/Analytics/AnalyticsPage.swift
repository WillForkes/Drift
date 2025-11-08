//
//  AnalyticsPage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct AnalyticsPage: View {
    @StateObject private var analyticsManager = AnalyticsManager.shared

    // Static cached DateFormatter to avoid creating new instances repeatedly
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter
    }()

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
        return stats.reversed().map { stat in
            (Self.dateFormatter.string(from: stat.date), stat.sessionCount)
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignTokens.Spacing.xxLarge) {
                        // Page Title
                        Text("Your Analytics")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, DesignTokens.Padding.large)

                    // Grid Layout
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.xLarge) {
                        // Left Column - Two stacked cards
                        VStack(spacing: DesignTokens.Spacing.xLarge) {
                            // Current Streak Card
                            StatCard(icon: "flame.fill", title: "Streak") {
                                Text(currentStreak == 0 ? "No streak" : "\(currentStreak) \(currentStreak == 1 ? "day" : "days")")
                                    .heading1()
                                    .foregroundColor(DesignTokens.Colors.textPrimary)
                            }
                            .frame(height: 175)

                            // Today Card
                            StatCard(icon: "clock.fill", title: "Today") {
                                Text(todaysFocusedTime)
                                    .heading1()
                                    .foregroundColor(DesignTokens.Colors.textPrimary)
                            }
                            .frame(height: 175)
                        }
                        .frame(maxWidth: .infinity)

                        // Right Column - Sessions per day (full height)
                        VStack(spacing: DesignTokens.Spacing.xLarge) {
                            // Icon
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 32))
                                .foregroundColor(DesignTokens.Colors.primary)

                            // Title
                            Text("Sessions")
                                .heading1()
                                .foregroundColor(DesignTokens.Colors.textPrimary)

                            // List of days
                            VStack(spacing: DesignTokens.Spacing.medium) {
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
                            }

                            Spacer()

                            // View All Button
                            ViewAllButton {
                                // Action placeholder
                                print("View All tapped")
                            }
                        }
                        .padding(DesignTokens.Padding.large)
                        .frame(maxWidth: .infinity)
                        .cardBackground()
                    }
                    .padding(.horizontal, DesignTokens.Padding.large)

                    // Full Width Card Below
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
                    .frame(maxWidth: .infinity)
                    .padding(DesignTokens.Padding.large)
                    .cardBackground()
                    .padding(.horizontal, DesignTokens.Padding.large)
                    .padding(.bottom, DesignTokens.Spacing.xxLarge)
                    }
                }
            }
        }
    }
}

#Preview {
    AnalyticsPage()
}
