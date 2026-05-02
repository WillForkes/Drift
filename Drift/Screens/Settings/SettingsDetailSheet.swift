//
//  SettingsDetailSheet.swift
//  Drift
//
//

import SwiftUI
import UserNotifications

// MARK: - Sheet Type Enum

enum SettingsSheetType: Identifiable {
    case notifications
    case troubleshooting
    case about
    case contactSupport

    var id: String {
        switch self {
        case .notifications: return "notifications"
        case .troubleshooting: return "troubleshooting"
        case .about: return "about"
        case .contactSupport: return "contactSupport"
        }
    }

    var title: String {
        switch self {
        case .notifications: return "Notifications"
        case .troubleshooting: return "Troubleshooting"
        case .about: return "About Drift"
        case .contactSupport: return "Contact Support"
        }
    }

    var icon: String {
        switch self {
        case .notifications: return "bell.fill"
        case .troubleshooting: return "wrench.and.screwdriver.fill"
        case .about: return "info.circle.fill"
        case .contactSupport: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Settings Detail Sheet

struct SettingsDetailSheet: View {
    let sheetType: SettingsSheetType
    let onDismiss: () -> Void

    @Environment(\.openURL) var openURL
    @State private var notificationsEnabled = false
    @State private var isCheckingPermissions = false

    var body: some View {
        NavigationView {
            ZStack {
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.xxLarge) {
                        // Icon
                        Image(systemName: sheetType.icon)
                            .font(.system(size: 48))
                            .foregroundColor(DesignTokens.Colors.primary)
                            .padding(.top, DesignTokens.Spacing.xLarge)

                        // Content based on sheet type
                        switch sheetType {
                        case .notifications:
                            notificationsContent
                        case .troubleshooting:
                            troubleshootingContent
                        case .about:
                            aboutContent
                        case .contactSupport:
                            contactSupportContent
                        }
                    }
                    .padding(DesignTokens.Padding.large)
                    .padding(.bottom, DesignTokens.Spacing.xxxLarge)
                }
            }
            .navigationTitle(sheetType.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(DesignTokens.Colors.primary)
                }
            }
        }
        .onAppear {
            checkNotificationPermissions()
        }
    }

    // MARK: - Content Views

    private var notificationsContent: some View {
        VStack(spacing: DesignTokens.Spacing.xLarge) {
            Text("Stay updated with notifications about your focus sessions and achievements.")
                .body()
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)

            // Notification toggle card
            VStack(spacing: DesignTokens.Spacing.xLarge) {
                HStack {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                        Text("Enable Notifications")
                            .heading2()
                            .foregroundColor(DesignTokens.Colors.textPrimary)

                        Text(notificationsEnabled ? "Notifications are enabled" : "Tap to enable notifications")
                            .bodySmall()
                            .subtextColor()
                    }

                    Spacer()
                }

                DriftButton(
                    title: notificationsEnabled ? "Enabled" : "Enable",
                    icon: notificationsEnabled ? "checkmark" : "bell.fill",
                    style: notificationsEnabled ? .pillSecondary : .pill
                ) {
                    requestNotificationPermission()
                }
                .disabled(notificationsEnabled)
            }
            .padding(DesignTokens.Padding.large)
            .cardBackground()
        }
    }

    private var troubleshootingContent: some View {
        VStack(spacing: DesignTokens.Spacing.xLarge) {
            Text("Having issues? Try these steps before contacting support.")
                .body()
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)

            // Screen Time Permission card
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xLarge) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                    Text("Screen Time Permission")
                        .heading2()
                        .foregroundColor(DesignTokens.Colors.textPrimary)

                    Text("Drift needs Screen Time permission to block apps during focus sessions. If blocking isn't working, try requesting permission again.")
                        .bodySmall()
                        .subtextColor()
                }

                DriftButton(
                    title: "Request Permission",
                    icon: "hand.raised.fill",
                    style: .pill
                ) {
                    requestScreenTimePermission()
                }
            }
            .padding(DesignTokens.Padding.large)
            .cardBackground()

            // Additional troubleshooting tips
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                Text("Common Issues")
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    TroubleshootingTip(
                        title: "Apps not blocking",
                        description: "Make sure Screen Time permission is granted above"
                    )

                    TroubleshootingTip(
                        title: "NFC not working",
                        description: "Hold your phone's top edge near the drift tag"
                    )

                    TroubleshootingTip(
                        title: "Session not starting",
                        description: "Ensure you have at least one drift and preset configured"
                    )
                }
            }
            .padding(DesignTokens.Padding.large)
            .cardBackground()
        }
    }

    private var aboutContent: some View {
        VStack(spacing: DesignTokens.Spacing.xLarge) {
            // App name and logo
            VStack(spacing: DesignTokens.Spacing.large) {
                Image("above")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)

                Text("Drift")
                    .headingXL()
                    .foregroundColor(DesignTokens.Colors.primary)
            }

            // Version info
            VStack(spacing: DesignTokens.Spacing.medium) {
                InfoRow(label: "Version", value: appVersion)
                InfoRow(label: "Build", value: buildNumber)
            }
            .padding(DesignTokens.Padding.large)
            .cardBackground()

            // Copyright
            Text("© 2025 Drift. All rights reserved.")
                .bodySmall()
                .extraSubtextColor()
                .multilineTextAlignment(.center)
        }
    }

    private var contactSupportContent: some View {
        VStack(spacing: DesignTokens.Spacing.xLarge) {
            Text("Need help? We're here for you.")
                .body()
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)

            // Try troubleshooting first card
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                HStack(spacing: DesignTokens.Spacing.large) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DesignTokens.Colors.primary)

                    Text("Try the Troubleshooting section first for quick solutions to common issues.")
                        .bodySmall()
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                }
            }
            .padding(DesignTokens.Padding.large)
            .cardBackground()

            // Support button card
            VStack(spacing: DesignTokens.Spacing.xLarge) {
                Text("Still need help? Visit our support page.")
                    .body()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                DriftButton(
                    title: "Visit Support Page",
                    icon: "safari.fill",
                    style: .pill
                ) {
                    if let url = URL(string: "https://get-drift.app/contact") {
                        openURL(url)
                    }
                }
            }
            .padding(DesignTokens.Padding.large)
            .cardBackground()
        }
    }

    // MARK: - Helper Views

    private struct TroubleshootingTip: View {
        let title: String
        let description: String

        var body: some View {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
                HStack {
                    Circle()
                        .fill(DesignTokens.Colors.primary)
                        .frame(width: 6, height: 6)

                    Text(title)
                        .body()
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                }

                Text(description)
                    .bodySmall()
                    .subtextColor()
                    .padding(.leading, DesignTokens.Spacing.xLarge)
            }
        }
    }

    private struct InfoRow: View {
        let label: String
        let value: String

        var body: some View {
            HStack {
                Text(label)
                    .body()
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                Spacer()

                Text(value)
                    .body()
                    .subtextColor()
            }
        }
    }

    // MARK: - Helper Methods

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                notificationsEnabled = granted
                if let error = error {
                    print("❌ [Notifications] Error requesting permission: \(error)")
                }
            }
        }
    }

    private func requestScreenTimePermission() {
        Task {
            do {
                try await FocusSessionManager.shared.requestAuthorization()
                print("✅ [Settings] Screen Time permission requested")
            } catch {
                print("❌ [Settings] Failed to request Screen Time permission: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsDetailSheet(sheetType: .about, onDismiss: {})
}
