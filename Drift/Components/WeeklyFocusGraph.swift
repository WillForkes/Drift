//
//  WeeklyFocusGraph.swift
//  Drift
//
//  Created by Claude Code on 07/11/2025.
//

import SwiftUI

struct WeeklyFocusGraph: View {
    let data: [(date: Date, minutes: Double)]

    // Graph configuration
    private let graphHeight: CGFloat = 180
    private let dotSize: CGFloat = 8
    private let lineWidth: CGFloat = 3

    // Static cached DateFormatter to avoid creating new instances repeatedly
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue, Wed
        return formatter
    }()

    // Computed properties
    private var maxMinutes: Double {
        let max = data.map { $0.minutes }.max() ?? 60
        return max > 0 ? max : 60
    }

    private var dayLabels: [String] {
        return data.map { Self.dayFormatter.string(from: $0.date) }
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xLarge) {
            // Graph area
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Y-axis labels and grid lines
                    YAxisView(maxMinutes: maxMinutes, height: graphHeight)

                    // Main graph
                    HStack(spacing: 0) {
                        ForEach(0..<data.count, id: \.self) { index in
                            Spacer()
                        }
                    }
                    .overlay(
                        // Gradient fill under line
                        GraphGradient(data: data, maxMinutes: maxMinutes, height: graphHeight, width: geometry.size.width)
                            .opacity(0.2)
                    )
                    .overlay(
                        // Smooth line path
                        GraphLine(data: data, maxMinutes: maxMinutes, height: graphHeight, width: geometry.size.width)
                            .stroke(DesignTokens.Colors.primary, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                            .shadow(color: DesignTokens.Colors.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        // Data points
                        HStack(spacing: 0) {
                            ForEach(0..<data.count, id: \.self) { index in
                                Spacer()
                                DataPoint()
                                    .offset(y: -yPosition(for: data[index].minutes, maxMinutes: maxMinutes, height: graphHeight))
                                Spacer()
                            }
                        }
                    )
                }
                .frame(height: graphHeight)
            }
            .frame(height: graphHeight)
            .padding(.horizontal, DesignTokens.Padding.large)

            // Day labels
            HStack(spacing: 0) {
                ForEach(0..<dayLabels.count, id: \.self) { index in
                    Spacer()
                    Text(dayLabels[index])
                        .bodySmall()
                        .foregroundColor(DesignTokens.Colors.subtext)
                    Spacer()
                }
            }
            .padding(.horizontal, DesignTokens.Padding.large)
        }
    }

    private func yPosition(for minutes: Double, maxMinutes: Double, height: CGFloat) -> CGFloat {
        guard maxMinutes > 0 else { return 0 }
        return CGFloat(minutes / maxMinutes) * height
    }
}

// MARK: - Y-Axis View

struct YAxisView: View {
    let maxMinutes: Double
    let height: CGFloat

    private var yAxisLabels: [(label: String, position: CGFloat)] {
        let steps = 4
        return (0...steps).map { step in
            let minutes = (maxMinutes / Double(steps)) * Double(step)
            let label = formatMinutes(minutes)
            let position = (CGFloat(step) / CGFloat(steps)) * height
            return (label, position)
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // Grid lines
            ForEach(yAxisLabels, id: \.position) { item in
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height - item.position))
                    path.addLine(to: CGPoint(x: 1000, y: height - item.position))
                }
                .stroke(DesignTokens.Colors.textPrimary.opacity(0.1), lineWidth: 1)
            }

            // Labels
            VStack(spacing: 0) {
                ForEach(yAxisLabels.reversed(), id: \.position) { item in
                    HStack {
                        Text(item.label)
                            .font(.system(size: 10))
                            .foregroundColor(DesignTokens.Colors.extraSubtext)
                        Spacer()
                    }
                    if item.position != 0 {
                        Spacer()
                    }
                }
            }
            .frame(height: height)
            .padding(.trailing, DesignTokens.Padding.large)
        }
    }

    private func formatMinutes(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60

        if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
}

// MARK: - Graph Line (Smooth Curve)

struct GraphLine: Shape {
    let data: [(date: Date, minutes: Double)]
    let maxMinutes: Double
    let height: CGFloat
    let width: CGFloat

    func path(in rect: CGRect) -> Path {
        guard data.count > 1 else {
            return Path()
        }

        var path = Path()
        let spacing = width / CGFloat(data.count + 1)

        // Calculate points
        let points = data.enumerated().map { index, item -> CGPoint in
            let x = spacing * CGFloat(index + 1)
            let y = height - (CGFloat(item.minutes / maxMinutes) * height)
            return CGPoint(x: x, y: y)
        }

        // Start path
        path.move(to: points[0])

        // Create smooth curve using quadratic Bézier curves
        for index in 0..<points.count - 1 {
            let current = points[index]
            let next = points[index + 1]

            let midX = (current.x + next.x) / 2
            let midY = (current.y + next.y) / 2

            path.addQuadCurve(to: midX == current.x ? next : CGPoint(x: midX, y: midY),
                              control: CGPoint(x: (midX + current.x) / 2, y: current.y))

            if index == points.count - 2 {
                path.addQuadCurve(to: next,
                                  control: CGPoint(x: (midX + next.x) / 2, y: next.y))
            }
        }

        return path
    }
}

// MARK: - Graph Gradient Fill

struct GraphGradient: Shape {
    let data: [(date: Date, minutes: Double)]
    let maxMinutes: Double
    let height: CGFloat
    let width: CGFloat

    func path(in rect: CGRect) -> Path {
        guard data.count > 1 else {
            return Path()
        }

        var path = Path()
        let spacing = width / CGFloat(data.count + 1)

        // Calculate points
        let points = data.enumerated().map { index, item -> CGPoint in
            let x = spacing * CGFloat(index + 1)
            let y = height - (CGFloat(item.minutes / maxMinutes) * height)
            return CGPoint(x: x, y: y)
        }

        // Start from bottom left
        path.move(to: CGPoint(x: points[0].x, y: height))
        path.addLine(to: points[0])

        // Create smooth curve
        for index in 0..<points.count - 1 {
            let current = points[index]
            let next = points[index + 1]

            let midX = (current.x + next.x) / 2
            let midY = (current.y + next.y) / 2

            path.addQuadCurve(to: midX == current.x ? next : CGPoint(x: midX, y: midY),
                              control: CGPoint(x: (midX + current.x) / 2, y: current.y))

            if index == points.count - 2 {
                path.addQuadCurve(to: next,
                                  control: CGPoint(x: (midX + next.x) / 2, y: next.y))
            }
        }

        // Close path to bottom
        path.addLine(to: CGPoint(x: points.last!.x, y: height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Data Point Dot

struct DataPoint: View {
    var body: some View {
        Circle()
            .fill(DesignTokens.Colors.primary)
            .frame(width: 8, height: 8)
            .overlay(
                Circle()
                    .stroke(DesignTokens.Colors.background, lineWidth: 2)
            )
    }
}

// MARK: - Preview

#Preview {
    let calendar = Calendar.current
    let today = Date()

    let sampleData: [(date: Date, minutes: Double)] = (0..<7).map { index in
        let date = calendar.date(byAdding: .day, value: -6 + index, to: today)!
        let minutes = Double.random(in: 20...120)
        return (date, minutes)
    }

    return WeeklyFocusGraph(data: sampleData)
        .padding()
        .background(DesignTokens.Colors.background)
}
