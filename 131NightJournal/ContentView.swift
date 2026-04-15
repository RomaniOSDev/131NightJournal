//
//  ContentView.swift
//  131NightJournal
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var viewModel = NightJournalViewModel()
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: hasCompletedOnboarding) { completed in
            if completed {
                viewModel.loadFromUserDefaults()
            }
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            JournalFeedView(viewModel: viewModel)
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(1)

            CalendarView(viewModel: viewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(2)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(3)

            ThemesView(viewModel: viewModel)
                .tabItem {
                    Label("Themes", systemImage: "folder.fill")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .onAppear {
            viewModel.loadFromUserDefaults()
        }
        .tint(.nightAccent)
    }
}

#Preview {
    ContentView()
}
