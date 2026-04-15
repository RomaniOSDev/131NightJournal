//
//  DateFormatting.swift
//  131NightJournal
//

import Foundation

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM d, yyyy"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
}

func formattedShortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
}
