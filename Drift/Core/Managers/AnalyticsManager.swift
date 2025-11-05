//
//  AnalyticsManager.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import Foundation

/// Represents a single focus session
struct FocusSession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    let presetName: String

    var duration: TimeInterval {
        guard let end = endTime else { return 0 }
        return end.timeIntervalSince(startTime)
    }

    init(startTime: Date, presetName: String) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = nil
        self.presetName = presetName
    }
}

/// Daily statistics summary
struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let totalFocusedTime: TimeInterval
    let sessionCount: Int

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var formattedTime: String {
        let hours = Int(totalFocusedTime) / 3600
        let minutes = Int(totalFocusedTime) % 3600 / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

/// Manages focus session analytics and statistics
@MainActor
class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()

    @Published private(set) var currentSession: FocusSession?
    @Published private(set) var sessions: [FocusSession] = []

    private enum Constants {
        static let sessionsKey = "drift.analytics.sessions"
        static let lastSessionDateKey = "drift.analytics.lastSessionDate"
    }

    private init() {
        loadSessions()
    }

    // MARK: - Session Tracking

    /// Start tracking a new focus session
    func startSession(presetName: String) {
        let session = FocusSession(startTime: Date(), presetName: presetName)
        currentSession = session
    }

    /// Stop the current session and save it
    func stopSession() {
        guard var session = currentSession else { return }

        session.endTime = Date()
        sessions.append(session)
        currentSession = nil

        // Update last session date for streak tracking
        UserDefaults.standard.set(Date(), forKey: Constants.lastSessionDateKey)

        saveSessions()
    }

    // MARK: - Statistics

    /// Get the last completed session
    func getLastSession() -> FocusSession? {
        return sessions.last
    }

    /// Get daily statistics for the last N days
    func getDailyStats(days: Int = 30) -> [DailyStats] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var statsDict: [Date: (time: TimeInterval, count: Int)] = [:]

        // Initialize last N days
        for i in 0..<days {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                statsDict[date] = (0, 0)
            }
        }

        // Aggregate session data
        for session in sessions {
            guard let endTime = session.endTime else { continue }
            let sessionDate = calendar.startOfDay(for: session.startTime)

            if let existing = statsDict[sessionDate] {
                statsDict[sessionDate] = (existing.time + session.duration, existing.count + 1)
            }
        }

        // Convert to array and sort
        let stats = statsDict.map { date, data in
            DailyStats(date: date, totalFocusedTime: data.time, sessionCount: data.count)
        }.sorted { $0.date > $1.date }

        return stats
    }

    /// Get total focused time for today
    func getTodaysFocusedTime() -> TimeInterval {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let todaySessions = sessions.filter { session in
            calendar.isDate(session.startTime, inSameDayAs: today)
        }

        return todaySessions.reduce(0) { $0 + $1.duration }
    }

    /// Calculate current streak (consecutive days with at least one session)
    func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Get unique session dates
        let sessionDates = Set(sessions.compactMap { session -> Date? in
            guard session.endTime != nil else { return nil }
            return calendar.startOfDay(for: session.startTime)
        }).sorted(by: >)

        guard !sessionDates.isEmpty else { return 0 }

        // Check if there's a session today or yesterday (grace period)
        let mostRecentDate = sessionDates.first!
        let daysSinceLastSession = calendar.dateComponents([.day], from: mostRecentDate, to: today).day ?? 0

        if daysSinceLastSession > 1 {
            return 0 // Streak broken
        }

        // Count consecutive days
        var streak = 0
        var checkDate = today

        for _ in 0..<365 { // Max 365 days to prevent infinite loop
            if sessionDates.contains(checkDate) {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else {
                break
            }
        }

        return streak
    }

    // MARK: - Persistence

    private func saveSessions() {
        // Only keep sessions from last 90 days to prevent unlimited growth
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -90, to: Date()) ?? Date()

        let recentSessions = sessions.filter { session in
            session.startTime > cutoffDate
        }

        if let data = try? JSONEncoder().encode(recentSessions) {
            UserDefaults.standard.set(data, forKey: Constants.sessionsKey)
        }

        sessions = recentSessions
    }

    private func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: Constants.sessionsKey),
              let loadedSessions = try? JSONDecoder().decode([FocusSession].self, from: data) else {
            return
        }

        sessions = loadedSessions
    }

    // MARK: - Debug/Reset

    /// Clear all analytics data (for development/testing)
    func resetAllData() {
        currentSession = nil
        sessions = []
        UserDefaults.standard.removeObject(forKey: Constants.sessionsKey)
        UserDefaults.standard.removeObject(forKey: Constants.lastSessionDateKey)
    }
}
