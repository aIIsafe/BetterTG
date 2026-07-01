// TelegramBackground.swift

import SwiftUI

// MARK: - Telegram animated mesh gradient background

struct TelegramBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                AnimatedMeshBackground(phase: phase)
            } else {
                FallbackGradientBackground()
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 9)
                .repeatForever(autoreverses: true)
            ) {
                phase = 1
            }
        }
    }
}

// MARK: - MeshGradient (iOS 18+)

@available(iOS 18.0, *)
private struct AnimatedMeshBackground: View {
    let phase: CGFloat

    // Telegram-style dark blue/teal palette
    private let colors: [Color] = [
        Color(r: 11, g: 26, b: 56),   // top-left:     deep navy
        Color(r: 9,  g: 41, b: 82),   // top-center:   dark blue
        Color(r: 14, g: 52, b: 75),   // top-right:    blue-teal

        Color(r: 7,  g: 58, b: 78),   // mid-left:     teal
        Color(r: 12, g: 45, b: 95),   // center:       medium blue  ← brightest
        Color(r: 9,  g: 78, b: 80),   // mid-right:    cyan-teal

        Color(r: 8,  g: 22, b: 52),   // bottom-left:  deep navy
        Color(r: 7,  g: 36, b: 70),   // bottom-center:navy blue
        Color(r: 13, g: 55, b: 72),   // bottom-right: blue-teal
    ]

    // Animate the 4 interior/edge control points
    private func points(_ t: Float) -> [SIMD2<Float>] {
        let s = sin(t * .pi) * 0.12
        let c = cos(t * .pi) * 0.08
        return [
            [0,   0  ], [0.5,        0          ], [1,   0  ],
            [0,   0.5 + s], [0.5 + c, 0.5       ], [1,   0.5 - s],
            [0,   1  ], [0.5,        1          ], [1,   1  ],
        ]
    }

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: points(Float(phase)),
            colors: colors,
            smoothsColors: true
        )
        .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: phase)
    }
}

// MARK: - Fallback for iOS < 18

private struct FallbackGradientBackground: View {
    @State private var isAnimating = false

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(r: 11, g: 26, b: 56), location: 0),
                .init(color: Color(r: 9,  g: 78, b: 80), location: isAnimating ? 0.6 : 0.4),
                .init(color: Color(r: 8,  g: 22, b: 52), location: 1),
            ],
            startPoint: isAnimating ? .topLeading : .bottomTrailing,
            endPoint:   isAnimating ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Helpers

private extension Color {
    init(r: Int, g: Int, b: Int) {
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
