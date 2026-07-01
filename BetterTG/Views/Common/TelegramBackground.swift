// TelegramBackground.swift
// Animated chat wallpaper – pure blue palette matching the AnyGram icon

import SwiftUI

struct TelegramBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                AnimatedMeshBackground(phase: phase)
            } else {
                FallbackGradientBackground(phase: phase)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(
                .easeInOut(duration: 10)
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

    // Sky-blue palette extracted from the AnyGram icon
    // No green / no teal – only blues
    private let baseColors: [Color] = [
        Color(r: 14,  g: 38,  b: 105),  // top-left:      deep navy
        Color(r: 18,  g: 58,  b: 145),  // top-center:    royal blue
        Color(r: 20,  g: 72,  b: 165),  // top-right:     bright blue

        Color(r: 12,  g: 45,  b: 130),  // mid-left:      mid-blue
        Color(r: 46,  g: 156, b: 245),  // center:        icon primary ← brightest
        Color(r: 25,  g: 90,  b: 200),  // mid-right:     sky blue

        Color(r: 10,  g: 28,  b: 85),   // bottom-left:   dark navy
        Color(r: 16,  g: 52,  b: 138),  // bottom-center: deep blue
        Color(r: 18,  g: 68,  b: 160),  // bottom-right:  blue
    ]

    private func points(_ t: Float) -> [SIMD2<Float>] {
        let s = sin(t * .pi) * 0.13
        let c = cos(t * .pi) * 0.07
        return [
            [0,   0            ], [0.5,      0       ], [1,   0],
            [0,   0.5 + s      ], [0.5 + c,  0.5     ], [1,   0.5 - s],
            [0,   1            ], [0.5,      1       ], [1,   1],
        ]
    }

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: points(Float(phase)),
            colors: baseColors,
            smoothsColors: true
        )
    }
}

// MARK: - Fallback for iOS < 18

private struct FallbackGradientBackground: View {
    let phase: CGFloat

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(r: 10, g: 28, b: 85),  location: 0),
                .init(color: Color(r: 46, g: 156, b: 245), location: phase * 0.6 + 0.2),
                .init(color: Color(r: 14, g: 38, b: 105), location: 1),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Helpers

private extension Color {
    init(r: Int, g: Int, b: Int) {
        self.init(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}
