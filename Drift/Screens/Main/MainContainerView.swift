//
//  MainContainerView.swift
//  Drift
//
//  Created by Claude Code on 27/10/2025.
//

import SwiftUI

/// Main container view with swipeable pages
struct MainContainerView: View {
    @ObservedObject private var coordinator = NFCFocusCoordinator.shared
    @State private var currentPage: Int = 1 // Start on Home page (middle)

    var body: some View {
        ZStack {
            // Swipeable pages
            TabView(selection: $currentPage) {
                // Page 0: Analytics
                VStack(spacing: 0) {
                    Spacer().frame(height: DesignTokens.Spacing.pageContentTop)
                    AnalyticsPage()
                }
                .background(DesignTokens.Colors.background)
                .tag(0)

                // Page 1: Home (no top spacing - keeps centered layout)
                HomePage()
                    .tag(1)

                // Page 2: Settings
                VStack(spacing: 0) {
                    Spacer().frame(height: DesignTokens.Spacing.pageContentTop)
                    SettingsPage()
                }
                .background(DesignTokens.Colors.background)
                .tag(2)

                // Page 3: Active Session
                ActiveSessionScreen()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            // Fixed UI elements overlaid on top
            VStack {
                // Slide Indicator - Fixed at top
                SlideIndicator(currentPage: currentPage)
                    .padding(.top, DesignTokens.Spacing.xxLarge)
                    .allowsHitTesting(false) // Let swipes pass through

                Spacer()
            }
            .allowsHitTesting(false)
        }
        .onChange(of: coordinator.shouldShowActiveSession) { oldValue, newValue in
            withAnimation {
                if newValue {
                    // Navigate to Active Session screen
                    currentPage = 3
                } else {
                    // Navigate back to Home
                    currentPage = 1
                }
            }
        }
    }
}

#Preview {
    MainContainerView()
}
