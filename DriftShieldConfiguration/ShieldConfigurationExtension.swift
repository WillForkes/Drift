//
//  ShieldConfigurationExtension.swift
//  DriftShieldConfiguration
//
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    // MARK: - Shield Configuration

    /// Creates a custom shield configuration matching Drift's design
    private func createDriftShieldConfiguration() -> ShieldConfiguration {
        // Lock icon (matching ActiveSessionScreen)
        // Primary color: #C86A1C (burnt orange)
        let primaryColor = UIColor(red: 200.0/255.0, green: 106.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        let lockImage = UIImage(systemName: "lock.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 60, weight: .regular))
            .withTintColor(primaryColor, renderingMode: .alwaysOriginal)

        // Background color matching design system (#F7F0E9 - warm beige)
        // Create fixed color that won't adapt to dark mode
        // Using color space to ensure exact color reproduction
        let backgroundColor = UIColor(
            red: 247.0/255.0,
            green: 240.0/255.0,
            blue: 233.0/255.0,
            alpha: 1.0
        )

        // Title: Aggressive, direct message
        let title = ShieldConfiguration.Label(
            text: "This app is distracting you",
            color: .black
        )

        // Subtitle: Actionable instruction
        let subtitle = ShieldConfiguration.Label(
            text: "Tap your drift to refocus",
            color: UIColor.black.withAlphaComponent(0.8)
        )

        // OK button with black background and white text
        let buttonLabel = ShieldConfiguration.Label(
            text: "OK",
            color: .white
        )

        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialLight,
            backgroundColor: backgroundColor,
            icon: lockImage,
            title: title,
            subtitle: subtitle,
            primaryButtonLabel: buttonLabel,
            primaryButtonBackgroundColor: .black,
            secondaryButtonLabel: nil
        )
    }

    // MARK: - Override Methods

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return createDriftShieldConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        return createDriftShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return createDriftShieldConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        return createDriftShieldConfiguration()
    }
}
