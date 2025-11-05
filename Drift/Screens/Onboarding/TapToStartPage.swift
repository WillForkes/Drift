//
//  TapToStartPage.swift
//  Drift
//
//  Created by Claude Code on 04/11/2025.
//

import SwiftUI

struct TapToStartPage: View {
    @StateObject private var nfcReader = NFCReaderManager.shared
    let onTagDetected: (String) -> Void
    let onCancelled: () -> Void
    let errorMessage: String?

    @State private var showError: Bool = false

    init(
        onTagDetected: @escaping (String) -> Void = { _ in },
        onCancelled: @escaping () -> Void = {},
        errorMessage: String? = nil
    ) {
        self.onTagDetected = onTagDetected
        self.onCancelled = onCancelled
        self.errorMessage = errorMessage
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // Heading Section - Fixed 80px from top
                    VStack(spacing: DesignTokens.Spacing.medium) {
                        Text("Let's Get Started")
                            .heading1()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Start by tapping your phone onto drift")
                            .heading2()
                            .foregroundColor(DesignTokens.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
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

                // Pill badge - positioned below center image (dynamic based on NFC state)
                PillBadge(
                    text: pillBadgeText,
                    icon: pillBadgeIcon,
                    style: .light
                )
                .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) + 100 + 60)

                // Bottom button - Fixed distance from bottom
                VStack {
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
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                nfcReader.startScanning()
                // Show error if coming from sync failure
                if errorMessage != nil {
                    showError = true
                    // Auto-dismiss after 3 seconds
                    Task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        showError = false
                    }
                }
            }
            .onDisappear {
                nfcReader.stopScanning()
            }
            .onChange(of: nfcReader.detectedTagId) { newTagId in
                if let tagId = newTagId {
                    onTagDetected(tagId)
                }
            }
            .onChange(of: nfcReader.isScanning) { isScanning in
                // Detect user cancellation
                // If scanning stopped but no tag detected and no error, user cancelled
                if !isScanning && nfcReader.detectedTagId == nil && nfcReader.errorMessage == nil {
                    print("ℹ️ [TapToStart] User cancelled NFC scan")
                    onCancelled()
                }
            }
            .onChange(of: nfcReader.errorMessage) { error in
                if let error = error {
                    print("❌ [NFC] Error: \(error)")
                }
            }
            .overlay(
                // Error message overlay
                Group {
                    // Show sync error from parent (with auto-dismiss)
                    if let error = errorMessage, showError {
                        VStack {
                            Spacer()
                            Text(error)
                                .bodySmall()
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(DesignTokens.Radii.radiusStandard)
                                .padding()
                                .padding(.bottom, 120)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    // Show NFC error from manager
                    else if let nfcError = nfcReader.errorMessage {
                        VStack {
                            Spacer()
                            Text(nfcError)
                                .bodySmall()
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(DesignTokens.Radii.radiusStandard)
                                .padding()
                                .padding(.bottom, 120)
                        }
                    }
                }
            )
        }
    }

    // MARK: - Computed Properties

    private var pillBadgeText: String {
        if nfcReader.detectedTagId != nil {
            return "Tap detected!"
        } else if nfcReader.isScanning {
            return "Scanning..."
        } else {
            return "Waiting for tap"
        }
    }

    private var pillBadgeIcon: PillIcon {
        if nfcReader.detectedTagId != nil {
            return .systemImage(name: "checkmark", color: .green, size: 12)
        } else if nfcReader.isScanning {
            return .systemImage(name: "antenna.radiowaves.left.and.right", color: .blue, size: 12)
        } else {
            return .circle(color: .red, size: 12)
        }
    }
}

#Preview {
    TapToStartPage(onTagDetected: { tagId in
        print("Tag detected: \(tagId)")
    })
}
