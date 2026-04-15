//
//  ThemeCard.swift
//  131NightJournal
//

import SwiftUI

struct ThemeCard: View {
    let theme: NightTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(theme.name)
                .font(.headline)
                .foregroundColor(.nightText)
            Text(theme.description)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)
            Text("\(theme.entries.count) entries")
                .font(.caption2)
                .foregroundColor(.nightAccent)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .nightElevatedCard(cornerRadius: 12)
    }
}
