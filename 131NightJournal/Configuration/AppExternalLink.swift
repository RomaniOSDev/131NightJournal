//
//  AppExternalLink.swift
//  131NightJournal
//

import Foundation
import UIKit

/// Legal and web URLs used by the app. Replace with production hosts when ready.
enum AppExternalLink: String {
    case privacyPolicy = "https://www.termsfeed.com/live/cf0360d8-c008-40a6-b6df-d3f346b11bc4"
    case termsOfUse = "https://www.termsfeed.com/live/476a6d28-a078-4a84-b7c2-7341381bc878"

    /// Opens the URL in the default browser (Safari).
    func openInBrowser() {
        if let url = URL(string: rawValue) {
            UIApplication.shared.open(url)
        }
    }
}
