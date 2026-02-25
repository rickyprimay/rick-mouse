//
//  View+Glassmorphism.swift
//  rick-mouse
//
//  Created by Ricky Primayuda Putra on 25/02/26.
//

import SwiftUI

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat
    var opacity: Double

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.3),
                                .white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

struct SubtleCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .fill(Color(.controlBackgroundColor).opacity(0.6))
            }
            .overlay {
                RoundedRectangle(cornerRadius: AppConstants.cornerRadius)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.5)
            }
    }
}

extension View {
    func glassCard(
        cornerRadius: CGFloat = AppConstants.cornerRadius,
        opacity: Double = 0.85
    ) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, opacity: opacity))
    }

    func subtleCard() -> some View {
        modifier(SubtleCardModifier())
    }

    func fadeSlideIn(edge: Edge = .trailing) -> some View {
        transition(
            .asymmetric(
                insertion: .opacity.combined(with: .move(edge: edge)),
                removal: .opacity
            )
        )
    }
}
