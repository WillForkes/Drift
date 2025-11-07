//
//  HapticManager.swift
//  Drift
//
//  Created by Claude Code on 06/11/2025.
//

import UIKit

/// Manages haptic feedback throughout the app
@MainActor
class HapticManager {
    static let shared = HapticManager()

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        // Prepare generators for reduced latency
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
    }

    // MARK: - Public Methods

    /// Plays success haptic feedback
    func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    /// Plays error haptic feedback
    func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }

    /// Plays warning haptic feedback
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    /// Plays light impact haptic
    func impactLight() {
        lightGenerator.impactOccurred()
        lightGenerator.prepare()
    }

    /// Plays medium impact haptic
    func impactMedium() {
        mediumGenerator.impactOccurred()
        mediumGenerator.prepare()
    }

    /// Plays heavy impact haptic
    func impactHeavy() {
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
    }

    /// Plays custom intensity impact haptic
    func impact(intensity: CGFloat = 0.5) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: intensity)
    }
}
