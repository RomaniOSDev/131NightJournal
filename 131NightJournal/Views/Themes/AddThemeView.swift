//
//  AddThemeView.swift
//  131NightJournal
//

import SwiftUI

struct AddThemeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NightJournalViewModel

    @State private var name = ""
    @State private var description = ""
    @State private var selectedEntryIds = Set<UUID>()

    var body: some View {
        NavigationStack {
            ZStack {
                NightScreenBackground()
                    .ignoresSafeArea()
                Form {
                    Section {
                        TextField("Name", text: $name)
                            .foregroundColor(.nightText)
                            .tint(.nightAccent)
                        TextField("Description", text: $description, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundColor(.nightText)
                            .tint(.nightAccent)
                    }
                    Section {
                        ForEach(viewModel.sortedEntries) { entry in
                            Toggle(isOn: Binding(
                                get: { selectedEntryIds.contains(entry.id) },
                                set: { on in
                                    if on { selectedEntryIds.insert(entry.id) }
                                    else { selectedEntryIds.remove(entry.id) }
                                }
                            )) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.title)
                                        .foregroundColor(.nightText)
                                    Text(entry.formattedDate)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .tint(.nightAccent)
                        }
                    } header: {
                        Text("Entries in this theme").foregroundColor(.gray)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .foregroundColor(.nightText)
            .navigationTitle("New theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.nightAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.nightAccent)
                        .bold()
                }
            }
            .toolbarBackground(
                LinearGradient(
                    colors: [Color.nightBackground, Color.nightBackground.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
        }
    }

    private func save() {
        let theme = NightTheme(
            id: UUID(),
            name: name.isEmpty ? "Untitled theme" : name,
            description: description,
            entries: Array(selectedEntryIds)
        )
        viewModel.addTheme(theme)
        dismiss()
    }
}
