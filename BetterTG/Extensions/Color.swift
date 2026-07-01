// Color.swift

import SwiftUI

extension Color {
    static let gray6 = Color(uiColor: .systemGray6)
    static let gray5 = Color(uiColor: .systemGray5)
    static let gray4 = Color(uiColor: .systemGray4)
    static let gray3 = Color(uiColor: .systemGray3)
    static let gray2 = Color(uiColor: .systemGray2)

    // AnyGram theme — blue palette from the icon
    /// Dark background for the main chat list (like Telegram dark mode)
    static let appDark = Color(red: 0.11, green: 0.11, blue: 0.12, opacity: 1)
    /// Placeholder, kept for API compat
    static let chatBackground = Color(red: 0.11, green: 0.11, blue: 0.12, opacity: 1)
    /// Incoming bubble: dark navy — readable on the blue gradient
    static let bubbleIncoming = Color(red: 0.14, green: 0.17, blue: 0.28, opacity: 1)
    /// Outgoing bubble: icon primary blue #2E9CF5
    static let bubbleOutgoing = Color(red: 0.18, green: 0.61, blue: 0.96, opacity: 1)
    /// Subtle transparent row tint for chat list on dark background
    static let chatListRowBackground = Color.clear

    init(red: Int, green: Int, blue: Int, opacity: Double) {
        self.init(.sRGB, red: Double(red / 255), green: Double(green / 255), blue: Double(blue / 255), opacity: opacity)
    }

    init(userId: Int64) {
        let colors: [Color] = [.red, .green, .yellow, .blue, .purple, .pink, .blue, .orange]
        let id = abs(Int(String(userId).replacing("-100", with: "")) ?? 0)
        self.init(uiColor: UIColor(colors[[0, 7, 4, 1, 6, 3, 5][id % 7]]))
    }
}
