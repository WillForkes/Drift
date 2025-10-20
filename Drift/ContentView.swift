//
//  ContentView.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = FocusSessionManager.shared
    @State private var showingSettings = false
    @State private var showingAuthError = false

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

                    if sessionManager.isSessionActive {
                        Text("Apps are blocked")
                            .font(.subheadline)
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
            .alert("Authorization Required", isPresented: $showingAuthError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please grant Screen Time permission to use Drift.")
            }
        }
    }

    private func toggleSession() {
        sessionManager.toggleSession()
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
