//
//  GesturesView.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import SwiftUI

struct GesturesView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = GesturesViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                enableToggle

                if viewModel.gesturesEnabled {
                    triggerButtonSection

                    dragGesturesSection

                    scrollGesturesSection

                    sensitivitySection
                }
            }
            .padding(24)
        }
        .onAppear {
            viewModel.loadSettings(from: appState.configuration)
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Gestures")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                Text("Trackpad-like gesture emulation for your mouse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var enableToggle: some View {
        HStack {
            Image(systemName: "hand.draw.fill")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Enable Gestures")
                    .font(.headline)
                Text("Hold a trigger button and drag to perform actions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $viewModel.gesturesEnabled)
                .toggleStyle(.switch)
                .labelsHidden()
                .onChange(of: viewModel.gesturesEnabled) {
                    viewModel.saveSettings(to: appState)
                }
        }
        .padding(16)
        .glassCard()
    }

    private var triggerButtonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trigger Button")
                .font(.headline)
            Text("Hold this button while dragging to activate gestures")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach([MouseButton.button4, .button5]) { button in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.triggerButton = button
                            viewModel.saveSettings(to: appState)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: button.sfSymbol)
                            Text(button.displayName)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.triggerButton == button
                                      ? .blue.opacity(0.15)
                                      : Color(.controlBackgroundColor))
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(viewModel.triggerButton == button
                                              ? .blue : .clear, lineWidth: 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    private var dragGesturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Drag Gestures", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                .font(.headline)

            gestureRow(direction: "Up", icon: "arrow.up", action: $viewModel.dragUpAction)
            Divider()
            gestureRow(direction: "Down", icon: "arrow.down", action: $viewModel.dragDownAction)
            Divider()
            gestureRow(direction: "Left", icon: "arrow.left", action: $viewModel.dragLeftAction)
            Divider()
            gestureRow(direction: "Right", icon: "arrow.right", action: $viewModel.dragRightAction)
        }
        .padding(16)
        .glassCard()
    }

    private var scrollGesturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Scroll Gestures (while holding trigger)", systemImage: "arrow.up.arrow.down")
                .font(.headline)

            gestureRow(direction: "Scroll Up", icon: "arrow.up.circle", action: $viewModel.scrollUpAction)
            Divider()
            gestureRow(direction: "Scroll Down", icon: "arrow.down.circle", action: $viewModel.scrollDownAction)
        }
        .padding(16)
        .glassCard()
    }

    private func gestureRow(direction: String, icon: String, action: Binding<MouseAction>) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.blue)
                .frame(width: 24)

            Text(direction)
                .font(.subheadline)

            Spacer()

            Picker("", selection: action) {
                ForEach(MouseAction.predefined) { mouseAction in
                    Text(mouseAction.displayName).tag(mouseAction)
                }
            }
            .labelsHidden()
            .frame(width: 180)
            .onChange(of: action.wrappedValue) {
                viewModel.saveSettings(to: appState)
            }
        }
    }

    private var sensitivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sensitivity")
                .font(.headline)

            VStack(spacing: 16) {
                HStack {
                    Text("Drag Threshold")
                        .font(.subheadline)
                    Spacer()
                    Text("\(Int(viewModel.dragThreshold))px")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Slider(
                    value: $viewModel.dragThreshold,
                    in: AppConstants.minimumDragThreshold...AppConstants.maximumDragThreshold,
                    step: 5
                )
                .onChange(of: viewModel.dragThreshold) {
                    viewModel.saveSettings(to: appState)
                }
            }
        }
        .padding(16)
        .glassCard()
    }
}
