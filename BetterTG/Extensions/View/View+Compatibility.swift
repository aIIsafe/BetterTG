// View+Compatibility.swift

import SwiftUI

extension View {
    @ViewBuilder
    func compatibleScrollEdgeEffectHidden() -> some View {
        if #available(iOS 18.0, *) {
            self.scrollEdgeEffectHidden(true, for: .all)
        } else {
            self
        }
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
