//
//  NFCFocusCoordinator.swift
//  Drift
//
//  Created by Claude Code on 06/11/2025.
//

import Foundation
import Combine

/// Coordinates NFC tag detection with focus session management
@MainActor
class NFCFocusCoordinator: ObservableObject {
    static let shared = NFCFocusCoordinator()

    @Published var shouldShowActiveSession = false

    private let sessionManager = FocusSessionManager.shared
    private let driftManager = DriftTagManager.shared
    private let presetManager = PresetManager.shared
    private let parentalControls = ParentalControlsManager.shared
    private let haptics = HapticManager.shared

    private init() {}

    // MARK: - Public Methods

    /// Handles NFC tag detection and toggles focus session accordingly
    /// - Parameter tagId: The drift tag ID detected
    /// - Returns: Result indicating success or failure with appropriate message
    @discardableResult
    func handleTagDetection(tagId: String) -> Result<SessionAction, CoordinatorError> {
        print("🏷️ [NFCFocusCoordinator] Handling tag detection: \(tagId)")

        // Check if tag is registered
        guard driftManager.isRegistered(id: tagId) else {
            print("❌ [NFCFocusCoordinator] Tag not registered")
            haptics.error()
            return .failure(.tagNotRegistered(tagId: tagId))
        }

        guard let drift = driftManager.getTag(by: tagId) else {
            print("❌ [NFCFocusCoordinator] Failed to get drift tag")
            haptics.error()
            return .failure(.tagNotFound)
        }

        // Get associated preset
        guard let preset = presetManager.getPreset(id: drift.presetId) else {
            print("❌ [NFCFocusCoordinator] Preset not found for drift")
            haptics.error()
            return .failure(.presetNotFound)
        }

        // Check if session is already active
        if sessionManager.isSessionActive {
            return handleStopSession()
        } else {
            return handleStartSession(drift: drift, preset: preset)
        }
    }

    // MARK: - Private Methods

    private func handleStartSession(drift: DriftTag, preset: FocusPreset) -> Result<SessionAction, CoordinatorError> {
        print("▶️ [NFCFocusCoordinator] Starting session with drift: \(drift.label)")

        // Set the current preset
        presetManager.setCurrentPreset(preset.id)

        // Start session with drift tag ID
        sessionManager.startSession(withDriftTagId: drift.id)

        // Play success haptic
        haptics.success()

        // Show active session screen
        shouldShowActiveSession = true

        print("✅ [NFCFocusCoordinator] Session started successfully")
        return .success(.started(driftName: drift.label, presetName: preset.name))
    }

    private func handleStopSession() -> Result<SessionAction, CoordinatorError> {
        print("⏹️ [NFCFocusCoordinator] Stopping active session")

        // Check if parental controls are enabled
        if parentalControls.isEnabled {
            print("🔒 [NFCFocusCoordinator] Parental controls enabled - notification posted")
            // Post notification for parental controls verification
            NotificationCenter.default.post(name: .nfcStopRequested, object: nil)
            haptics.warning()
            return .failure(.parentalControlsRequired)
        }

        // Stop the session
        sessionManager.stopSession()

        // Play success haptic
        haptics.success()

        // Hide active session screen
        shouldShowActiveSession = false

        print("✅ [NFCFocusCoordinator] Session stopped successfully")
        return .success(.stopped)
    }
}

// MARK: - Supporting Types

extension NFCFocusCoordinator {
    enum SessionAction {
        case started(driftName: String, presetName: String)
        case stopped
    }

    enum CoordinatorError: LocalizedError {
        case tagNotRegistered(tagId: String)
        case tagNotFound
        case presetNotFound
        case parentalControlsRequired

        var errorDescription: String? {
            switch self {
            case .tagNotRegistered(let tagId):
                return "Drift tag '\(tagId)' is not registered. Please set it up first."
            case .tagNotFound:
                return "Could not find drift tag information."
            case .presetNotFound:
                return "Focus mode preset not found for this drift."
            case .parentalControlsRequired:
                return "Parental controls are enabled. Please verify to stop session."
            }
        }
    }
}
