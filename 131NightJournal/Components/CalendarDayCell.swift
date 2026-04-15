//
//  CalendarDayCell.swift
//  131NightJournal
//

import SwiftUI

struct CalendarDayCell: View {
    let calendar: Calendar
    let date: Date
    let hasEntry: Bool
    let mood: Mood?

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.caption)
                .foregroundColor(hasEntry ? .nightAccent : .nightText)
            if hasEntry, let mood {
                Image(systemName: mood.icon)
                    .font(.caption2)
                    .foregroundColor(mood.color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 2)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: hasEntry
                            ? [Color.nightAccent.opacity(0.18), Color.nightAccent.opacity(0.06)]
                            : [Color.nightAccent.opacity(0.06), Color.nightAccent.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.nightAccent.opacity(hasEntry ? 0.35 : 0.12), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(hasEntry ? 0.25 : 0.12), radius: hasEntry ? 6 : 2, x: 0, y: 3)
        )
    }
}
