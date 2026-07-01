// ChatsListItemView.swift

import SwiftUI
import TDLibKit

struct ChatsListItemView: View {
    @State var folder: CustomFolder
    @State var customChat: CustomChat
    
    var body: some View {
        HStack(spacing: 12) {
            if customChat.position.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(45))
            }
            
            let chat = customChat.chat
            ProfileImageView(
                photo: chat.photo?.big,
                minithumbnail: chat.photo?.minithumbnail,
                title: chat.title,
                userId: chat.id,
                fontSize: 24,
            )
            .frame(width: 54, height: 54)
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(customChat.chat.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let lastMessage = customChat.lastMessage {
                        Text(lastMessageTime(Date(timeIntervalSince1970: Double(lastMessage.date))))
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack {
                    LastOrDraftMessageView(customChat: customChat)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if customChat.unreadCount > 0 {
                        Text("\(customChat.unreadCount)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.blue)
                            .clipShape(.capsule)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .contentShape(.rect)
        .animation(.smooth(duration: 0.2), value: customChat.unreadCount)
    }

    private func lastMessageTime(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let fmt = DateFormatter()
            fmt.dateFormat = "HH:mm"
            return fmt.string(from: date)
        } else if cal.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "dd.MM.yy"
            return fmt.string(from: date)
        }
    }
}
