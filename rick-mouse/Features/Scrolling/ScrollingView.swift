//
//  ScrollingView.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import SwiftUI

struct ScrollingView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ScrollingViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                smoothnessPicker

                speedControl

                if viewModel.smoothness == .high {
                    inertiaControl
                }

                optionsSection
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
                Text("Scrolling")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                Text("Customize your scroll behavior and smoothness")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var smoothnessPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Smoothness")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(ScrollSmoothness.allCases) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.smoothness = mode
                            viewModel.saveSettings(to: appState)
                        }
                    } label: {
                        smoothnessButtonLabel(for: mode)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassCard()
    }

    @ViewBuilder
    private func smoothnessButtonLabel(for mode: ScrollSmoothness) -> some View {
        let isSelected = viewModel.smoothness == mode
        
        VStack(spacing: 8) {
            Image(systemName: mode.sfSymbol)
                .font(.system(size: 24))
                .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )))

            Text(mode.displayName)
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Color.primary)

            Text(mode.subtitle)
                .font(.system(size: 10))
                .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.8))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(NSColor.controlBackgroundColor))
                }
            }
        )
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            }
        }
        .shadow(
            color: isSelected ? .blue.opacity(0.3) : .clear,
            radius: 8,
            y: 4
        )
    }

    private var speedControl: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Scroll Speed")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1fx", viewModel.scrollSpeed))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(value: $viewModel.scrollSpeed, in: 0.2...3.0, step: 0.1)
                .onChange(of: viewModel.scrollSpeed) {
                    viewModel.saveSettings(to: appState)
                }

            HStack {
                Text("Slower")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Faster")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .glassCard()
    }

    private var inertiaControl: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Inertia Strength")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.0f%%", viewModel.inertiaStrength * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(value: $viewModel.inertiaStrength, in: 0.1...1.0, step: 0.05)
                .onChange(of: viewModel.inertiaStrength) {
                    viewModel.saveSettings(to: appState)
                }

            HStack {
                Text("Light")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Heavy")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .glassCard()
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Options")
                .font(.headline)

            Toggle(isOn: $viewModel.invertDirection) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Invert Scroll Direction")
                        .font(.subheadline)
                    Text("Reverse the scroll direction (natural scrolling)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
            .onChange(of: viewModel.invertDirection) {
                viewModel.saveSettings(to: appState)
            }

            Divider()

            Toggle(isOn: $viewModel.precisionScrollModifier) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Precision Scroll (Shift key)")
                        .font(.subheadline)
                    Text("Hold Shift while scrolling for fine-grained control")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
            .onChange(of: viewModel.precisionScrollModifier) {
                viewModel.saveSettings(to: appState)
            }
        }
        .padding(16)
        .glassCard()
    }
}
