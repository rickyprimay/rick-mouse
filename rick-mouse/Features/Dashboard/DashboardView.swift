//
//  DashboardView.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                if !viewModel.isAccessibilityGranted {
                    permissionBanner
                }
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    statusCard(
                        title: "Mouse Enhancement",
                        value: viewModel.isEnabled ? "Active" : "Disabled",
                        icon: "computermouse.fill",
                        color: viewModel.isEnabled ? .green : .secondary,
                        isActive: viewModel.isEnabled
                    )

                    statusCard(
                        title: "Accessibility",
                        value: viewModel.isAccessibilityGranted ? "Granted" : "Required",
                        icon: "lock.shield.fill",
                        color: viewModel.isAccessibilityGranted ? .green : .orange,
                        isActive: viewModel.isAccessibilityGranted
                    )

                    statusCard(
                        title: "Button Mappings",
                        value: "\(viewModel.activeButtonMappings) Active",
                        icon: "computermouse.fill",
                        color: .blue,
                        isActive: viewModel.activeButtonMappings > 0
                    )

                    statusCard(
                        title: "Scroll Smoothness",
                        value: viewModel.scrollSmoothness.displayName,
                        icon: viewModel.scrollSmoothness.sfSymbol,
                        color: .purple,
                        isActive: viewModel.scrollSmoothness != .off
                    )
                }

                gestureStatusCard
            }
            .padding(24)
        }
        .onAppear {
            viewModel.update(from: appState)
        }
        .onChange(of: appState.configuration.isEnabled) {
            viewModel.update(from: appState)
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                Text("Overview of your mouse enhancement settings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var permissionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text("Accessibility Permission Required")
                    .font(.headline)

                Text("Rick Mouse needs Accessibility access to intercept mouse events and provide enhanced controls.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Grant Access") {
                appState.permissionManager.requestPermission()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(16)
        .glassCard()
    }

    private func statusCard(
        title: String,
        value: String,
        icon: String,
        color: Color,
        isActive: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .shadow(color: color.opacity(0.4), radius: 4)

                Spacer()

                Circle()
                    .fill(isActive ? color : .secondary.opacity(0.3))
                    .frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title3, design: .rounded, weight: .semibold))

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var gestureStatusCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "hand.draw.fill")
                .font(.system(size: 24))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Trackpad-Like Gestures")
                    .font(.headline)

                Text(viewModel.gesturesEnabled
                     ? "Hold \(appState.configuration.gestureSettings.triggerButton.displayName) and drag to trigger gestures"
                     : "Gestures are currently disabled")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(viewModel.gesturesEnabled ? "Enabled" : "Disabled")
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(viewModel.gesturesEnabled ? .green.opacity(0.15) : .secondary.opacity(0.15))
                }
                .foregroundStyle(viewModel.gesturesEnabled ? .green : .secondary)
        }
        .padding(16)
        .glassCard()
    }
}
