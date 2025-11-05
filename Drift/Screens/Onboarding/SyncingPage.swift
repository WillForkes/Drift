//
//  SyncingPage.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct SyncingPage: View {
    let tagId: String
    @Binding var driftName: String
    let onSuccess: () -> Void
    let onError: (String) -> Void

    @State private var syncState: SyncState = .validating
    @StateObject private var tagManager = DriftTagManager.shared
    @FocusState private var isTextFieldFocused: Bool

    enum SyncState: Equatable {
        case validating
        case authorizing
        case namingTag
        case finishing
        case success
        case error(String)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Non-naming states: Use absolute positioning
                if syncState != .namingTag {
                    VStack(spacing: 0) {
                        // Heading Section - Fixed 80px from top
                        VStack(spacing: DesignTokens.Spacing.medium) {
                            Text(headingText)
                                .heading1()
                                .foregroundColor(DesignTokens.Colors.whiteText)

                            Text(subheadingText)
                                .heading2()
                                .foregroundColor(DesignTokens.Colors.whiteText)
                        }
                        .padding(.top, 80)
                        .frame(maxWidth: .infinity)

                        Spacer()
                    }

                    // Image - Absolute vertical center (dead center)
                    Image("above")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)

                    // Content - positioned below center image
                    contentView
                        .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) + 100 + 110)
                } else {
                    // Naming state: Use flexible layout for keyboard handling
                    VStack(spacing: 0) {
                        // Heading Section - Fixed 80px from top
                        VStack(spacing: DesignTokens.Spacing.medium) {
                            Text(headingText)
                                .heading1()
                                .foregroundColor(DesignTokens.Colors.whiteText)

                            Text(subheadingText)
                                .heading2()
                                .foregroundColor(DesignTokens.Colors.whiteText)
                        }
                        .padding(.top, 80)
                        .frame(maxWidth: .infinity)

                        Spacer()

                        // Naming form - in normal flow
                        contentView
                            .padding(.horizontal, DesignTokens.Padding.large)

                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                performSync()
            }
        }
    }

    // MARK: - Content Views
    @ViewBuilder
    private var contentView: some View {
        switch syncState {
        case .validating, .authorizing, .finishing, .success:
            statusBadges
        case .namingTag:
            namingView
        case .error(let errorMessage):
            errorView(errorMessage)
        }
    }

    private var statusBadges: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            PillBadge(
                text: "NFC Chip valid",
                icon: badgeIcon(for: .validating),
                style: .light
            )

            PillBadge(
                text: "Setting up...",
                icon: badgeIcon(for: .authorizing),
                style: .transparent
            )

            PillBadge(
                text: "Finishing up...",
                icon: badgeIcon(for: .finishing),
                style: .transparent
            )
        }
    }

    private var namingView: some View {
        VStack(spacing: DesignTokens.Spacing.xxLarge) {
            VStack(spacing: DesignTokens.Spacing.medium) {
                Text("Name your drift")
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.whiteText)
                    .multilineTextAlignment(.center)

                Text("Give your drift a memorable name")
                    .bodySmall()
                    .foregroundColor(DesignTokens.Colors.whiteText.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: DesignTokens.Spacing.large) {
                TextField("", text: $driftName, prompt: Text("My Drift").foregroundColor(.gray))
                    .focused($isTextFieldFocused)
                    .font(.custom(DesignTokens.Typography.fontFamily, size: 20))
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 280)
                    .background(DesignTokens.Colors.whiteText)
                    .cornerRadius(DesignTokens.Radii.radiusStandard)

                DriftButton(title: "Continue", style: .primary) {
                    isTextFieldFocused = false // Dismiss keyboard
                    registerTag()
                }
                .disabled(driftName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(driftName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
            }
        }
        .padding(.horizontal, DesignTokens.Padding.large)
        .padding(.vertical, DesignTokens.Padding.large)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radii.radiusStandard)
                .fill(DesignTokens.Colors.whiteText.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radii.radiusStandard)
                        .stroke(DesignTokens.Colors.whiteText.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            // Auto-focus text field when naming view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)

            Text(message)
                .body()
                .foregroundColor(DesignTokens.Colors.whiteText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    // MARK: - Computed Properties

    private var headingText: String {
        switch syncState {
        case .validating, .authorizing, .finishing:
            return "Syncing..."
        case .namingTag:
            return "Almost done!"
        case .success:
            return "Success!"
        case .error:
            return "Error"
        }
    }

    private var subheadingText: String {
        switch syncState {
        case .validating, .authorizing, .finishing:
            return "Please wait for the sync to finish"
        case .namingTag:
            return "Let's give your drift a name"
        case .success:
            return "Your drift is ready to use"
        case .error:
            return "Something went wrong"
        }
    }

    private func badgeIcon(for step: SyncState) -> PillIcon {
        switch (syncState, step) {
        case (.validating, .validating):
            return .systemImage(name: "arrow.clockwise", color: .black, size: 14)
        case (.authorizing, .validating), (.namingTag, .validating), (.finishing, .validating), (.success, .validating):
            return .systemImage(name: "checkmark", color: .green, size: 14)

        case (.authorizing, .authorizing):
            return .systemImage(name: "arrow.clockwise", color: .black, size: 12)
        case (.namingTag, .authorizing), (.finishing, .authorizing), (.success, .authorizing):
            return .systemImage(name: "checkmark", color: .green, size: 12)
        case (_, .authorizing):
            return .systemImage(name: "arrow.clockwise", color: .black, size: 12)
        case (.finishing, .finishing):
            return .systemImage(name: "arrow.clockwise", color: .black, size: 12)
        case (.success, .finishing):
            return .systemImage(name: "checkmark", color: .green, size: 12)
            
        case (_, .finishing):
            return .systemImage(name: "arrow.clockwise", color: .black, size: 12)
        default:
            return .systemImage(name: "arrow.clockwise", color: .black, size: 12)
        }
    }

    // MARK: - Sync Logic

    private func performSync() {
        Task {
            do {
                // Step 1: Validate tag
                print("🔄 [Sync] Validating tag...")
                syncState = .validating
                try await Task.sleep(nanoseconds: 1_000_000_000) // 0.5s

                // Check if tag ID is valid
                guard !tagId.isEmpty else {
                    throw SyncError.invalidTag
                }

                // Check if already registered
                if tagManager.isRegistered(id: tagId) {
                    throw SyncError.alreadyRegistered
                }

                // Step 2: Authorize (simulate API call or Screen Time check)
                print("🔄 [Sync] Authorizing...")
                syncState = .authorizing
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1s

                // Step 3: Prompt user to name their drift
                print("📝 [Sync] Waiting for drift name...")
                syncState = .namingTag

            } catch {
                handleError(error)
            }
        }
    }

    private func registerTag() {
        Task {
            do {
                // Step 4: Finish registration
                print("🔄 [Sync] Finishing registration...")
                syncState = .finishing
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5s

                // No preset assigned yet
                let presetId = ""

                // Register tag with current timestamp (trim whitespace)
                let trimmedName = driftName.trimmingCharacters(in: .whitespacesAndNewlines)
                tagManager.registerTag(
                    id: tagId,
                    label: trimmedName,
                    presetId: presetId
                )

                print("✅ [Sync] Tag registered: \(tagId) as '\(trimmedName)' (no preset yet)")

                // Show success
                syncState = .success
                try await Task.sleep(nanoseconds: 500_000_000) // Show success for 0.5s

                onSuccess()

            } catch {
                handleError(error)
            }
        }
    }

    private func handleError(_ error: Error) {
        let errorMessage = formatError(error)
        print("❌ [Sync] Error: \(errorMessage)")
        syncState = .error(errorMessage)

        Task {
            // Show error for 2 seconds before calling onError
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            onError(errorMessage)
        }
    }

    private func formatError(_ error: Error) -> String {
        #if DEBUG
        if let syncError = error as? SyncError {
            return "\(syncError.localizedDescription)\n\nTag ID: \(tagId)"
        }
        return "\(error.localizedDescription)\n\nTag ID: \(tagId)"
        #else
        if let syncError = error as? SyncError {
            return syncError.localizedDescription
        }
        return error.localizedDescription
        #endif
    }
}

// MARK: - Sync Errors

enum SyncError: LocalizedError {
    case alreadyRegistered
    case invalidTag
    case networkError

    var errorDescription: String? {
        switch self {
        case .alreadyRegistered:
            return "This Drift tag is already registered"
        case .invalidTag:
            return "Invalid Drift tag"
        case .networkError:
            return "Network error. Please try again"
        }
    }
}

#Preview {
    SyncingPage(
        tagId: "1234",
//        driftName: .constant("My Drift"),
        driftName: .constant(""),
        onSuccess: {
            print("Success")
        },
        onError: { error in
            print("Error: \(error)")
        }
    )
    .background(DesignTokens.Colors.primary)
}
