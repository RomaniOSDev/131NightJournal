//
//  JournalFeedView.swift
//  131NightJournal
//

import Combine
import SwiftUI

struct JournalFeedView: View {
    @ObservedObject var viewModel: NightJournalViewModel
    @State private var showAddEntrySheet = false
    @State private var showInspirationLibrary = false
    @State private var addEntryInitialContent = ""
    @State private var addEntrySession = UUID()
    @State private var now = Date()

    private let clock = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    headerBlock
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.nightBackground)
                        .listRowSeparator(.hidden)
                }

                Section {
                    ForEach(viewModel.sortedEntries) { entry in
                        NavigationLink(value: entry.id) {
                            EntryCard(entry: entry)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(.nightAccent.opacity(0.3))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteEntry(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                viewModel.toggleFavorite(entry)
                            } label: {
                                Label("Favorite", systemImage: "star")
                            }
                            .tint(.nightAccent)
                        }
                    }
                }
                .listRowSeparator(.visible)

                Section {
                    Button {
                        openNewEntry(prefill: "")
                    } label: {
                        Text("Write a new entry")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [Color.nightAccent, Color.nightAccent.opacity(0.82)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.nightBackground)
                    .shadow(color: Color.nightAccent.opacity(0.35), radius: 8, x: 0, y: 4)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .nightScreenBackdrop()
            .navigationDestination(for: UUID.self) { id in
                if let entry = viewModel.entry(id: id) {
                    EntryDetailView(entry: entry, viewModel: viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showInspirationLibrary = true
                    } label: {
                        Image(systemName: "text.quote")
                            .foregroundColor(.nightAccent)
                    }
                    .accessibilityLabel("Inspiration library")
                }
            }
            .sheet(isPresented: $showAddEntrySheet) {
                AddEntryView(viewModel: viewModel, initialContent: addEntryInitialContent)
                    .id(addEntrySession)
            }
            .sheet(isPresented: $showInspirationLibrary) {
                InspirationLibraryView(viewModel: viewModel)
            }
            .onReceive(clock) { _ in now = Date() }
        }
    }

    private func openNewEntry(prefill: String) {
        addEntryInitialContent = prefill
        addEntrySession = UUID()
        showAddEntrySheet = true
    }

    private var headerBlock: some View {
        let vm = viewModel
        return VStack(alignment: .leading, spacing: 16) {
            Text("Journal")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.nightAccent, Color.nightAccent.opacity(0.75)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(headerDateTime)
                .font(.subheadline)
                .foregroundColor(.nightText.opacity(0.85))

            if let prompt = vm.dailyPrompt {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(.nightAccent)
                        Text("Today's prompt")
                            .font(.caption)
                            .foregroundColor(.nightAccent)
                    }
                    Text(prompt.text)
                        .font(.body)
                        .foregroundColor(.nightText)
                    Button {
                        openNewEntry(prefill: prompt.text + "\n\n")
                    } label: {
                        Text("Write with this prompt")
                            .font(.subheadline)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundColor(.nightBackground)
                            .nightPrimaryButtonShape(cornerRadius: 10)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .nightInsetPanel(cornerRadius: 12)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StatCard(
                        title: "Total entries",
                        value: "\(vm.totalEntries)",
                        icon: "book.fill",
                        color: .nightAccent
                    )
                    .frame(width: 160)
                    StatCard(
                        title: "Day streak",
                        value: "\(vm.streakDays)",
                        icon: "flame.fill",
                        color: .nightAccent
                    )
                    .frame(width: 160)
                    StatCard(
                        title: "This month",
                        value: "\(vm.monthlyEntries)",
                        icon: "calendar",
                        color: .nightAccent
                    )
                    .frame(width: 160)
                    StatCard(
                        title: "Top tag",
                        value: vm.mostUsedTag.isEmpty ? "—" : "#\(vm.mostUsedTag)",
                        icon: "tag.fill",
                        color: .nightAccent
                    )
                    .frame(width: 160)
                }
            }

            if let quote = vm.nightQuote {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "quote.opening")
                            .foregroundColor(.nightAccent)
                        Text("Quote of the night")
                            .font(.caption)
                            .foregroundColor(.nightAccent)
                        if vm.quotes.contains(where: { $0.isFavorite }) {
                            Text("(favorites)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    Text(quote.text)
                        .font(.subheadline)
                        .foregroundColor(.nightText)
                        .italic()
                    Text("— \(quote.author)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .nightInsetPanel(cornerRadius: 12)
            }
        }
        .padding(.vertical, 8)
    }

    private var headerDateTime: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: now)
    }
}

// MARK: - Inspiration library (same file ensures the type is always compiled with this target)

