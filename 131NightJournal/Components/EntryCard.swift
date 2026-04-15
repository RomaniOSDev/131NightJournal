//
//  EntryCard.swift
//  131NightJournal
//

import SwiftUI

struct EntryCard: View {
    let entry: NightEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: entry.category.icon)
                    .foregroundColor(.nightAccent)
                    .font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.headline)
                        .foregroundColor(.nightText)
                    Text(entry.formattedTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                if entry.isPrivate {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.nightText.opacity(0.5))
                        .font(.caption)
                }
                if entry.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.nightAccent)
                        .font(.caption)
                }
                Image(systemName: entry.mood.icon)
                    .foregroundColor(entry.mood.color)
                    .font(.caption)
            }
            Text(entry.preview)
                .font(.body)
                .foregroundColor(.nightText.opacity(0.8))
                .lineLimit(3)
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .foregroundColor(.nightAccent)
                        }
                    }
                }
            }
        }
        .padding()
        .nightElevatedCard(cornerRadius: 12)
    }
}
