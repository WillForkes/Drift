//
//  NFCFocusCoordinator.swift
//  Drift
//
//  Created by William Forkes on 06/11/2025.
//

import Foundation
import Combine

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

    @discardableResult
    func handleTagDetection(tagId: String) -> Result<SessionAction, CoordinatorError> {
        print("🏷️ [NFCFocusCoordinator] Handling tag detection: \(tagId)")

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

        guard !drift.presetId.isEmpty else {
            print("❌ [NFCFocusCoordinator] Drift has not been linked to a preset")
            haptics.error()
            return .failure(.presetNotLinked(driftName: drift.label))
        }

        guard let preset = presetManager.getPreset(id: drift.presetId) else {
            print("❌ [NFCFocusCoordinator] Preset not found for drift")
            haptics.error()
            return .failure(.presetNotFound)
        }

        if sessionManager.isSessionActive {
            return handleStopSession()
        } else {
            return handleStartSession(drift: drift, preset: preset)
        }
    }

    // MARK: - Private Methods

    private func handleStartSession(drift: DriftTag, preset: FocusPreset) -> Result<SessionAction, CoordinatorError> {
        print("▶️ [NFCFocusCoordinator] Starting session with drift: \(drift.label)")

        presetManager.setCurrentPreset(preset.id)
        sessionManager.startSession(withDriftTagId: drift.id)
        haptics.success()
        shouldShowActiveSession = true

        print("✅ [NFCFocusCoordinator] Session started successfully")
        return .success(.started(driftName: drift.label, presetName: preset.name))
    }

    private func handleStopSession() -> Result<SessionAction, CoordinatorError> {
        print("⏹️ [NFCFocusCoordinator] Stopping active session")

        if parentalControls.isEnabled {
            print("🔒 [NFCFocusCoordinator] Parental controls enabled - notification posted")
            NotificationCenter.default.post(name: .nfcStopRequested, object: nil)
            haptics.warning()
            return .failure(.parentalControlsRequired)
        }

        sessionManager.stopSession()
        haptics.success()
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
        case presetNotLinked(driftName: String)
        case presetNotFound
        case parentalControlsRequired

        var errorDescription: String? {
            switch self {
            case .tagNotRegistered(let tagId):
                return "Drift tag '\(tagId)' is not registered. Please set it up first."
            case .tagNotFound:
                return "Could not find drift tag information."
            case .presetNotLinked(let driftName):
                return "Drift '\(driftName)' hasn't been linked to a focus mode yet. Please select a mode on the home screen first."
            case .presetNotFound:
                return "Focus mode preset not found for this drift."
            case .parentalControlsRequired:
                return "Parental controls are enabled. Please verify to stop session."
            }
        }
    }
}
