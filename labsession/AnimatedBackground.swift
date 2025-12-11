//
//  AnimatedBackground.swift
//  labsession
//
//  Created by Assistant on 11.12.2025.
//

import SwiftUI

struct AnimatedBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var t1: CGFloat = 0
    @State private var t2: CGFloat = 0
    @State private var t3: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                // Базовый мягкий фон
                LinearGradient(
                    colors: [
                        Color.secondary.opacity(0.08),
                        Color.secondary.opacity(0.08)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Плавающие «пузыри»
                bubble(color: .blue.opacity(0.35),
                       size: 260,
                       x: size.width * (0.15 + 0.05 * sin(t1)),
                       y: size.height * (0.22 + 0.04 * cos(t1)))

                bubble(color: .purple.opacity(0.30),
                       size: 300,
                       x: size.width * (0.82 + 0.04 * cos(t2)),
                       y: size.height * (0.18 + 0.05 * sin(t2)))

                bubble(color: .pink.opacity(0.28),
                       size: 220,
                       x: size.width * (0.25 + 0.06 * sin(t3)),
                       y: size.height * (0.80 + 0.05 * cos(t3)))
            }
            .frame(width: size.width, height: size.height)
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.linear(duration: 14).repeatForever(autoreverses: false)) {
                t1 = .pi * 2
            }
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                t2 = .pi * 2
            }
            withAnimation(.linear(duration: 22).repeatForever(autoreverses: false)) {
                t3 = .pi * 2
            }
        }
        .drawingGroup() // производительность
    }

    @ViewBuilder
    private func bubble(color: Color, size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(
                LinearGradient(colors: [color, color.opacity(0.6)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .blur(radius: 24)
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

#Preview {
    AnimatedBackground()
}
