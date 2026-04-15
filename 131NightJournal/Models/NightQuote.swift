//
//  NightQuote.swift
//  131NightJournal
//

import Foundation

struct NightQuote: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var author: String
    var isFavorite: Bool
}

struct NightPrompt: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
}
