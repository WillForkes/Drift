//
//  OnboardingFlow.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct OnboardingFlow: View {
    @State private var currentPage = 0
    private let totalPages = 4
    
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
                    
                    TapToStartPage()
                        .tag(1)
                    
                    SyncingPage()
                        .tag(2)
                    
                    SyncedWelcomePage()
                        .tag(3)
                    
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .disabled(currentPage != 0) // Only allow swiping on first page
                
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

// MARK: - Individual Pages
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxxLarge) {
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.large) {
                Text("Welcome to")
                    .heading1()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Text("drift")
                    .headingXL()
                    .foregroundColor(DesignTokens.Colors.primary)
            }
            
            Spacer()
            
            HStack(spacing: DesignTokens.Spacing.medium) {
                Text("Swipe to get started")
                    .bodySmall()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: DesignTokens.Typography.Size.bodySmall))
                    .foregroundColor(DesignTokens.Colors.textPrimary)
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SyncedWelcomePage: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxxLarge) {
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.large) {
                Text("Synced!")
                    .heading1()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("Let's start focusing.")
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.subtext)
            }
            
            Spacer()
            
            // Drift device image
            Image("above")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
            
            Spacer()
            
            DriftButton(title: "Get Started", style: .primary) {
                print("Get Started tapped")
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SyncingPage: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxxLarge) {
            Spacer()
            
            Text("Syncing...")
                .heading1()
                .foregroundColor(DesignTokens.Colors.whiteText)
            
            Spacer()
            
            // Drift device image
            Image("above")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
            
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.large) {
                PillBadge(
                    text: "NFC Chip valid",
                    icon: .systemImage(name: "checkmark", color: .green, size: 14),
                    style: .light
                )
                
                PillBadge(
                    text: "Authorizing",
                    icon: .circle(color: .yellow, size: 12),
                    style: .transparent
                )
                
                PillBadge(
                    text: "Finishing up...",
                    icon: .systemImage(name: "arrow.clockwise", color: .white.opacity(0.7), size: 12),
                    style: .transparent
                )
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TapToStartPage: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xxxLarge) {
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.medium) {
                Text("Let's Get Started")
                    .heading1()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Text("Start by tapping your phone onto drift")
                    .heading2()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            
            Spacer()
            
            // Drift device in perspective view
            Image("above")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
            
            Spacer()
            
            PillBadge(
                text: "Waiting for tap",
                icon: .circle(color: .red, size: 12),
                style: .light
            )
            
            Spacer()
            
            Button(action: {
                print("I don't have a drift tapped")
            }) {
                HStack(spacing: DesignTokens.Spacing.medium) {
                    Text("I don't have a drift")
                        .bodySmall()
                        .foregroundColor(DesignTokens.Colors.extraSubtext)
                    
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: DesignTokens.Typography.Size.bodySmall))
                        .foregroundColor(DesignTokens.Colors.extraSubtext)
                }
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



#Preview {
    OnboardingFlow()
}
