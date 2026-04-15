//
//  AddEntryView.swift
//  131NightJournal
//

import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NightJournalViewModel

    @State private var title: String
    @State private var content: String
    @State private var mood: Mood = .peaceful
    @State private var category: NightCategory = .thoughts
    @State private var tagsString = ""
    @State private var isFavorite = false
    @State private var isPrivate = false

    init(viewModel: NightJournalViewModel, initialTitle: String = "", initialContent: String = "") {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        _title = State(initialValue: initialTitle)
        _content = State(initialValue: initialContent)
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
            .navigationTitle("New entry")
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
        let entry = NightEntry(
            id: UUID(),
            date: Date(),
            title: title.isEmpty ? "Untitled" : title,
            content: content,
            mood: mood,
            category: category,
            tags: tags,
            isFavorite: isFavorite,
            isPrivate: isPrivate,
            createdAt: Date()
        )
        viewModel.addEntry(entry)
        dismiss()
    }
}
