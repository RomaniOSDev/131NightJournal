//
//  EntryDetailView.swift
//  131NightJournal
//

import SwiftUI

struct EntryDetailView: View {
    @ObservedObject var viewModel: NightJournalViewModel
    @Environment(\.dismiss) private var dismiss

    private let entryId: UUID

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    init(entry: NightEntry, viewModel: NightJournalViewModel) {
        entryId = entry.id
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    private var entry: NightEntry? {
        viewModel.entry(id: entryId)
    }

    var body: some View {
        Group {
            if let entry {
                content(for: entry)
            } else {
                Text("Entry was removed")
                    .foregroundColor(.nightText)
            }
        }
        .nightScreenBackdrop()
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            if let entry {
                EditEntryView(viewModel: viewModel, entry: entry)
            }
        }
        .alert("Delete entry?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let e = viewModel.entry(id: entryId) {
                    viewModel.deleteEntry(e)
                    dismiss()
                }
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    @ViewBuilder
    private func content(for entry: NightEntry) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Image(systemName: entry.category.icon)
                            .foregroundColor(.nightAccent)
                            .font(.title2)
                        Text(entry.title)
                            .font(.largeTitle)
                            .bold()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.nightText, Color.nightText.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        Spacer()
                        if entry.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.nightAccent)
                        }
                    }
                    Text(entry.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        Image(systemName: entry.mood.icon)
                            .foregroundColor(entry.mood.color)
                        Text(entry.mood.rawValue)
                            .font(.caption)
                            .foregroundColor(entry.mood.color)
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Entry")
                        .font(.headline)
                        .foregroundColor(.nightAccent)
                    Text(entry.content)
                        .foregroundColor(.nightText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .nightInsetPanel(cornerRadius: 12)
                }
                .padding(.horizontal)

                if !entry.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.nightAccent)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.nightAccent.opacity(0.35), Color.nightAccent.opacity(0.15)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.nightAccent.opacity(0.35), lineWidth: 1)
                                        )
                                        .foregroundColor(.nightAccent)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                HStack(spacing: 12) {
                    Button {
                        showEditSheet = true
                    } label: {
                        Text("Edit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.nightBackground)
                            .nightPrimaryButtonShape(cornerRadius: 10)
                    }
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Delete")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.nightAccent)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.nightAccent.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.nightAccent.opacity(0.7), Color.nightAccent.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .shadow(color: Color.black.opacity(0.25), radius: 6, x: 0, y: 3)
                            )
                    }
                }
                .padding()
            }
        }
    }
}
