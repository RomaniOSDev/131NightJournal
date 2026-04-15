//
//  SettingsView.swift
//  131NightJournal
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        rateApp()
                    } label: {
                        Label("Rate us", systemImage: "star.fill")
                            .foregroundColor(.nightText)
                    }
                    .listRowBackground(Color.nightAccent.opacity(0.08))
                } header: {
                    Text("Support")
                        .foregroundColor(.nightAccent)
                }

                Section {
                    Button {
                        AppExternalLink.privacyPolicy.openInBrowser()
                    } label: {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                            .foregroundColor(.nightText)
                    }
                    .listRowBackground(Color.nightAccent.opacity(0.08))

                    Button {
                        AppExternalLink.termsOfUse.openInBrowser()
                    } label: {
                        Label("Terms of Use", systemImage: "doc.text.fill")
                            .foregroundColor(.nightText)
                    }
                    .listRowBackground(Color.nightAccent.opacity(0.08))
                } header: {
                    Text("Legal")
                        .foregroundColor(.nightAccent)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .nightScreenBackdrop()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(
                LinearGradient(
                    colors: [Color.nightBackground.opacity(0.98), Color.nightBackground.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                for: .navigationBar
            )
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    SettingsView()
}
