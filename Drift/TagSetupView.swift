//
//  TagSetupView.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

/// Setup flow for registering a new Drift tag
struct TagSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tagManager = DriftTagManager.shared
    @StateObject private var sessionManager = FocusSessionManager.shared

    let tagId: String
    let onComplete: () -> Void

    @State private var label: String = ""
    @State private var selectedPresetId: String = ""
    @State private var showError: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Tag ID: \(tagId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Drift Tag")
                }

                Section {
                    TextField("Label (e.g., Kitchen, Bedroom)", text: $label)
                } header: {
                    Text("Give it a name")
                } footer: {
                    Text("Choose a name to identify where this Drift is located.")
                }

                Section {
                    Picker("Preset", selection: $selectedPresetId) {
                        ForEach(sessionManager.presets) { preset in
                            Text(preset.name).tag(preset.id)
                        }
                    }
                } header: {
                    Text("Choose Preset")
                } footer: {
                    Text("This preset will be activated when you tap this Drift.")
                }

                if showError {
                    Section {
                        Text("Please enter a label for this Drift.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button("Save & Start Session") {
                        saveAndStart()
                    }
                    .disabled(label.isEmpty)
                }
            }
            .navigationTitle("Setup Drift")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Pre-select first preset
                if let firstPreset = sessionManager.presets.first {
                    selectedPresetId = firstPreset.id
                }
            }
        }
    }

    private func saveAndStart() {
        guard !label.isEmpty else {
            showError = true
            return
        }

        // Register the tag
        tagManager.registerTag(id: tagId, label: label, presetId: selectedPresetId)

        // Dismiss and trigger session start
        dismiss()
        onComplete()
    }
}

/// Edit an existing tag
struct TagEditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tagManager = DriftTagManager.shared
    @StateObject private var sessionManager = FocusSessionManager.shared

    let tag: DriftTag

    @State private var label: String
    @State private var selectedPresetId: String
    @State private var showError: Bool = false

    init(tag: DriftTag) {
        self.tag = tag
        _label = State(initialValue: tag.label)
        _selectedPresetId = State(initialValue: tag.presetId)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Tag ID: \(tag.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Drift Tag")
                }

                Section {
                    TextField("Label", text: $label)
                } header: {
                    Text("Name")
                }

                Section {
                    Picker("Preset", selection: $selectedPresetId) {
                        ForEach(sessionManager.presets) { preset in
                            Text(preset.name).tag(preset.id)
                        }
                    }
                } header: {
                    Text("Preset")
                }

                if showError {
                    Section {
                        Text("Please enter a label.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                Section {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .disabled(label.isEmpty)
                }
            }
            .navigationTitle("Edit Drift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        guard !label.isEmpty else {
            showError = true
            return
        }

        tagManager.updateTag(id: tag.id, label: label, presetId: selectedPresetId)
        dismiss()
    }
}

#Preview {
    TagSetupView(tagId: "1234", onComplete: {})
}
