//
//  ShieldConfigurationExtension.swift
//  DriftShieldConfiguration
//
//  Created by William Forkes on 20/10/2025.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Provides custom shield configuration for blocked apps
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield for blocked applications
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "moon.fill"),
            title: ShieldConfiguration.Label(
                text: "This app is a distraction.",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Tap your Drift tag to end your focus session.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: nil,
            primaryButtonBackgroundColor: nil,
            secondaryButtonLabel: nil
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield for blocked application categories
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "moon.fill"),
            title: ShieldConfiguration.Label(
                text: "This app is a distraction.",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Tap your Drift tag to end your focus session.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: nil,
            primaryButtonBackgroundColor: nil,
            secondaryButtonLabel: nil
        )
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield for blocked web domains
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "moon.fill"),
            title: ShieldConfiguration.Label(
                text: "This site is a distraction.",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Tap your Drift tag to end your focus session.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: nil,
            primaryButtonBackgroundColor: nil,
            secondaryButtonLabel: nil
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield for blocked web domain categories
        return ShieldConfiguration(
            backgroundBlurStyle: .systemMaterial,
            backgroundColor: UIColor.systemBackground,
            icon: UIImage(systemName: "moon.fill"),
            title: ShieldConfiguration.Label(
                text: "This site is a distraction.",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Tap your Drift tag to end your focus session.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: nil,
            primaryButtonBackgroundColor: nil,
            secondaryButtonLabel: nil
        )
    }
}
