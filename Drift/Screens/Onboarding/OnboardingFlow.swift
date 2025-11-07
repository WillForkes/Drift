//
//  OnboardingFlow.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct OnboardingFlow: View {
    let onComplete: () -> Void
    let isAddingAnotherDrift: Bool
    @State private var currentPage: Int
    @State private var detectedTagId: String?
    @State private var driftName: String = ""
    @State private var syncError: String?
    private let totalPages = 4

    init(isAddingAnotherDrift: Bool = false, onComplete: @escaping () -> Void) {
        self.isAddingAnotherDrift = isAddingAnotherDrift
        self.onComplete = onComplete
        // Start on TapToStartPage when adding another drift, otherwise start on WelcomePage
        _currentPage = State(initialValue: isAddingAnotherDrift ? 1 : 0)
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

                    TapToStartPage(
                        onTagDetected: { tagId in
                            print("✅ [Onboarding] Tag detected: \(tagId)")
                            detectedTagId = tagId
                            syncError = nil // Clear any previous errors
                            // Wait 3 seconds for NFC dialog to dismiss before showing syncing page
                            Task {
                                try? await Task.sleep(nanoseconds: 3_000_000_000)
                                withAnimation {
                                    currentPage = 2
                                }
                            }
                        },
                        onCancelled: {
                            print("ℹ️ [Onboarding] User cancelled NFC scan")
                            // Only navigate back to welcome page if in initial onboarding
                            if !isAddingAnotherDrift {
                                withAnimation {
                                    currentPage = 0
                                }
                            }
                            // When adding another drift, user will dismiss the sheet manually
                        },
                        errorMessage: syncError
                    ).tag(1)

                    if let tagId = detectedTagId {
                        SyncingPage(
                            tagId: tagId,
                            driftName: $driftName,
                            onSuccess: {
                                print("✅ [Onboarding] Sync successful")
                                // Advance to synced welcome page
                                withAnimation {
                                    currentPage = 3
                                }
                            },
                            onError: { error in
                                print("❌ [Onboarding] Sync error: \(error)")
                                syncError = error
                                // Navigate back to tap to start page
                                withAnimation {
                                    currentPage = 1
                                }
                            }
                        )
                        .tag(2)
                    }

                    SyncedWelcomePage(onComplete: {
                        print("✅ [Onboarding] Completed - entering app")
                        onComplete()
                    })
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .highPriorityGesture(
                    // Block swipe gestures on pages 1, 2, and 3 (only allow on page 0)
                    currentPage != 0 ? DragGesture() : nil
                )

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
