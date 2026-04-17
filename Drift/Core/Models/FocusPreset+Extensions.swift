//
//  FocusPreset+Extensions.swift
//  Drift
//
//  Created by William Forkes on 06/11/2025.
//

import SwiftUI

// MARK: - Preset Identifier

struct PresetIdentifier: Identifiable {
    let id: String
}

// MARK: - FocusPreset Display Utilities

extension FocusPreset {
    var appCountText: String {
        if blocksAllApps {
            return "All apps"
        }

        let appCount = selection.applicationTokens.count
        let categoryCount = selection.categoryTokens.count

        if appCount > 0 && categoryCount > 0 {
            let appText = appCount == 1 ? "app" : "apps"
            let categoryText = categoryCount == 1 ? "category" : "categories"
            return "\(appCount) \(appText), \(categoryCount) \(categoryText)"
        } else if categoryCount > 0 {
            let categoryText = categoryCount == 1 ? "category" : "categories"
            return "\(categoryCount) \(categoryText)"
        } else if appCount > 0 {
            let appText = appCount == 1 ? "app" : "apps"
            return "\(appCount) \(appText)"
        } else {
            return "No apps"
        }
    }
}

// MARK: - Shared UI Components

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
