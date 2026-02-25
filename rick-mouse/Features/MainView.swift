//
//  MainView.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case buttons = "Buttons"
    case gestures = "Gestures"
    case scrolling = "Scrolling"
    case settings = "Settings"

    var id: String { rawValue }

    var sfSymbol: String {
        switch self {
        case .dashboard: return "gauge.with.dots.needle.33percent"
        case .buttons: return "computermouse.fill"
        case .gestures: return "hand.draw.fill"
        case .scrolling: return "arrow.up.arrow.down.circle.fill"
        case .settings: return "gear"
        }
    }
}

struct MainView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedItem: NavigationItem = .dashboard

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationSplitViewStyle(.balanced)
        .background(.ultraThinMaterial)
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Image(systemName: "computermouse.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 8)

                Text(AppConstants.appName)
                    .font(.system(.title3, design: .rounded, weight: .bold))

                Text("v\(AppConstants.appVersion)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)

            Divider()
                .padding(.horizontal)

            VStack(spacing: 4) {
                ForEach(NavigationItem.allCases) { item in
                    sidebarButton(for: item)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            Spacer()

            HStack(spacing: 8) {
                Circle()
                    .fill(appState.configuration.isEnabled ? .green : .secondary)
                    .frame(width: 8, height: 8)
                    .shadow(color: appState.configuration.isEnabled ? .green.opacity(0.5) : .clear, radius: 4)

                Text(appState.configuration.isEnabled ? "Active" : "Disabled")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { appState.configuration.isEnabled },
                    set: { _ in appState.toggleEnabled() }
                ))
                .toggleStyle(.switch)
                .controlSize(.mini)
                .labelsHidden()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(minWidth: AppConstants.sidebarWidth)
    }

    private func sidebarButton(for item: NavigationItem) -> some View {
        Button {
            withAnimation(.easeInOut(duration: AppConstants.animationDuration)) {
                selectedItem = item
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item.sfSymbol)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 22)
                    .foregroundStyle(selectedItem == item ? .white : .primary)

                Text(item.rawValue)
                    .font(.system(.body, design: .rounded, weight: selectedItem == item ? .semibold : .regular))
                    .foregroundStyle(selectedItem == item ? .white : .primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                if selectedItem == item {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 4, y: 2)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.clear)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selectedItem {
        case .dashboard:
            DashboardView()
        case .buttons:
            ButtonMappingView()
        case .gestures:
            GesturesView()
        case .scrolling:
            ScrollingView()
        case .settings:
            SettingsView()
        }
    }
}
