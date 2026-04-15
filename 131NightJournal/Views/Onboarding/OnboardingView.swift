//
//  OnboardingView.swift
//  131NightJournal
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var page = 0

    var body: some View {
        ZStack {
            NightScreenBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.nightAccent.opacity(0.9))
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                TabView(selection: $page) {
                    OnboardingPage(
                        icon: "moon.stars.fill",
                        iconGradient: [.nightAccent, .nightAccent.opacity(0.55)],
                        title: "Write by night",
                        text: "Capture thoughts, mood, and tags in a calm, focused space made for evening reflection."
                    )
                    .tag(0)

                    OnboardingPage(
                        icon: "square.grid.2x2.fill",
                        iconGradient: [.nightAccent.opacity(0.95), .nightAccent.opacity(0.5)],
                        title: "See the full picture",
                        text: "Browse entries, explore the calendar, check statistics, and organize moments into themes."
                    )
                    .tag(1)

                    OnboardingPage(
                        icon: "lock.shield.fill",
                        iconGradient: [.nightAccent, Color.nightText.opacity(0.75)],
                        title: "Stays on your device",
                        text: "Your words stay private here. No sign-in, no cloud—just your journal, always within reach."
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                VStack(spacing: 14) {
                    if page < 2 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                page += 1
                            }
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundColor(.nightBackground)
                                .nightPrimaryButtonShape(cornerRadius: 14)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Get started")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundColor(.nightBackground)
                                .nightPrimaryButtonShape(cornerRadius: 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
                .padding(.top, 8)
            }
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

private struct OnboardingPage: View {
    let icon: String
    let iconGradient: [Color]
    let title: String
    let text: String

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 20)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.nightAccent.opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 110
                        )
                    )
                    .frame(width: 220, height: 220)
                    .blur(radius: 8)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.nightAccent.opacity(0.2),
                                Color.nightAccent.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.nightAccent.opacity(0.5), Color.nightAccent.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 10)
                    .shadow(color: Color.nightAccent.opacity(0.2), radius: 12, x: 0, y: 4)

                Image(systemName: icon)
                    .font(.system(size: 52))
                    .foregroundStyle(
                        LinearGradient(
                            colors: iconGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(spacing: 12) {
                Text(title)
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.nightText, Color.nightText.opacity(0.88)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal)

                Text(text)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.nightText.opacity(0.72))
                    .lineSpacing(4)
                    .padding(.horizontal, 28)
            }

            Spacer(minLength: 40)
        }
    }
}

#Preview {
    OnboardingView()
}
