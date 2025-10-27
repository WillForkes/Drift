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
    @StateObject private var parentalControls = ParentalControlsManager.shared
    @StateObject private var tagManager = DriftTagManager.shared
    @State private var selection = FamilyActivitySelection()
    @State private var showingPicker = false
    @State private var editingPreset: FocusPreset?
    @State private var showingParentalSetup = false
    @State private var showingDisableConfirm = false
    @State private var showingRegisteredTags = false

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
                    HStack {
                        Text("Parental Controls")
                        Spacer()
                        Text(parentalControls.isEnabled ? "Enabled" : "Disabled")
                            .foregroundColor(.secondary)
                    }

                    if parentalControls.isEnabled {
                        Button("Disable", role: .destructive) {
                            showingDisableConfirm = true
                        }
                    } else {
                        Button("Set Up") {
                            showingParentalSetup = true
                        }
                    }
                } header: {
                    Text("Parental Controls")
                } footer: {
                    Text("When enabled, a passcode will be required to stop focus sessions. This prevents you from easily ending a session.")
                }

                Section {
                    Button(action: { showingRegisteredTags = true }) {
                        HStack {
                            Label("My Drifts", systemImage: "wave.3.right")
                                .foregroundColor(.primary)
                            Spacer()
                            if !tagManager.tags.isEmpty {
                                Text("\(tagManager.tags.count)")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Drift Tags")
                } footer: {
                    Text("Manage your registered Drift tags. Tap a Drift tag to set it up for the first time.")
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
            .sheet(isPresented: $showingParentalSetup) {
                ParentalControlsSetupView()
            }
            .sheet(isPresented: $showingRegisteredTags) {
                RegisteredTagsView()
            }
            .alert("Disable Parental Controls", isPresented: $showingDisableConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Disable", role: .destructive) {
                    parentalControls.disable()
                }
            } message: {
                Text("Are you sure you want to disable parental controls? You will no longer need a passcode to stop sessions.")
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
