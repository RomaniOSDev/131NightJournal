//
//  NightJournalViewModel.swift
//  131NightJournal
//

import Foundation
import Combine

@MainActor
final class NightJournalViewModel: ObservableObject {
    @Published var entries: [NightEntry] = []
    @Published var quotes: [NightQuote] = []
    @Published var prompts: [NightPrompt] = []
    @Published var themes: [NightTheme] = []

    @Published var searchText: String = ""
    @Published var selectedMood: Mood?
    @Published var selectedCategory: NightCategory?

    var totalEntries: Int { entries.count }

    var streakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())

        while true {
            let hasEntry = entries.contains { calendar.isDate($0.date, inSameDayAs: date) }
            if hasEntry {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = prev
            } else {
                break
            }
        }
        return streak
    }

    var monthlyEntries: Int {
        let calendar = Calendar.current
        let now = Date()
        return entries.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }.count
    }

    var mostUsedTag: String {
        let allTags = entries.flatMap(\.tags)
        let grouped = Dictionary(grouping: allTags, by: { $0 })
        return grouped.max { $0.value.count < $1.value.count }?.key ?? ""
    }

    var averageWords: Int {
        guard !entries.isEmpty else { return 0 }
        let totalWords = entries.reduce(0) { acc, entry in
            acc + entry.content.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count
        }
        return totalWords / entries.count
    }

    var averageEntriesPerWeek: Double {
        guard !entries.isEmpty else { return 0 }
        let calendar = Calendar.current
        guard let oldest = entries.map(\.date).min() else { return 0 }
        let days = max(1, calendar.dateComponents([.day], from: calendar.startOfDay(for: oldest), to: Date()).day ?? 1)
        let weeks = max(1.0, Double(days) / 7.0)
        return Double(entries.count) / weeks
    }

    var sortedEntries: [NightEntry] {
        entries.sorted { $0.date > $1.date }
    }

    var filteredEntries: [NightEntry] {
        var result = entries

        if let mood = selectedMood {
            result = result.filter { $0.mood == mood }
        }
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
                    || $0.content.localizedCaseInsensitiveContains(searchText)
                    || $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        return result.sorted { $0.date > $1.date }
    }

    /// Quotes shown in rotation; favorites only when at least one exists.
    private var quotesForRotation: [NightQuote] {
        let favorites = quotes.filter(\.isFavorite)
        return favorites.isEmpty ? quotes : favorites
    }

    var nightQuote: NightQuote? {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let pool = quotesForRotation
        guard !pool.isEmpty else { return nil }
        return pool[dayOfYear % pool.count]
    }

    var dailyPrompt: NightPrompt? {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        guard !prompts.isEmpty else { return nil }
        return prompts[dayOfYear % prompts.count]
    }

    struct HourlyActivity: Identifiable {
        let id: Int
        let hour: Int
        let count: Int
        let label: String
    }

    /// Non-empty hours only, sorted by hour, for chart readability.
    var entriesByHour: [HourlyActivity] {
        let calendar = Calendar.current
        var counts = [Int](repeating: 0, count: 24)
        for entry in entries {
            let h = calendar.component(.hour, from: entry.date)
            counts[h] += 1
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return (0..<24).compactMap { hour -> HourlyActivity? in
            guard counts[hour] > 0 else { return nil }
            let labelDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
            let label = formatter.string(from: labelDate).lowercased()
            return HourlyActivity(id: hour, hour: hour, count: counts[hour], label: label)
        }
    }

    struct WeeklyActivity: Identifiable {
        let id: String
        let day: String
        let count: Int
    }

    var weeklyActivity: [WeeklyActivity] {
        let calendar = Calendar.current
        let today = Date()
        let ids = DateFormatter()
        ids.dateFormat = "yyyy-MM-dd"
        ids.locale = Locale(identifier: "en_US_POSIX")
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "EEE"
        dayFmt.locale = Locale(identifier: "en_US_POSIX")

        return (0..<7).reversed().compactMap { offset -> WeeklyActivity? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let count = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
            return WeeklyActivity(
                id: ids.string(from: date),
                day: dayFmt.string(from: date),
                count: count
            )
        }
    }

    struct MoodDistribution: Identifiable {
        var id: Mood { mood }
        let mood: Mood
        let count: Int
        let percentage: Double
    }

    var moodDistribution: [MoodDistribution] {
        let grouped = Dictionary(grouping: entries, by: \.mood)
        let total = Double(entries.count)
        return grouped.map { mood, list in
            MoodDistribution(
                mood: mood,
                count: list.count,
                percentage: total > 0 ? Double(list.count) / total * 100 : 0
            )
        }
        .sorted { $0.count > $1.count }
    }

    var popularTags: [String] {
        let allTags = entries.flatMap(\.tags)
        let grouped = Dictionary(grouping: allTags, by: { $0 })
        return grouped.sorted { $0.value.count > $1.value.count }
            .map(\.key)
            .prefix(10)
            .map { $0 }
    }

    func hasEntry(on date: Date) -> Bool {
        let calendar = Calendar.current
        return entries.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func moodOnDate(_ date: Date) -> Mood? {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date > $1.date }
            .first?
            .mood
    }

    func entriesOnDate(_ date: Date) -> [NightEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            .sorted { $0.date > $1.date }
    }

    func entry(id: UUID) -> NightEntry? {
        entries.first { $0.id == id }
    }

    func addEntry(_ entry: NightEntry) {
        entries.append(entry)
        saveToUserDefaults()
    }

    func updateEntry(_ entry: NightEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveToUserDefaults()
        }
    }

    func deleteEntry(_ entry: NightEntry) {
        entries.removeAll { $0.id == entry.id }
        themes = themes.map { theme in
            var t = theme
            t.entries.removeAll { $0 == entry.id }
            return t
        }
        saveToUserDefaults()
    }

    func toggleFavorite(_ entry: NightEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    func addQuote(_ quote: NightQuote) {
        quotes.append(quote)
        saveToUserDefaults()
    }

    func updateQuote(_ quote: NightQuote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index] = quote
            saveToUserDefaults()
        }
    }

    func deleteQuote(_ quote: NightQuote) {
        quotes.removeAll { $0.id == quote.id }
        saveToUserDefaults()
    }

    func toggleQuoteFavorite(_ quote: NightQuote) {
        if let index = quotes.firstIndex(where: { $0.id == quote.id }) {
            quotes[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    func addPrompt(_ prompt: NightPrompt) {
        prompts.append(prompt)
        saveToUserDefaults()
    }

    func updatePrompt(_ prompt: NightPrompt) {
        if let index = prompts.firstIndex(where: { $0.id == prompt.id }) {
            prompts[index] = prompt
            saveToUserDefaults()
        }
    }

    func deletePrompt(_ prompt: NightPrompt) {
        prompts.removeAll { $0.id == prompt.id }
        saveToUserDefaults()
    }

    func addTheme(_ theme: NightTheme) {
        themes.append(theme)
        saveToUserDefaults()
    }

    func deleteTheme(_ theme: NightTheme) {
        themes.removeAll { $0.id == theme.id }
        saveToUserDefaults()
    }

    private let entriesKey = "nightjournal_entries"
    private let quotesKey = "nightjournal_quotes"
    private let promptsKey = "nightjournal_prompts"
    private let promptsInitializedKey = "nightjournal_prompts_initialized"
    private let themesKey = "nightjournal_themes"

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
        if let encoded = try? JSONEncoder().encode(quotes) {
            UserDefaults.standard.set(encoded, forKey: quotesKey)
        }
        if let encoded = try? JSONEncoder().encode(prompts) {
            UserDefaults.standard.set(encoded, forKey: promptsKey)
        }
        if let encoded = try? JSONEncoder().encode(themes) {
            UserDefaults.standard.set(encoded, forKey: themesKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([NightEntry].self, from: data) {
            entries = decoded
        }
        if let data = UserDefaults.standard.data(forKey: quotesKey),
           let decoded = try? JSONDecoder().decode([NightQuote].self, from: data) {
            quotes = decoded
        }
        if let data = UserDefaults.standard.data(forKey: promptsKey),
           let decoded = try? JSONDecoder().decode([NightPrompt].self, from: data) {
            prompts = decoded
        }
        if let data = UserDefaults.standard.data(forKey: themesKey),
           let decoded = try? JSONDecoder().decode([NightTheme].self, from: data) {
            themes = decoded
        }
        if entries.isEmpty {
            loadDemoData()
        } else if prompts.isEmpty, !UserDefaults.standard.bool(forKey: promptsInitializedKey) {
            loadDefaultPrompts()
            UserDefaults.standard.set(true, forKey: promptsInitializedKey)
        }
        saveToUserDefaults()
    }

    private func loadDefaultPrompts() {
        prompts = [
            NightPrompt(id: UUID(), text: "What thought kept you awake tonight?"),
            NightPrompt(id: UUID(), text: "Name one small win from today."),
            NightPrompt(id: UUID(), text: "What would you tell your morning self?"),
            NightPrompt(id: UUID(), text: "What are you grateful for before sleep?"),
            NightPrompt(id: UUID(), text: "What do you want to let go of tonight?")
        ]
    }

    private func loadDemoData() {
        let entry1 = NightEntry(
            id: UUID(),
            date: Date().addingTimeInterval(-86400),
            title: "Quiet night",
            content: "Tonight felt especially calm. The stars were bright outside the window, and I felt at peace.",
            mood: .peaceful,
            category: .reflection,
            tags: ["calm", "night", "stars"],
            isFavorite: true,
            isPrivate: false,
            createdAt: Date()
        )
        let entry2 = NightEntry(
            id: UUID(),
            date: Date().addingTimeInterval(-172_800),
            title: "A new idea",
            content: "An idea for an app came to mind. I need to write down the details before I forget.",
            mood: .inspired,
            category: .ideas,
            tags: ["idea", "build"],
            isFavorite: false,
            isPrivate: false,
            createdAt: Date()
        )
        entries = [entry1, entry2]
        quotes = [
            NightQuote(
                id: UUID(),
                text: "Night is when the noise of the day fades and the conversation with yourself begins.",
                author: "Unknown",
                isFavorite: true
            )
        ]
        loadDefaultPrompts()
        UserDefaults.standard.set(true, forKey: promptsInitializedKey)
    }
}
