//
//  NightTheme.swift
//  131NightJournal
//

import Foundation

struct NightTheme: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var entries: [UUID]
}
