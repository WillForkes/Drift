//
//  OnboardingFlow.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct OnboardingFlow: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @State private var detectedTagId: String?
    private let totalPages = 4

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            // Background color that changes based on current page
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top indicators
                SlideIndicator(currentPage: currentPage, totalPages: totalPages)
                    .padding(.top, 20)

                Spacer()

                // Content pages
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)

                    TapToStartPage(onTagDetected: { tagId in
                        print("✅ [Onboarding] Tag detected: \(tagId)")
                        detectedTagId = tagId
                        // Automatically advance to syncing page
                        withAnimation {
                            currentPage = 2
                        }
                    })
                        .tag(1)

                    SyncingPage()
                        .tag(2)

                    SyncedWelcomePage(onComplete: {
                        print("✅ [Onboarding] Completed - entering app")
                        onComplete()
                    })
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .disabled(currentPage != 0 && currentPage != 3) // Only allow swiping on first and last pages

                Spacer()
            }
        }
    }

    private var backgroundColor: Color {
        switch currentPage {
        case 2:
            return DesignTokens.Colors.primary // Orange for syncing page
        default:
            return DesignTokens.Colors.background // Light cream for other pages
        }
    }
}

#Preview {
    OnboardingFlow(onComplete: {
        print("Onboarding completed")
    })
}
