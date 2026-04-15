//
//  StatCard.swift
//  131NightJournal
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            Text(value)
                .foregroundColor(.nightText)
                .font(.title2)
                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .nightElevatedCard(cornerRadius: 12)
    }
}
