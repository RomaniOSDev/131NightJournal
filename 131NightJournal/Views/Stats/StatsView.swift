//
//  StatsView.swift
//  131NightJournal
//

import Charts
import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: NightJournalViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Statistics")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.nightAccent, Color.nightAccent.opacity(0.75)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    StatCard(
                        title: "Total entries",
                        value: "\(viewModel.totalEntries)",
                        icon: "book.fill",
                        color: .nightAccent
                    )
                    StatCard(
                        title: "Day streak",
                        value: "\(viewModel.streakDays)",
                        icon: "flame.fill",
                        color: .nightAccent
                    )
                    StatCard(
                        title: "Avg. words",
                        value: "\(viewModel.averageWords)",
                        icon: "doc.text",
                        color: .nightAccent
                    )
                    StatCard(
                        title: "Activity",
                        value: String(format: "%.1f/wk", viewModel.averageEntriesPerWeek),
                        icon: "chart.line.uptrend.xyaxis",
                        color: .nightAccent
                    )
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Activity by day")
                        .font(.headline)
                        .foregroundColor(.nightAccent)
                    Chart {
                        ForEach(viewModel.weeklyActivity) { data in
                            BarMark(
                                x: .value("Day", data.day),
                                y: .value("Entries", data.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.nightAccent.opacity(0.95), Color.nightAccent.opacity(0.45)],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        }
                    }
                    .frame(height: 150)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .nightInsetPanel(cornerRadius: 16)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Moods")
                        .font(.headline)
                        .foregroundColor(.nightAccent)
                    if viewModel.moodDistribution.isEmpty {
                        Text("No data yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(viewModel.moodDistribution) { item in
                            HStack {
                                Image(systemName: item.mood.icon)
                                    .foregroundColor(item.mood.color)
                                    .frame(width: 30)
                                Text(item.mood.rawValue)
                                    .foregroundColor(.nightText)
                                Spacer()
                                Text("\(item.count)")
                                    .foregroundColor(.nightAccent)
                                Text("(\(Int(item.percentage))%)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .nightInsetPanel(cornerRadius: 16)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Mood chart")
                        .font(.headline)
                        .foregroundColor(.nightAccent)
                    if viewModel.moodDistribution.isEmpty {
                        Text("No data yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Chart {
                            ForEach(viewModel.moodDistribution) { item in
                                BarMark(
                                    x: .value("Count", item.count),
                                    y: .value("Mood", item.mood.rawValue)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [item.mood.color, item.mood.color.opacity(0.55)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            }
                        }
                        .frame(height: max(200, CGFloat(viewModel.moodDistribution.count) * 36))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .nightInsetPanel(cornerRadius: 16)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Entries by hour")
                        .font(.headline)
                        .foregroundColor(.nightAccent)
                    if viewModel.entriesByHour.isEmpty {
                        Text("No data yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Chart {
                            ForEach(viewModel.entriesByHour) { bucket in
                                BarMark(
                                    x: .value("Hour", bucket.label),
                                    y: .value("Entries", bucket.count)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.nightAccent, Color.nightAccent.opacity(0.5)],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                            }
                        }
                        .frame(height: 180)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .nightInsetPanel(cornerRadius: 16)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Popular tags")
                        .font(.headline)
                        .foregroundColor(.nightAccent)
                    if viewModel.popularTags.isEmpty {
                        Text("No tags yet")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.popularTags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.nightAccent.opacity(0.35), Color.nightAccent.opacity(0.12)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.nightAccent.opacity(0.35), lineWidth: 1)
                                        )
                                        .foregroundColor(.nightAccent)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .nightInsetPanel(cornerRadius: 16)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .nightScreenBackdrop()
    }
}
