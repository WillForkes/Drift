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
    @State private var hasDetectedTag: Bool = false
    @State private var hasStartedScanning: Bool = false

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

                // Scan button or pill badge - positioned below center image
                if !hasStartedScanning {
                    DriftButton(title: "Tap to Scan", style: .primary) {
                        hasStartedScanning = true
                        nfcReader.startScanning()
                    }
                    .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) + 100 + 60)
                } else {
                    PillBadge(
                        text: pillBadgeText,
                        iconColor: pillBadgeIconColor,
                        iconSize: 8
                    )
                    .position(x: geometry.size.width / 2, y: (geometry.size.height / 2) + 100 + 60)
                }

                // Bottom button - Fixed distance from bottom
                VStack {
                    Spacer()

                    Button(action: {
                        print("I don't have a drift tapped")
                    }) {
                        HStack(spacing: DesignTokens.Spacing.medium) {
                            Text("I don't have a drift")
                                .bodySmall()
                                .underline()
                                .foregroundColor(DesignTokens.Colors.extraSubtext)

                            Image(systemName: "questionmark.circle")
                                .font(.system(size: DesignTokens.Typography.Size.bodySmall))
                                .foregroundColor(DesignTokens.Colors.extraSubtext)
                        }
                    }
                    .padding(.bottom, 50)
                    .background(Color(.clear))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                hasDetectedTag = false  // Reset flag for fresh scan
                hasStartedScanning = false  // Reset scanning state
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
                    hasDetectedTag = true  // Mark that we successfully detected a tag
                    onTagDetected(tagId)
                }
            }
            .onChange(of: nfcReader.isScanning) { oldValue, newValue in
                // Detect user cancellation (only if they started scanning)
                // If scanning stopped but no tag detected and no error, user cancelled
                let shouldCancel = hasStartedScanning &&
                                  !newValue &&
                                  !hasDetectedTag &&
                                  nfcReader.errorMessage == nil

                if shouldCancel {
                    print("ℹ️ [TapToStart] User cancelled NFC scan")
                    onCancelled()
                }
            }
            .overlay(
                // Error message overlay
                Group {
                    if let error = displayError {
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
                }
            )
        }
    }

    // MARK: - Computed Properties

    private enum ScanState {
        case detected
        case scanning
        case waiting
    }

    private var scanState: ScanState {
        if nfcReader.detectedTagId != nil {
            return .detected
        } else if nfcReader.isScanning {
            return .scanning
        } else {
            return .waiting
        }
    }

    private var displayError: String? {
        if let error = errorMessage, showError {
            return error
        } else if let nfcError = nfcReader.errorMessage {
            return nfcError
        }
        return nil
    }

    private var pillBadgeText: String {
        switch scanState {
        case .detected: return "Tap detected!"
        case .scanning: return "Scanning..."
        case .waiting: return "Waiting for tap"
        }
    }

    private var pillBadgeIconColor: Color {
        switch scanState {
        case .detected: return .green
        case .scanning: return .blue
        case .waiting: return .red
        }
    }
}

#Preview {
    TapToStartPage(onTagDetected: { tagId in
        print("Tag detected: \(tagId)")
    })
}
