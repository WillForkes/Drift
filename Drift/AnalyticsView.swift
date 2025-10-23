//
//  AnalyticsView.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

struct AnalyticsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var analytics = AnalyticsManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Stats
                    VStack(spacing: 16) {
                        StatCard(
                            title: "Current Streak",
                            value: "\(analytics.getCurrentStreak())",
                            subtitle: "days",
                            icon: "flame.fill",
                            color: .orange
                        )

                        HStack(spacing: 16) {
                            StatCard(
                                title: "Today",
                                value: formatDuration(analytics.getTodaysFocusedTime()),
                                subtitle: "focused",
                                icon: "clock.fill",
                                color: .blue
                            )

                            if let lastSession = analytics.getLastSession() {
                                StatCard(
                                    title: "Last Session",
                                    value: formatDuration(lastSession.duration),
                                    subtitle: lastSession.presetName,
                                    icon: "bolt.fill",
                                    color: .green
                                )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Last 30 Days
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Last 30 Days")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(analytics.getDailyStats(days: 30)) { stat in
                            DayStatRow(stat: stat)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "0m"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 32, weight: .bold))

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct DayStatRow: View {
    let stat: DailyStats

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.dateString)
                    .font(.subheadline)

                if stat.sessionCount > 0 {
                    Text("\(stat.sessionCount) session\(stat.sessionCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if stat.totalFocusedTime > 0 {
                Text(stat.formattedTime)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            } else {
                Text("No sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    AnalyticsView()
}
