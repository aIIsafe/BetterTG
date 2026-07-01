// ChatsListItemView.swift

import Foundation
import SwiftUI
import TDLibKit

struct ChatsListItemView: View {
    @State var folder: CustomFolder
    @State var customChat: CustomChat

    var body: some View {
        HStack(spacing: 12) {
            let chat = customChat.chat

            // Avatar
            ZStack(alignment: .bottomTrailing) {
                ProfileImageView(
                    photo: chat.photo?.big,
                    minithumbnail: chat.photo?.minithumbnail,
                    title: chat.title,
                    userId: chat.id,
                    fontSize: 22,
                )
                .frame(width: 54, height: 54)

                if customChat.position.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(3)
                        .background(Color(red: 0.4, green: 0.4, blue: 0.45, opacity: 1))
                        .clipShape(.circle)
                        .offset(x: 3, y: 3)
                }
            }

            // Text info
            VStack(alignment: .leading, spacing: 4) {
                // Title + time row
                HStack(alignment: .firstTextBaseline) {
                    Text(chat.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    if let lastMessage = customChat.lastMessage {
                        Text(lastMessageTime(
                            Foundation.Date(timeIntervalSince1970: Double(lastMessage.date))
                        ))
                        .font(.system(size: 13))
                        .foregroundStyle(Color(.systemGray))
                    }
                }

                // Preview + badge row
                HStack(alignment: .center) {
                    LastOrDraftMessageView(customChat: customChat)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.systemGray))
                        .lineLimit(1)

                    Spacer(minLength: 4)

                    if customChat.unreadCount > 0 {
                        Text(customChat.unreadCount > 999 ? "999+" : "\(customChat.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0.18, green: 0.61, blue: 0.96, opacity: 1))
                            .clipShape(.capsule)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.vertical, 9)
        .contentShape(.rect)
        .animation(.smooth(duration: 0.2), value: customChat.unreadCount)
    }

    private func lastMessageTime(_ date: Foundation.Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let fmt = DateFormatter()
            fmt.dateFormat = "HH:mm"
            return fmt.string(from: date)
        } else if cal.isDateInYesterday(date) {
            return "Вчера"
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "dd.MM.yy"
            return fmt.string(from: date)
        }
    }
}
