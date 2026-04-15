//
//  NightCategory.swift
//  131NightJournal
//

import Foundation

enum NightCategory: String, CaseIterable, Codable, Hashable {
    case thoughts = "Thoughts"
    case dreams = "Dreams"
    case ideas = "Ideas"
    case reflection = "Reflection"
    case plans = "Plans"
    case gratitude = "Gratitude"
    case other = "Other"

    var icon: String {
        switch self {
        case .thoughts: return "brain"
        case .dreams: return "moon.stars.fill"
        case .ideas: return "lightbulb.fill"
        case .reflection: return "arrow.clockwise"
        case .plans: return "list.bullet"
        case .gratitude: return "heart.fill"
        case .other: return "pencil"
        }
    }
}
