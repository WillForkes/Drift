//
//  ContentView.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = FocusSessionManager.shared
    @StateObject private var parentalControls = ParentalControlsManager.shared
    @State private var showingSettings = false
    @State private var showingAuthError = false
    @State private var showingConfigError = false
    @State private var showingPasscodeEntry = false
    @State private var showingForgotPasscode = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Session Status Indicator
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(sessionManager.isSessionActive ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)

                        Image(systemName: sessionManager.isSessionActive ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }

                    Text(sessionManager.isSessionActive ? "Focus Active" : "Not Focused")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if let preset = sessionManager.currentPreset {
                        Text(preset.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if sessionManager.isSessionActive {
                        Text("Apps are blocked")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Controls
                VStack(spacing: 16) {
                    if !sessionManager.isAuthorized {
                        // Authorization Request Button
                        Button(action: requestAuthorization) {
                            HStack {
                                Image(systemName: "lock.shield")
                                Text("Enable App Blocking")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        Text("Required for Drift to block apps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        // Test Toggle Button (for development)
                        Button(action: toggleSession) {
                            HStack {
                                Image(systemName: sessionManager.isSessionActive ? "stop.circle" : "play.circle")
                                Text(sessionManager.isSessionActive ? "End Session (Test)" : "Start Session (Test)")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(sessionManager.isSessionActive ? Color.red : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        Text("Tap your NFC tag to toggle sessions normally")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Drift")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                    }
                    .disabled(!sessionManager.isAuthorized)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPasscodeEntry) {
                PasscodeEntryView(
                    title: "Enter Passcode to Stop Session",
                    onSuccess: stopSessionAfterPasscode,
                    onForgot: {
                        showingPasscodeEntry = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingForgotPasscode = true
                        }
                    }
                )
            }
            .sheet(isPresented: $showingForgotPasscode) {
                SecurityQuestionRecoveryView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .nfcStopRequested)) { _ in
                // NFC tag tapped to stop session, show passcode entry
                showingPasscodeEntry = true
            }
            .alert("Authorization Required", isPresented: $showingAuthError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please grant Screen Time permission to use Drift.")
            }
            .alert("Configure Preset", isPresented: $showingConfigError) {
                Button("Open Settings", role: .none) {
                    showingSettings = true
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                if let preset = sessionManager.currentPreset {
                    Text("Please configure the '\(preset.name)' preset in Settings before starting a session.")
                } else {
                    Text("Please select and configure a preset in Settings.")
                }
            }
        }
    }

    private func toggleSession() {
        // Check if we're starting a session
        if !sessionManager.isSessionActive {
            // Validate preset is configured before starting
            if let preset = sessionManager.currentPreset, !preset.isConfigured {
                showingConfigError = true
                return
            } else if sessionManager.currentPreset == nil {
                showingConfigError = true
                return
            }
            // Start session immediately
            sessionManager.toggleSession()
        } else {
            // Stopping session - check if parental controls enabled
            if parentalControls.isEnabled {
                showingPasscodeEntry = true
            } else {
                sessionManager.toggleSession()
            }
        }
    }

    private func stopSessionAfterPasscode() {
        sessionManager.stopSession()
    }

    private func requestAuthorization() {
        Task {
            do {
                try await sessionManager.requestAuthorization()
            } catch {
                showingAuthError = true
            }
        }
    }
}

#Preview {
    ContentView()
}
