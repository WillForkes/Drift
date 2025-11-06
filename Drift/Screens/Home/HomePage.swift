//
//  HomePage.swift
//  Drift
//
//  Created by Claude Code on 28/10/2025.
//

import SwiftUI

struct HomePage: View {
    @ObservedObject private var sessionManager = FocusSessionManager.shared
    @ObservedObject private var nfcReader = NFCReaderManager.shared
    @ObservedObject private var driftManager = DriftTagManager.shared
    @ObservedObject private var coordinator = NFCFocusCoordinator.shared

    @State private var selectedDriftId: String?
    @State private var showError = false
    @State private var errorMessage = ""

    let imageSize = UIScreen.main.bounds.width * 0.6

    private var driftName: String {
        guard let id = selectedDriftId,
              let drift = driftManager.getTag(by: id) else {
            return "Drift Name"
        }
        return drift.label
    }

    private var headingText: String {
        if sessionManager.isSessionActive {
            return "Session Active"
        } else {
            return "Tap drift to activate"
        }
    }

    var body: some View {
        ZStack {
            // Background
            DesignTokens.Colors.background
                .ignoresSafeArea()

            // Main Content - Image centered, text above
            VStack(spacing: DesignTokens.Spacing.xLarge) {
                // Drift Selector
                DriftSelector(selectedDriftId: $selectedDriftId)

                // Heading text
                Text(headingText)
                    .heading1()
                    .foregroundColor(DesignTokens.Colors.textPrimary)

                Spacer()
                    .frame(height: DesignTokens.Spacing.xxxLarge)

                // Square Image - Centered and tappable
                Image("above")
                    .resizable()
                    .scaledToFill()
                    .frame(width: imageSize, height: imageSize)
                    .opacity(nfcReader.isScanning ? 0.6 : 1.0)
                    .scaleEffect(nfcReader.isScanning ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: nfcReader.isScanning)
                    .onTapGesture {
                        startManualNFCScan()
                    }
            }
            .padding(.large)
            .offset(y: -30)

            // Bottom Preset Slider - Fixed at bottom
            VStack {
                Spacer()
                BottomPresetSlider(selectedDriftId: $selectedDriftId)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Initialize selectedDriftId on first load
            if selectedDriftId == nil {
                // If only 1 drift, auto-select it
                if driftManager.tags.count == 1 {
                    selectedDriftId = driftManager.tags.first?.id
                } else if let firstDrift = driftManager.tags.first {
                    // Multiple drifts - select the first one by default
                    selectedDriftId = firstDrift.id
                }
            }
        }
    }

    // MARK: - Methods

    private func startManualNFCScan() {
        print("📱 [HomePage] Starting manual NFC scan")

        nfcReader.startScanning { result in
            switch result {
            case .success(let tagId):
                print("✅ [HomePage] Tag detected: \(tagId)")
                handleTagDetection(tagId: tagId)

            case .failure(let error):
                print("❌ [HomePage] Scan failed: \(error.localizedDescription)")
                // Don't show error for user cancellation
                if case .userCancelled = error {
                    return
                }
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func handleTagDetection(tagId: String) {
        let result = coordinator.handleTagDetection(tagId: tagId)

        switch result {
        case .success(let action):
            switch action {
            case .started(let driftName, let presetName):
                print("▶️ [HomePage] Session started: \(driftName) - \(presetName)")

            case .stopped:
                print("⏹️ [HomePage] Session stopped")
            }

        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    HomePage()
}
