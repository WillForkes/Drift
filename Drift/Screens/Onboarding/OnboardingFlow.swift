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
                    
                    SyncingPage()
                        .tag(1)
                    
                    SyncedWelcomePage()
                        .tag(2)
                    
                    TapToStartPage()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .disabled(true) // Disable swiping as requested
                
                Spacer()
                
                // Debug navigation arrows
                HStack {
                    Button(action: {
                        if currentPage > 0 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .opacity(currentPage > 0 ? 1.0 : 0.3)
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < totalPages - 1 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .clipShape(Circle())
                    }
                    .opacity(currentPage < totalPages - 1 ? 1.0 : 0.3)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
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
                    .heading1()
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
                Text("Synced! Welcome to")
                    .heading1()
                    .foregroundColor(DesignTokens.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text("drift")
                    .heading1()
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(DesignTokens.Colors.primary)
            }
            
            Spacer()
            
            // Drift device mockup
            DriftDeviceMockup()
            
            Spacer()
            
            DriftButton(title: "Get Started", style: .pill) {
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
                .font(.system(size: 32, weight: .regular, design: .default))
                .foregroundColor(.white)
            
            Spacer()
            
            // Drift device mockup
            DriftDeviceMockup()
            
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.large) {
                SyncStatusRow(text: "NFC Chip valid", status: .complete)
                SyncStatusRow(text: "Authorizing", status: .inProgress)
                SyncStatusRow(text: "Finishing up...", status: .pending)
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
            
            Text("To get started, tap your phone onto drift")
                .heading1()
                .foregroundColor(DesignTokens.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Drift device in perspective view
            DriftDevicePerspective()
            
            Spacer()
            
            VStack(spacing: DesignTokens.Spacing.xLarge) {
                HStack(spacing: DesignTokens.Spacing.medium) {
                    Circle()
                        .fill(DesignTokens.Colors.primary)
                        .frame(width: 8, height: 8)
                    
                    Text("Waiting for tap...")
                        .bodySmall()
                        .foregroundColor(DesignTokens.Colors.textPrimary)
                }
                
                Button(action: {
                    print("I don't have a drift tapped")
                }) {
                    HStack(spacing: DesignTokens.Spacing.medium) {
                        Text("I don't have a drift")
                            .bodySmall()
                            .foregroundColor(DesignTokens.Colors.textPrimary.opacity(0.6))
                        
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: DesignTokens.Typography.Size.bodySmall))
                            .foregroundColor(DesignTokens.Colors.textPrimary.opacity(0.6))
                    }
                }
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Supporting Views

struct DriftDeviceMockup: View {
    var body: some View {
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
                .frame(width: 140, height: 140)
                .offset(x: 8, y: 8)
            
            // Main device
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.8, green: 0.6, blue: 0.4),
                            Color(red: 0.7, green: 0.5, blue: 0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
            
            // Inner border
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.2), lineWidth: 2)
                .frame(width: 120, height: 120)
            
            // Drift text
            Text("drift")
                .bodySmall()
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
    }
}

struct DriftDevicePerspective: View {
    var body: some View {
        ZStack {
            // Shadow
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.3))
                .frame(width: 180, height: 140)
                .offset(x: 10, y: 10)
                .rotation3DEffect(
                    .degrees(-15),
                    axis: (x: 1, y: 0, z: 0)
                )
            
            // Main device
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.8, green: 0.6, blue: 0.4),
                            Color(red: 0.7, green: 0.5, blue: 0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 180, height: 140)
                .rotation3DEffect(
                    .degrees(-15),
                    axis: (x: 1, y: 0, z: 0)
                )
            
            // Top edge highlight
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.3))
                .frame(width: 180, height: 8)
                .offset(y: -66)
                .rotation3DEffect(
                    .degrees(-15),
                    axis: (x: 1, y: 0, z: 0)
                )
            
            // Drift text
            Text("drift")
                .body()
                .fontWeight(.bold)
                .foregroundColor(.black)
                .rotation3DEffect(
                    .degrees(-15),
                    axis: (x: 1, y: 0, z: 0)
                )
                .offset(y: -5)
        }
    }
}

struct SyncStatusRow: View {
    let text: String
    let status: SyncStatus
    
    enum SyncStatus {
        case complete
        case inProgress
        case pending
    }
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.medium) {
            statusIcon
            
            Text(text)
                .bodySmall()
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.2))
        .cornerRadius(25)
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .complete:
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.green)
        case .inProgress:
            Circle()
                .fill(Color.yellow)
                .frame(width: 12, height: 12)
        case .pending:
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#Preview {
    OnboardingFlow()
}
