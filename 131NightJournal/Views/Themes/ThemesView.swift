//
//  ThemesView.swift
//  131NightJournal
//

import SwiftUI

struct ThemesView: View {
    @ObservedObject var viewModel: NightJournalViewModel
    @State private var showAddThemeSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(viewModel.themes) { theme in
                        NavigationLink(value: theme.id) {
                            ThemeCard(theme: theme)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(.nightAccent.opacity(0.3))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteTheme(theme)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                Section {
                    Button {
                        showAddThemeSheet = true
                    } label: {
                        Text("Create theme")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .listRowBackground(
                        LinearGradient(
                            colors: [Color.nightAccent.opacity(0.22), Color.nightAccent.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.nightAccent)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .nightScreenBackdrop()
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(
                LinearGradient(
                    colors: [Color.nightBackground.opacity(0.98), Color.nightBackground.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: UUID.self) { id in
                if let theme = viewModel.themes.first(where: { $0.id == id }) {
                    ThemeDetailView(theme: theme, viewModel: viewModel)
                } else if let entry = viewModel.entry(id: id) {
                    EntryDetailView(entry: entry, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showAddThemeSheet) {
                AddThemeView(viewModel: viewModel)
            }
        }
    }
}
