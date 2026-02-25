//
//  ButtonMappingView.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import SwiftUI


struct ButtonMappingView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ButtonMappingViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                buttonSelector

                clickTypeTabs

                actionPicker

                mappingSummary
            }
            .padding(24)
        }
        .onAppear {
            viewModel.loadMappings(from: appState.configuration)
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Button Mapping")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                Text("Assign actions to your mouse buttons")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var buttonSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Button")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(viewModel.remappableButtons) { button in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedButton = button
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: button.sfSymbol)
                                .font(.system(size: 20))
                            Text(button.displayName)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.selectedButton == button
                                      ? Color.blue.opacity(0.15)
                                      : Color.clear)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(viewModel.selectedButton == button
                                              ? .blue
                                              : .secondary.opacity(0.2),
                                              lineWidth: viewModel.selectedButton == button ? 2 : 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private var clickTypeTabs: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Click Type")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(ClickType.allCases) { clickType in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedClickType = clickType
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: clickType.sfSymbol)
                                .font(.system(size: 12))
                            Text(clickType.displayName)
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .background {
                            Capsule()
                                .fill(viewModel.selectedClickType == clickType
                                      ? .blue
                                      : Color(.controlBackgroundColor))
                        }
                        .foregroundStyle(viewModel.selectedClickType == clickType ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private var actionPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Assigned Action")
                    .font(.headline)
                Spacer()
                Text(viewModel.currentAction.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(MouseAction.predefined) { action in
                    actionButton(for: action)
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private func actionButton(for action: MouseAction) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.updateAction(action, appState: appState)
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: action.sfSymbol)
                    .font(.system(size: 16))
                    .foregroundStyle(viewModel.currentAction == action ? .white : .blue)

                Text(action.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(viewModel.currentAction == action ? .white : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(viewModel.currentAction == action
                          ? LinearGradient(colors: [.blue, .blue.opacity(0.8)],
                                           startPoint: .top, endPoint: .bottom)
                          : LinearGradient(colors: [Color(.controlBackgroundColor)],
                                           startPoint: .top, endPoint: .bottom))
            }
            .overlay {
                if viewModel.currentAction == action {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.blue, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var mappingSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Mappings")
                .font(.headline)

            let activeMappings = viewModel.mappings.filter { $0.action != .none }

            if activeMappings.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("No active mappings")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                ForEach(activeMappings) { mapping in
                    HStack {
                        Image(systemName: mapping.button.sfSymbol)
                            .foregroundStyle(.blue)
                        Text(mapping.button.displayName)
                            .font(.subheadline)

                        Image(systemName: mapping.clickType.sfSymbol)
                            .foregroundStyle(.secondary)
                            .font(.caption)

                        Spacer()

                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)
                            .font(.caption)

                        Text(mapping.action.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 4)

                    if mapping.id != activeMappings.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(16)
        .glassCard()
    }
}
