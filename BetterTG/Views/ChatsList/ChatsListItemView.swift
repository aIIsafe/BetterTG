// ChatsListItemView.swift

import Foundation
import SwiftUI
import TDLibKit

struct ChatsListItemView: View {
    @State var folder: CustomFolder
    @State var customChat: CustomChat

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Avatar + pin badge
            ZStack(alignment: .bottomTrailing) {
                ProfileImageView(
                    photo: customChat.chat.photo?.big,
                    minithumbnail: customChat.chat.photo?.minithumbnail,
                    title: customChat.chat.title,
                    userId: customChat.chat.id,
                    fontSize: 22,
                )
                .frame(width: 56, height: 56)

                if customChat.position.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 8, weight: .bold))
                        .rotationEffect(.degrees(45))
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(Color(red: 0.37, green: 0.37, blue: 0.40))
                        .clipShape(.circle)
                        .offset(x: 2, y: 2)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 12)

            // Title + preview
            VStack(alignment: .leading, spacing: 3) {
                // Row 1: name + time
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(customChat.chat.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer(minLength: 2)

                    if let lastMessage = customChat.lastMessage {
                        Text(formattedTime(Foundation.Date(
                            timeIntervalSince1970: Double(lastMessage.date)
                        )))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color(.systemGray))
                        .fixedSize()
                    }
                }

                // Row 2: preview + unread badge
                HStack(alignment: .center, spacing: 4) {
                    LastOrDraftMessageView(customChat: customChat)
                        .font(.system(size: 15))
                        .lineLimit(1)

                    Spacer(minLength: 2)

                    if customChat.unreadCount > 0 {
                        Text(customChat.unreadCount > 999 ? "999+" : "\(customChat.unreadCount)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.18, green: 0.61, blue: 0.96))
                            )
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                }
            }
            .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 72)
        .contentShape(.rect)
        .animation(.smooth(duration: 0.18), value: customChat.unreadCount)
    }

    private func formattedTime(_ date: Foundation.Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let fmt = DateFormatter()
            fmt.dateFormat = "HH:mm"
            return fmt.string(from: date)
        } else if cal.isDateInYesterday(date) {
            return "вчера"
        } else if let days = cal.dateComponents([.day], from: date, to: .now).day, days < 7 {
            let fmt = DateFormatter()
            fmt.dateFormat = "EEE"
            fmt.locale = Locale(identifier: "ru_RU")
            return fmt.string(from: date).capitalized
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "dd.MM.yy"
            return fmt.string(from: date)
        }
    }
}
