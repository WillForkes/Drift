//
//  HapticManager.swift
//  Drift
//
//

import UIKit

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

    func success() {
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    func error() {
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }

    func warning() {
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    func impactLight() {
        lightGenerator.impactOccurred()
        lightGenerator.prepare()
    }

    func impactMedium() {
        mediumGenerator.impactOccurred()
        mediumGenerator.prepare()
    }

    func impactHeavy() {
        heavyGenerator.impactOccurred()
        heavyGenerator.prepare()
    }

    func impact(intensity: CGFloat = 0.5) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: intensity)
    }
}