struct QuoteEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let quoteId: UUID
    private let isNew: Bool
    var onSave: (NightQuote) -> Void

    @State private var text: String
    @State private var author: String
    @State private var isFavorite: Bool

    init(quote: NightQuote, isNew: Bool, onSave: @escaping (NightQuote) -> Void) {
        quoteId = quote.id
        self.isNew = isNew
        self.onSave = onSave
        _text = State(initialValue: quote.text)
        _author = State(initialValue: quote.author)
        _isFavorite = State(initialValue: quote.isFavorite)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NightScreenBackground()
                    .ignoresSafeArea()
                Form {
                    Section {
                        TextField("Quote", text: $text, axis: .vertical)
                            .lineLimit(4...12)
                            .foregroundColor(.nightText)
                            .tint(.nightAccent)
                        TextField("Author", text: $author)
                            .foregroundColor(.nightText)
                            .tint(.nightAccent)
                    }
                    Section {
                        Toggle("Favorite (include in rotation)", isOn: $isFavorite)
                            .tint(.nightAccent)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .foregroundColor(.nightText)
            .navigationTitle(isNew ? "New quote" : "Edit quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.nightAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let q = NightQuote(
                            id: quoteId,
                            text: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "…" : text,
                            author: author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unknown" : author,
                            isFavorite: isFavorite
                        )
                        onSave(q)
                        dismiss()
                    }
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
}

struct PromptEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let promptId: UUID
    private let isNew: Bool
    var onSave: (NightPrompt) -> Void

    @State private var text: String

    init(prompt: NightPrompt, isNew: Bool, onSave: @escaping (NightPrompt) -> Void) {
        promptId = prompt.id
        self.isNew = isNew
        self.onSave = onSave
        _text = State(initialValue: prompt.text)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NightScreenBackground()
                    .ignoresSafeArea()
                Form {
                    Section {
                        TextField("Prompt", text: $text, axis: .vertical)
                            .lineLimit(3...10)
                            .foregroundColor(.nightText)
                            .tint(.nightAccent)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .foregroundColor(.nightText)
            .navigationTitle(isNew ? "New prompt" : "Edit prompt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.nightAccent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let p = NightPrompt(
                            id: promptId,
                            text: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "…" : text
                        )
                        onSave(p)
                        dismiss()
                    }
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
}

struct InspirationLibraryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: NightJournalViewModel

    @State private var quoteToEdit: NightQuote?
    @State private var isNewQuote = false
    @State private var promptToEdit: NightPrompt?
    @State private var isNewPrompt = false

    var body: some View {
        NavigationStack {
            inspirationList
                .navigationTitle("Inspiration")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(
                    LinearGradient(
                        colors: [Color.nightBackground.opacity(0.98), Color.nightBackground.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    for: .navigationBar
                )
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                            .foregroundColor(.nightAccent)
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                isNewPrompt = true
                                promptToEdit = NightPrompt(id: UUID(), text: "")
                            } label: {
                                Label("Add prompt", systemImage: "sparkles")
                            }
                            Button {
                                isNewQuote = true
                                quoteToEdit = NightQuote(id: UUID(), text: "", author: "", isFavorite: false)
                            } label: {
                                Label("Add quote", systemImage: "quote.bubble")
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.nightAccent)
                        }
                    }
                }
                .sheet(item: $quoteToEdit) { quote in
                    quoteEditorSheet(quote: quote)
                }
                .sheet(item: $promptToEdit) { prompt in
                    promptEditorSheet(prompt: prompt)
                }
        }
        .nightScreenBackdrop()
    }

    private var inspirationList: some View {
        List {
            Section {
                Text("Favorite quotes are used for the rotating quote on the Journal tab when at least one favorite exists.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .listRowBackground(Color.nightBackground)
            }

            Section {
                ForEach(viewModel.prompts) { prompt in
                    promptRow(prompt)
                }
            } header: {
                Text("Daily prompts")
                    .foregroundColor(.nightAccent)
            }

            Section {
                ForEach(viewModel.quotes) { quote in
                    quoteRow(quote)
                }
            } header: {
                Text("Quotes")
                    .foregroundColor(.nightAccent)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private func promptRow(_ prompt: NightPrompt) -> some View {
        Button {
            promptToEdit = prompt
            isNewPrompt = false
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .foregroundColor(.nightAccent)
                Text(prompt.text)
                    .foregroundColor(.nightText)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .listRowBackground(Color.nightAccent.opacity(0.05))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.deletePrompt(prompt)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    @ViewBuilder
    private func quoteRow(_ quote: NightQuote) -> some View {
        Button {
            quoteToEdit = quote
            isNewQuote = false
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: quote.isFavorite ? "star.fill" : "star")
                    .foregroundColor(quote.isFavorite ? .nightAccent : .gray)
                VStack(alignment: .leading, spacing: 4) {
                    Text(quote.text)
                        .foregroundColor(.nightText)
                        .multilineTextAlignment(.leading)
                    Text("— \(quote.author)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
        .listRowBackground(Color.nightAccent.opacity(0.05))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.deleteQuote(quote)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            Button {
                viewModel.toggleQuoteFavorite(quote)
            } label: {
                Label("Favorite", systemImage: "star")
            }
            .tint(.nightAccent)
        }
    }

    @ViewBuilder
    private func quoteEditorSheet(quote: NightQuote) -> some View {
        QuoteEditorSheet(
            quote: quote,
            isNew: isNewQuote,
            onSave: { saved in
                if isNewQuote {
                    viewModel.addQuote(saved)
                } else {
                    viewModel.updateQuote(saved)
                }
            }
        )
        .onDisappear {
            isNewQuote = false
        }
    }

    @ViewBuilder
    private func promptEditorSheet(prompt: NightPrompt) -> some View {
        PromptEditorSheet(
            prompt: prompt,
            isNew: isNewPrompt,
            onSave: { saved in
                if isNewPrompt {
                    viewModel.addPrompt(saved)
                } else {
                    viewModel.updatePrompt(saved)
                }
            }
        )
        .onDisappear {
            isNewPrompt = false
        }
    }
}
