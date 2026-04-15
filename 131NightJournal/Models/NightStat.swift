//
//  NightStat.swift
//  131NightJournal
//

import Foundation

struct NightStat {
    var totalEntries: Int
    var streakDays: Int
    var moodCounts: [Mood: Int]
    var categoryCounts: [NightCategory: Int]
    var mostUsedTag: String
    var averageEntriesPerWeek: Double
}
