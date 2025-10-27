//
//  RegisteredTagsView.swift
//  Drift
//
//  Created by William Forkes on 20/10/2025.
//

import SwiftUI

struct RegisteredTagsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tagManager = DriftTagManager.shared
    @StateObject private var sessionManager = FocusSessionManager.shared
    @State private var editingTag: DriftTag?

    var body: some View {
        NavigationStack {
            List {
                if tagManager.tags.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "wave.3.right.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)

                            Text("No Drifts registered")
                                .font(.headline)

                            Text("Tap a Drift tag to set it up")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                } else {
                    ForEach(tagManager.tags) { tag in
                        Button(action: { editingTag = tag }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tag.label)
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    if let preset = sessionManager.presets.first(where: { $0.id == tag.presetId }) {
                                        Text(preset.name)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Text("ID: \(tag.id)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteTags)
                }
            }
            .navigationTitle("My Drifts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $editingTag) { tag in
                TagEditView(tag: tag)
            }
        }
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            let tag = tagManager.tags[index]
            tagManager.deleteTag(id: tag.id)
        }
    }
}

#Preview {
    RegisteredTagsView()
}
