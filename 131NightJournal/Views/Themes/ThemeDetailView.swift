//
//  ThemeDetailView.swift
//  131NightJournal
//

import SwiftUI

struct ThemeDetailView: View {
    @ObservedObject var viewModel: NightJournalViewModel
    private let themeId: UUID

    init(theme: NightTheme, viewModel: NightJournalViewModel) {
        themeId = theme.id
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    private var theme: NightTheme? {
        viewModel.themes.first { $0.id == themeId }
    }

    var body: some View {
        Group {
            if let theme {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(theme.name)
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.nightText, Color.nightText.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Text(theme.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Linked entries")
                            .font(.headline)
                            .foregroundColor(.nightAccent)
                            .padding(.top, 8)

                        ForEach(theme.entries, id: \.self) { entryUUID in
                            if let entry = viewModel.entry(id: entryUUID) {
                                NavigationLink(value: entry.id) {
                                    MiniEntryCard(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Text("Theme was removed")
                    .foregroundColor(.nightText)
            }
        }
        .nightScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
    }
}
