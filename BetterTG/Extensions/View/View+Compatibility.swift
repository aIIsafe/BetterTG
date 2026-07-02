// View+Compatibility.swift

import SwiftUI

extension View {
    /// No-op — scroll edge effect is handled by removing gradient overlays.
    @ViewBuilder
    func compatibleScrollEdgeEffectHidden() -> some View {
        self
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
