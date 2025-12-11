//
//  PinkAnimatedBackground.swift
//  labsession
//
//  Created by Assistant on 11.12.2025.
//

import SwiftUI

struct PinkAnimatedBackground: View {
    @State private var t1: CGFloat = 0
    @State private var t2: CGFloat = 0
    @State private var t3: CGFloat = 0

    // Нежные розовые цвета
    private let base1 = Color(red: 1.00, green: 0.95, blue: 0.98) // #FFF2FA
    private let base2 = Color(red: 1.00, green: 0.92, blue: 0.96) // #FFEAF5
    private let bubbleA = Color(red: 1.00, green: 0.80, blue: 0.90) // мягкий розовый
    private let bubbleB = Color(red: 0.98, green: 0.76, blue: 0.88) // чуть насыщеннее
    private let bubbleC = Color(red: 0.96, green: 0.70, blue: 0.86) // акцент, но очень прозрачный

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                // Мягкий нежно‑розовый градиент
                LinearGradient(
                    colors: [
                        base1.opacity(0.9),
                        base2.opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Плавающие «пузыри» с очень мягкой прозрачностью
                bubble(color: bubbleA.opacity(0.28),
                       size: 280,
                       x: size.width * (0.18 + 0.05 * sin(t1)),
                       y: size.height * (0.24 + 0.04 * cos(t1)))

                bubble(color: bubbleB.opacity(0.24),
                       size: 320,
                       x: size.width * (0.84 + 0.04 * cos(t2)),
                       y: size.height * (0.20 + 0.05 * sin(t2)))

                bubble(color: bubbleC.opacity(0.22),
                       size: 240,
                       x: size.width * (0.28 + 0.06 * sin(t3)),
                       y: size.height * (0.82 + 0.05 * cos(t3)))
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
        .drawingGroup()
    }

    @ViewBuilder
    private func bubble(color: Color, size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Circle()
            .fill(
                LinearGradient(colors: [color, color.opacity(0.6)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .blur(radius: 22)
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

#Preview {
    PinkAnimatedBackground()
}
