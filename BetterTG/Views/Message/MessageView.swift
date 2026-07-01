// MessageView.swift

import SwiftUI
import TDLibKit

struct MessageView: View {
    let customMessage: CustomMessage

    @Environment(ChatVM.self) var chatVM
    
    private var isOutgoing: Bool { customMessage.message.isOutgoing }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            if let forwardedFrom = customMessage.forwardedFrom {
                ForwardedFromView(name: forwardedFrom)
            }
            
            if customMessage.replyUser != nil, let replyToMessage = customMessage.replyToMessage {
                ReplyMessageView(
                    customMessage: customMessage,
                    type: .replied,
                    onTap: { chatVM.scrollTo(id: replyToMessage.id) },
                )
            }
            
            if customMessage.messagePhoto != nil
                || customMessage.messageVoiceNote != nil
                || !customMessage.album.isEmpty
            {
                MessageContentView(customMessage: customMessage)
            }
            
            if let formattedText = customMessage.formattedText {
                MessageTextView(formattedText: formattedText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .padding(
                        .top,
                        customMessage.replyUser != nil && customMessage.replyToMessage != nil
                            || customMessage.forwardedFrom != nil ? -4 : 0,
                    )
            }
        }
        .background(bubbleColor)
        .clipShape(bubbleShape)
        .overlay(alignment: .bottomTrailing) {
            Text(chatVM.dateFormatter.string(from: customMessage.date))
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.black.opacity(0.25))
                .clipShape(.capsule)
                .padding([.trailing, .bottom], 5)
        }
        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 1)
        .scaleEffect(
            chatVM.highlightedMessageId == customMessage.id ? 1.02 : 1.0,
            anchor: isOutgoing ? .bottomTrailing : .bottomLeading,
        )
        .animation(.spring(duration: 0.2), value: chatVM.highlightedMessageId)
        .customContextMenu(cornerRadius: 18, contextMenuActions)
    }

    private var bubbleColor: Color {
        if chatVM.highlightedMessageId == customMessage.id {
            return isOutgoing ? Color.bubbleOutgoing.opacity(0.7) : .white.opacity(0.15)
        }
        return isOutgoing ? Color.bubbleOutgoing : Color.bubbleIncoming
    }

    private var bubbleShape: some Shape {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
    }
}
