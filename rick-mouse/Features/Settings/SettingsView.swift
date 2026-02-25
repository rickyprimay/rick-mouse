//
//  SettingsView.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import SwiftUI


struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                generalSection

                accessibilitySection

                aboutSection

                dangerZone
            }
            .padding(24)
        }
        .onAppear {
            viewModel.loadSettings(from: appState)
        }
        .alert("Reset Configuration", isPresented: $viewModel.showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetConfiguration(appState: appState)
            }
        } message: {
            Text("This will reset all button mappings, gestures, and scroll settings to their defaults. This action cannot be undone.")
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                Text("General preferences and app information")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("General")
                .font(.headline)

            Toggle(isOn: $viewModel.launchAtLogin) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Launch at Login")
                        .font(.subheadline)
                    Text("Automatically start Rick Mouse when you log in")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
            .onChange(of: viewModel.launchAtLogin) {
                viewModel.toggleLaunchAtLogin(appState: appState)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accessibility")
                .font(.headline)

            HStack(spacing: 12) {
                Image(systemName: appState.permissionManager.isGranted
                      ? "checkmark.shield.fill"
                      : "exclamationmark.shield.fill")
                    .font(.title2)
                    .foregroundStyle(appState.permissionManager.isGranted ? .green : .orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.permissionManager.isGranted
                         ? "Accessibility Permission Granted"
                         : "Accessibility Permission Required")
                        .font(.subheadline)

                    Text("Rick Mouse uses Accessibility API to intercept mouse events. No data is collected or transmitted.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !appState.permissionManager.isGranted {
                    Button("Grant Access") {
                        appState.permissionManager.requestPermission()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)

            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "computermouse.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(AppConstants.appName)
                            .font(.system(.title3, design: .rounded, weight: .bold))

                        Text("Version \(AppConstants.appVersion)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                Divider()

                HStack(spacing: 12) {
                    Image(systemName: "hand.raised.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Privacy First")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("No network calls • No analytics • No tracking • Only Accessibility permission")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                Divider()

                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Created by")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Ricky Primayuda Putra")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Danger Zone")
                .font(.headline)
                .foregroundStyle(.red)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reset All Settings")
                        .font(.subheadline)
                    Text("Restore all settings to their default values")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Reset") {
                    viewModel.showResetConfirmation = true
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .controlSize(.small)
            }
        }
        .padding(16)
        .overlay {
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                .strokeBorder(.red.opacity(0.3), lineWidth: 1)
        }
    }
}
