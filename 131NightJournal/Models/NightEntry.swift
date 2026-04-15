//
//  NightEntry.swift
//  131NightJournal
//

import Foundation

struct NightEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    var title: String
    var content: String
    var mood: Mood
    var category: NightCategory
    var tags: [String]
    var isFavorite: Bool
    var isPrivate: Bool
    let createdAt: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy, HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    var preview: String {
        if content.count > 100 {
            return String(content.prefix(100)) + "..."
        }
        return content
    }
}
