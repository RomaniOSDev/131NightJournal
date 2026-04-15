//
//  HomeView.swift
//  131NightJournal
//

import Combine
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: NightJournalViewModel
    @Binding var selectedTab: Int

    @State private var showAddEntrySheet = false
    @State private var showInspirationLibrary = false
    @State private var addEntryInitialContent = ""
    @State private var addEntrySession = UUID()
    @State private var now = Date()

    private let clock = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    heroSection
                    quickStatsRow
                    primaryActionsRow
                    if let prompt = viewModel.dailyPrompt {
                        promptCard(prompt)
                    }
                    if let quote = viewModel.nightQuote {
                        quoteCard(quote)
                    }
                    recentSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
            .nightScreenBackdrop()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(formattedShortDate(now))
                        .font(.subheadline)
                        .foregroundColor(.nightText.opacity(0.6))
                }
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
            .navigationDestination(for: UUID.self) { id in
                if let entry = viewModel.entry(id: id) {
                    EntryDetailView(entry: entry, viewModel: viewModel)
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

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.title.weight(.semibold))
                        .foregroundColor(.nightText)
                    Text("Your space for night thoughts.")
                        .font(.subheadline)
                        .foregroundColor(.nightText.opacity(0.65))
                }
                Spacer()
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.nightAccent, .nightAccent.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }
            .padding(.top, 8)

            Button {
                openNewEntry(prefill: "")
            } label: {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("New entry")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundColor(.nightBackground)
                .nightPrimaryButtonShape(cornerRadius: 14)
            }
            .buttonStyle(.plain)
        }
    }

    private var quickStatsRow: some View {
        let vm = viewModel
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                HomeStatChip(title: "Entries", value: "\(vm.totalEntries)", icon: "book.fill")
                HomeStatChip(title: "Streak", value: "\(vm.streakDays)", icon: "flame.fill")
                HomeStatChip(title: "Month", value: "\(vm.monthlyEntries)", icon: "calendar")
                HomeStatChip(
                    title: "Tag",
                    value: vm.mostUsedTag.isEmpty ? "—" : "#\(vm.mostUsedTag)",
                    icon: "tag.fill"
                )
            }
        }
    }

    private var primaryActionsRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explore")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.nightAccent, Color.nightAccent.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                HomeActionTile(
                    title: "Journal",
                    subtitle: "All entries",
                    icon: "book.fill",
                    action: { selectedTab = 1 }
                )
                HomeActionTile(
                    title: "Calendar",
                    subtitle: "By day",
                    icon: "calendar",
                    action: { selectedTab = 2 }
                )
                HomeActionTile(
                    title: "Statistics",
                    subtitle: "Insights",
                    icon: "chart.bar.fill",
                    action: { selectedTab = 3 }
                )
                HomeActionTile(
                    title: "Themes",
                    subtitle: "Collections",
                    icon: "folder.fill",
                    action: { selectedTab = 4 }
                )
            }
        }
    }

    private func promptCard(_ prompt: NightPrompt) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.nightAccent)
                Text("Today's prompt")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.nightAccent)
            }
            Text(prompt.text)
                .font(.body)
                .foregroundColor(.nightText)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                openNewEntry(prefill: prompt.text + "\n\n")
            } label: {
                Text("Write with this prompt")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [Color.nightAccent.opacity(0.35), Color.nightAccent.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.nightAccent.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                    )
                    .foregroundColor(.nightAccent)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .nightInsetPanel(cornerRadius: 16)
    }

    private func quoteCard(_ quote: NightQuote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundColor(.nightAccent)
                Text("Quote of the night")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.nightAccent)
                if viewModel.quotes.contains(where: { $0.isFavorite }) {
                    Text("(favorites)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            Text(quote.text)
                .font(.subheadline)
                .italic()
                .foregroundColor(.nightText.opacity(0.95))
            Text("— \(quote.author)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .nightElevatedCard(cornerRadius: 16)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent")
                    .font(.headline)
                    .foregroundColor(.nightAccent)
                Spacer()
                Button("See all") {
                    selectedTab = 1
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(.nightAccent)
            }

            let recent = Array(viewModel.sortedEntries.prefix(3))
            if recent.isEmpty {
                Text("No entries yet. Tap New entry to begin.")
                    .font(.subheadline)
                    .foregroundColor(.nightText.opacity(0.55))
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(recent) { entry in
                        NavigationLink(value: entry.id) {
                            HomeRecentEntryRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func openNewEntry(prefill: String) {
        addEntryInitialContent = prefill
        addEntrySession = UUID()
        showAddEntrySheet = true
    }

    private func formattedShortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }
}

// MARK: - Subviews

private struct HomeStatChip: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.nightAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.nightText)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .nightElevatedCard(cornerRadius: 12)
    }
}

private struct HomeActionTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.nightAccent)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.nightText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .nightElevatedCard(cornerRadius: 14)
        }
        .buttonStyle(.plain)
    }
}

private struct HomeRecentEntryRow: View {
    let entry: NightEntry

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: entry.category.icon)
                .font(.title3)
                .foregroundColor(.nightAccent)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color.nightAccent.opacity(0.28), Color.nightAccent.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.nightText)
                    .lineLimit(1)
                Text(entry.formattedTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.nightAccent.opacity(0.7))
        }
        .padding(12)
        .nightElevatedCard(cornerRadius: 12)
    }
}
