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
    @State private var t4: CGFloat = 0

    // Нежные розовые цвета (слегка усиленные)
    private let base1 = Color(red: 1.00, green: 0.94, blue: 0.98) // #FFEFFF
    private let base2 = Color(red: 1.00, green: 0.90, blue: 0.96) // #FFE5F5

    // Пузыри — чуть более заметные, но по‑прежнему мягкие
    private let bubbleA = Color(red: 1.00, green: 0.78, blue: 0.90) // розовый
    private let bubbleB = Color(red: 0.98, green: 0.72, blue: 0.88) // розовый акцент
    private let bubbleC = Color(red: 0.96, green: 0.66, blue: 0.86) // розовый акцент 2
    private let bubbleD = Color(red: 1.00, green: 0.84, blue: 0.92) // светло-розовый

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                // Более насыщенный базовый градиент
                LinearGradient(
                    colors: [
                        base1.opacity(0.95),
                        base2.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Плавающие «пузыри» — выше непрозрачность, меньше blur, больше разнообразия
                bubble(color: bubbleA.opacity(0.42),
                       size: min(size.width, size.height) * 0.45,
                       x: size.width * (0.18 + 0.06 * sin(t1)),
                       y: size.height * (0.26 + 0.05 * cos(t1)),
                       blur: 14)

                bubble(color: bubbleB.opacity(0.36),
                       size: min(size.width, size.height) * 0.55,
                       x: size.width * (0.82 + 0.05 * cos(t2)),
                       y: size.height * (0.22 + 0.06 * sin(t2)),
                       blur: 16)

                bubble(color: bubbleC.opacity(0.34),
                       size: min(size.width, size.height) * 0.40,
                       x: size.width * (0.30 + 0.07 * sin(t3)),
                       y: size.height * (0.78 + 0.06 * cos(t3)),
                       blur: 12)

                bubble(color: bubbleD.opacity(0.38),
                       size: min(size.width, size.height) * 0.48,
                       x: size.width * (0.55 + 0.05 * sin(t4 + .pi/3)),
                       y: size.height * (0.58 + 0.05 * cos(t4)),
                       blur: 14)
            }
            .frame(width: size.width, height: size.height)
            .ignoresSafeArea()
        }
        .onAppear {
            // Чуть быстрее, чтобы движение было очевиднее
            withAnimation(.linear(duration: 9).repeatForever(autoreverses: false)) {
                t1 = .pi * 2
            }
            withAnimation(.linear(duration: 11).repeatForever(autoreverses: false)) {
                t2 = .pi * 2
            }
            withAnimation(.linear(duration: 13).repeatForever(autoreverses: false)) {
                t3 = .pi * 2
            }
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                t4 = .pi * 2
            }
        }
        .drawingGroup()
    }

    @ViewBuilder
    private func bubble(color: Color, size: CGFloat, x: CGFloat, y: CGFloat, blur: CGFloat) -> some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blur(radius: blur)
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

#Preview {
    PinkAnimatedBackground()
}
