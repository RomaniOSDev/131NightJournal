//
//  NightDesign.swift
//  131NightJournal
//

import SwiftUI

enum NightStyle {
    static let cardRadius: CGFloat = 14
    static let panelRadius: CGFloat = 16
    static let softShadowRadius: CGFloat = 10
    static let liftShadowRadius: CGFloat = 14
}

/// Full-screen gradient + soft light orbs (depth).
struct NightScreenBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.055, blue: 0.13),
                    Color.nightBackground,
                    Color(red: 0.065, green: 0.085, blue: 0.175)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.nightAccent.opacity(0.22), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 50)
                .offset(x: 130, y: -190)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.nightAccent.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 130
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 45)
                .offset(x: -150, y: 160)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.nightAccent.opacity(0.06), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 35)
                .offset(x: 100, y: 320)
        }
    }
}

extension View {
    /// Deep night backdrop behind scroll/list content.
    func nightScreenBackdrop() -> some View {
        background(NightScreenBackground().ignoresSafeArea())
    }

    /// Raised card: gradient fill, luminous edge, double shadow.
    func nightElevatedCard(cornerRadius: CGFloat = NightStyle.cardRadius) -> some View {
        modifier(NightElevatedCardModifier(cornerRadius: cornerRadius))
    }

    /// Inset panel for charts / sections (softer depth).
    func nightInsetPanel(cornerRadius: CGFloat = NightStyle.panelRadius) -> some View {
        modifier(NightInsetPanelModifier(cornerRadius: cornerRadius))
    }

    /// Primary CTA: blue gradient + glow shadow.
    func nightPrimaryButtonShape(cornerRadius: CGFloat = 14) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.nightAccent,
                            Color.nightAccent.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.nightAccent.opacity(0.45), radius: 14, x: 0, y: 6)
                .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
        )
    }
}

struct NightElevatedCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.nightAccent.opacity(0.16),
                                Color.nightAccent.opacity(0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.nightAccent.opacity(0.45),
                                        Color.nightAccent.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: NightStyle.liftShadowRadius, x: 0, y: 8)
                    .shadow(color: Color.nightAccent.opacity(0.18), radius: 12, x: 0, y: 4)
            )
    }
}

struct NightInsetPanelModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.nightAccent.opacity(0.12),
                                Color.nightAccent.opacity(0.03)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.nightAccent.opacity(0.28),
                                        Color.nightAccent.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: NightStyle.softShadowRadius, x: 0, y: 6)
                    .shadow(color: Color.nightAccent.opacity(0.08), radius: 6, x: 0, y: 2)
            )
    }
}

