//
//  MainContainerView.swift
//  Drift
//
//  Created by Claude Code on 27/10/2025.
//

import SwiftUI

/// Main container view with swipeable pages
struct MainContainerView: View {
    @State private var currentPage: Int = 1 // Start on Home page (middle)

    var body: some View {
        ZStack {
            // Swipeable pages
            TabView(selection: $currentPage) {
                // Page 0: Analytics
                AnalyticsPage()
                    .tag(0)

                // Page 1: Home
                HomePage()
                    .tag(1)

                // Page 2: Settings
                SettingsPage()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            .safeAreaInset(edge: .top, spacing: 0) {
                // Spacer to push content below slide indicator
                Color.clear
                    .frame(height: DesignTokens.Spacing.pageContentTop)
            }

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
    }
}

#Preview {
    MainContainerView()
}
