// View+Compatibility.swift

import SwiftUI

extension View {
    @ViewBuilder
    func compatibleScrollEdgeEffectHidden() -> some View {
        self
    }

    @ViewBuilder
    func compatibleGlassEffect() -> some View {
        background(.ultraThinMaterial)
    }

    @ViewBuilder
    func compatibleGlassEffectInteractive() -> some View {
        background(.ultraThinMaterial, in: Capsule())
    }
}
