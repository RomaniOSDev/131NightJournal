//
//  Mood.swift
//  131NightJournal
//

import SwiftUI

enum Mood: String, CaseIterable, Codable, Hashable {
    case peaceful = "Peaceful"
    case inspired = "Inspired"
    case thoughtful = "Thoughtful"
    case grateful = "Grateful"
    case anxious = "Anxious"
    case sad = "Sad"
    case happy = "Happy"
    case tired = "Tired"

    var icon: String {
        switch self {
        case .peaceful: return "leaf.fill"
        case .inspired: return "lightbulb.fill"
        case .thoughtful: return "brain"
        case .grateful: return "hands.sparkles.fill"
        case .anxious: return "exclamationmark.triangle.fill"
        case .sad: return "cloud.rain.fill"
        case .happy: return "sun.max.fill"
        case .tired: return "bed.double.fill"
        }
    }

    var color: Color {
        switch self {
        case .peaceful, .inspired, .grateful, .happy:
            return .nightAccent
        case .thoughtful:
            return .nightText.opacity(0.8)
        case .anxious, .sad, .tired:
            return .nightText.opacity(0.6)
        }
    }
}
