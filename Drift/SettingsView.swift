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
    @State private var editingPreset: FocusPreset?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(sessionManager.presets) { preset in
                        Button(action: { handlePresetTap(preset) }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(preset.name)
                                        .foregroundColor(.primary)
                                    if preset.blocksAllApps {
                                        Text("Blocks all apps")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    } else if !preset.isConfigured {
                                        Text("Not configured")
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                }
                                Spacer()
                                if sessionManager.currentPreset?.id == preset.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Presets")
                } footer: {
                    Text("Tap a preset to select it. 'Social Media' and 'Work' can be configured with specific apps. 'All' automatically blocks every app including Drift (use NFC tag to exit).")
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
                            Text("https://get-drift.app/focus")
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
                if let preset = editingPreset {
                    sessionManager.updatePreset(preset, selection: newSelection)
                }
            }
        }
    }

    private func handlePresetTap(_ preset: FocusPreset) {
        if preset.blocksAllApps {
            // Just select "All" preset - no configuration needed
            sessionManager.selectPreset(preset)
        } else {
            // Select preset and show picker to configure
            editingPreset = preset
            selection = preset.selection
            sessionManager.selectPreset(preset)
            showingPicker = true
        }
    }
}

#Preview {
    SettingsView()
}
