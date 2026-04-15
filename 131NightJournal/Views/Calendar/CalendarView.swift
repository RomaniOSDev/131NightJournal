//
//  CalendarView.swift
//  131NightJournal
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: NightJournalViewModel
    @State private var visibleMonth = Date()
    @State private var selectedDate: Date?

    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.firstWeekday = 2
        return c
    }

    private let weekdaySymbols = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Calendar")
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

                    VStack(spacing: 12) {
                        HStack {
                            Button(action: previousMonth) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.nightAccent)
                            }
                            Spacer()
                            Text(monthYearString)
                                .font(.title2)
                                .foregroundColor(.nightText)
                            Spacer()
                            Button(action: nextMonth) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.nightAccent)
                            }
                        }
                        .padding(.horizontal)

                        HStack {
                            ForEach(weekdaySymbols, id: \.self) { day in
                                Text(day)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, cell in
                                if let date = cell {
                                    CalendarDayCell(
                                        calendar: calendar,
                                        date: date,
                                        hasEntry: viewModel.hasEntry(on: date),
                                        mood: viewModel.moodOnDate(date)
                                    )
                                    .onTapGesture {
                                        selectedDate = calendar.startOfDay(for: date)
                                    }
                                    .background(
                                        (selectedDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false)
                                            ? Color.nightAccent.opacity(0.15)
                                            : Color.clear
                                    )
                                    .cornerRadius(8)
                                } else {
                                    Color.clear
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                        }
                    }
                    .padding()
                    .nightInsetPanel(cornerRadius: 16)
                    .padding(.horizontal)

                    if let selectedDate {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(formattedDate(selectedDate))
                                .font(.headline)
                                .foregroundColor(.nightAccent)
                                .padding(.horizontal)

                            ForEach(viewModel.entriesOnDate(selectedDate)) { entry in
                                NavigationLink(value: entry.id) {
                                    MiniEntryCard(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical)
            }
            .nightScreenBackdrop()
            .navigationDestination(for: UUID.self) { id in
                if let entry = viewModel.entry(id: id) {
                    EntryDetailView(entry: entry, viewModel: viewModel)
                }
            }
        }
    }

    private var monthYearString: String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: visibleMonth).capitalized
    }

    private var daysInMonth: [Date?] {
        guard
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: visibleMonth)),
            let range = calendar.range(of: .day, in: .month, for: monthStart)
        else { return [] }

        let weekdayIndex = calendar.component(.weekday, from: monthStart)
        let leading = (weekdayIndex - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: leading)
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                cells.append(d)
            }
        }
        while cells.count % 7 != 0 {
            cells.append(nil)
        }
        return cells
    }

    private func previousMonth() {
        if let d = calendar.date(byAdding: .month, value: -1, to: visibleMonth) {
            visibleMonth = d
        }
    }

    private func nextMonth() {
        if let d = calendar.date(byAdding: .month, value: 1, to: visibleMonth) {
            visibleMonth = d
        }
    }
}
