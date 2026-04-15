//
//  MiniEntryCard.swift
//  131NightJournal
//

import SwiftUI

struct MiniEntryCard: View {
    let entry: NightEntry

    var body: some View {
        HStack {
            Image(systemName: entry.category.icon)
                .foregroundColor(.nightAccent)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.title)
                    .font(.headline)
                    .foregroundColor(.nightText)
                Text(entry.formattedTime)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: entry.mood.icon)
                .foregroundColor(entry.mood.color)
                .font(.caption)
        }
        .padding()
        .nightElevatedCard(cornerRadius: 12)
        .padding(.horizontal)
    }
}
