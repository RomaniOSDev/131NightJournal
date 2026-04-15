//
//  EditEntryView.swift
//  131NightJournal
//

import SwiftUI

struct EditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NightJournalViewModel

    @State private var title: String
    @State private var content: String
    @State private var mood: Mood
    @State private var category: NightCategory
    @State private var tagsString: String
    @State private var isFavorite: Bool
    @State private var isPrivate: Bool

    private let entryId: UUID
    private let date: Date
    private let createdAt: Date

    init(viewModel: NightJournalViewModel, entry: NightEntry) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        entryId = entry.id
        date = entry.date
        createdAt = entry.createdAt
        _title = State(initialValue: entry.title)
        _content = State(initialValue: entry.content)
        _mood = State(initialValue: entry.mood)
        _category = State(initialValue: entry.category)
        _tagsString = State(initialValue: entry.tags.joined(separator: ", "))
        _isFavorite = State(initialValue: entry.isFavorite)
        _isPrivate = State(initialValue: entry.isPrivate)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NightScreenBackground()
                    .ignoresSafeArea()
                Form {
                    Section {
                        TextField("Title", text: $title)
                            .foregroundColor(.nightText)
                            .tint(.nightAccent)
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .foregroundColor(.nightText)
                            .tint(.nightAccent)
                    }
                    Section {
                        Picker("Mood", selection: $mood) {
                            ForEach(Mood.allCases, id: \.self) { m in
                                Label(m.rawValue, systemImage: m.icon).tag(m)
                            }
                        }
                        .tint(.nightAccent)
                    } header: {
                        Text("Mood").foregroundColor(.gray)
                    }
                    Section {
                        Picker("Category", selection: $category) {
                            ForEach(NightCategory.allCases, id: \.self) { cat in
                                Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                            }
                        }
                        .tint(.nightAccent)
                    } header: {
                        Text("Category").foregroundColor(.gray)
                    }
                    Section {
                        TextField("Tags, comma-separated", text: $tagsString)
                            .foregroundColor(.nightText)
                            .tint(.nightAccent)
                    } header: {
                        Text("Tags").foregroundColor(.gray)
                    }
                    Section {
                        Toggle("Add to favorites", isOn: $isFavorite)
                            .tint(.nightAccent)
                        Toggle("Private entry", isOn: $isPrivate)
                            .tint(.nightAccent)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .foregroundColor(.nightText)
            .navigationTitle("Edit entry")
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
        let tags = tagsString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let updated = NightEntry(
            id: entryId,
            date: date,
            title: title.isEmpty ? "Untitled" : title,
            content: content,
            mood: mood,
            category: category,
            tags: tags,
            isFavorite: isFavorite,
            isPrivate: isPrivate,
            createdAt: createdAt
        )
        viewModel.updateEntry(updated)
        dismiss()
    }
}
