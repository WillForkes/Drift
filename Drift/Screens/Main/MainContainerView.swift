//
//  MainContainerView.swift
//  Drift
//
//

import SwiftUI

struct MainContainerView: View {
    @ObservedObject private var coordinator = NFCFocusCoordinator.shared
    @State private var currentPage: Int = 1

    var body: some View {
        ZStack {
            if coordinator.shouldShowActiveSession {
                ActiveSessionScreen()
            } else {
                TabView(selection: $currentPage) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: DesignTokens.Spacing.pageContentTop)
                        AnalyticsPage()
                    }
                    .background(DesignTokens.Colors.background)
                    .tag(0)

                    HomePage()
                        .tag(1)

                    VStack(spacing: 0) {
                        Spacer().frame(height: DesignTokens.Spacing.pageContentTop)
                        SettingsPage()
                    }
                    .background(DesignTokens.Colors.background)
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()

                VStack {
                    SlideIndicator(currentPage: currentPage)
                        .padding(.top, DesignTokens.Spacing.xxLarge)
                        .allowsHitTesting(false)

                    Spacer()
                }
                .allowsHitTesting(false)
            }
        }
        .onChange(of: coordinator.shouldShowActiveSession) { oldValue, newValue in
            withAnimation {
                if !newValue {
                    currentPage = 1
                }
            }
        }
    }
}

#Preview {
    MainContainerView()
}
