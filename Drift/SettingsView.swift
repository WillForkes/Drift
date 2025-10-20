//
//  SettingsView.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI
import FamilyControls

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sessionManager = FocusSessionManager.shared
    @State private var selection = FamilyActivitySelection()
    @State private var showingPicker = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button(action: { showingPicker = true }) {
                        HStack {
                            Label("Select Apps to Block", systemImage: "app.badge.checkmark")
                                .foregroundColor(.primary)
                            Spacer()
                            if !selection.applicationTokens.isEmpty || !selection.categoryTokens.isEmpty {
                                Text("\(selection.applicationTokens.count) apps")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Blocked Apps")
                } footer: {
                    Text("Choose which apps to block during focus sessions. You can select individual apps or entire categories.")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("NFC Tag Setup", systemImage: "wave.3.right")
                            .font(.headline)

                        Text("To use Drift with NFC:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("1. Write this URL to your NFC tag:")
                                .font(.caption)
                            Text("https://drift.app/focus")
                                .font(.caption.monospaced())
                                .foregroundColor(.blue)

                            Text("2. Tap the tag to start/stop sessions")
                                .font(.caption)
                                .padding(.top, 4)
                        }
                        .padding(.leading)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("NFC Configuration")
                } footer: {
                    Text("You'll need an NFC tag and an NFC writing app to set this up. Once configured, tapping the tag will toggle your focus sessions.")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .familyActivityPicker(
                isPresented: $showingPicker,
                selection: $selection
            )
            .onChange(of: selection) { _, newSelection in
                sessionManager.saveBlockedApps(newSelection)
            }
            .onAppear {
                selection = sessionManager.getBlockedApps()
            }
        }
    }
}

#Preview {
    SettingsView()
}
