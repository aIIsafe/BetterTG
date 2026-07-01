// View+Compatibility.swift

import SwiftUI

private struct ScrollEdgeEffectHiddenModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.scrollEdgeEffectHidden(true, for: .all)
        } else {
            content
        }
    }
}

extension View {
    func compatibleScrollEdgeEffectHidden() -> some View {
        modifier(ScrollEdgeEffectHiddenModifier())
    }

    @ViewBuilder
    func compatibleGlassEffect() -> some View {
        self.background(Color(red: 0.12, green: 0.12, blue: 0.14, opacity: 0.9))
    }

    @ViewBuilder
    func compatibleGlassEffectInteractive() -> some View {
        self.background(Color(red: 0.12, green: 0.12, blue: 0.14, opacity: 0.9), in: Capsule())
    }
}
