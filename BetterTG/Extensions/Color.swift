// Color.swift

import SwiftUI

extension Color {
    static let gray6 = Color(uiColor: .systemGray6)
    static let gray5 = Color(uiColor: .systemGray5)
    static let gray4 = Color(uiColor: .systemGray4)
    static let gray3 = Color(uiColor: .systemGray3)
    static let gray2 = Color(uiColor: .systemGray2)

    // AnyGram theme
    static let chatBackground = Color(red: 0.06, green: 0.12, blue: 0.22, opacity: 1)
    // Incoming: slightly translucent dark, reads well on the blue gradient
    static let bubbleIncoming = Color(red: 0.13, green: 0.17, blue: 0.27, opacity: 1)
    // Outgoing: bright saturated blue, stands out from the background
    static let bubbleOutgoing = Color(red: 0.17, green: 0.46, blue: 0.82, opacity: 1)
    // Chat list row overlay: subtle dark tint for readability
    static let chatListRowBackground = Color(red: 0.04, green: 0.09, blue: 0.18, opacity: 0.55)

    init(red: Int, green: Int, blue: Int, opacity: Double) {
        self.init(.sRGB, red: Double(red / 255), green: Double(green / 255), blue: Double(blue / 255), opacity: opacity)
    }

    init(userId: Int64) {
        let colors: [Color] = [.red, .green, .yellow, .blue, .purple, .pink, .blue, .orange]
        let id = abs(Int(String(userId).replacing("-100", with: "")) ?? 0)
        self.init(uiColor: UIColor(colors[[0, 7, 4, 1, 6, 3, 5][id % 7]]))
    }
}
