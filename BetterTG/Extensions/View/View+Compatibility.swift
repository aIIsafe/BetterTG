// View+Compatibility.swift

import SwiftUI

extension View {
    /// Hides the iOS 26 scroll edge blur/fade effect. No-op on older OS.
    @ViewBuilder
    func compatibleScrollEdgeEffectHidden() -> some View {
        if #available(iOS 26.0, *) {
            self.scrollEdgeEffectStyle(.hard, for: .all)
        } else {
            self
        }
    }

    /// Liquid Glass on iOS 26+, ultraThinMaterial on older.
    @ViewBuilder
    func compatibleGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular)
        } else {
            self.background(.ultraThinMaterial)
        }
    }

    /// Interactive Liquid Glass (capsule shape) on iOS 26+.
    @ViewBuilder
    func compatibleGlassEffectInteractive() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.regular, in: .capsule)
        } else {
            self.background(.ultraThinMaterial, in: Capsule())
        }
    }
}
