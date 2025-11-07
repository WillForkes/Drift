//
//  SyncedWelcomePage.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct SyncedWelcomePage: View {
    let onComplete: () -> Void
    private let haptics = HapticManager.shared

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // Heading Section - Fixed 80px from top
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        Text("Synced!")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Let's start focusing.")
                            .heading2()
                            .foregroundColor(DesignTokens.Colors.subtext)
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

                // Get Started button - positioned below center image
                DriftButton(title: "Get Started", style: .primary) {
                    onComplete()
                }
                .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) + 100 + 70)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                haptics.success()
            }
        }
    }
}

#Preview {
    SyncedWelcomePage(onComplete: {
        print("Onboarding completed")
    })
}
