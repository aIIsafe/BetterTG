// ChatView.swift

import Combine
import PhotosUI
import SwiftUI
import TDLibKit

struct ChatView: View {
    // MARK: Lifecycle

    init(customChat: CustomChat) {
        self._chatVM = State(wrappedValue: ChatVM(customChat: customChat))
    }
    
    // MARK: Internal

    @Environment(\.isPreview) var isPreview
    @Environment(\.dismiss) var dismiss
    
    @FocusState var focused
    
    @State var chatVM: ChatVM
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            bodyView.onAppear { chatVM.scrollViewProxy = scrollViewProxy }
        }
        .ignoresSafeArea(.container)
        .overlay {
            if chatVM.customChat.lastMessage == nil {
                ZStack {
                    TelegramBackground()
                    Text("No messages")
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxHeight: .infinity)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !isPreview, chatVM.customChat.canPostMessages {
                ChatBottomArea(focused: $focused)
                    .readSize { chatVM.bottomAreaHeight = $0.height }
            }
        }
        .dropDestination(for: SelectedImage.self) { items, _ in
            nc.post(name: .localOnSelectedImagesDrop, object: Array(items.prefix(10)))
            return true
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHeight($navigationBarHeight)
        .toolbar {
            ToolbarItem(placement: .principal) { principal }
            ToolbarItem(placement: .topBarTrailing) { topBarTrailing }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .environment(chatVM)
        .onChange(of: focused) { chatVM.focused = focused }
    }
    
    var bodyView: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(chatVM.messages) { customMessage in
                    HStack(alignment: .bottom, spacing: 0) {
                        if customMessage.message.isOutgoing { Spacer(minLength: 0) } else {
                            if let user = customMessage.senderUser,
                               chatVM.customChat.shouldShowProfileImage,
                               let index = chatVM.messages.firstIndex(of: customMessage)
                            {
                                if chatVM.messages[safe: index - 1]?.senderUser?.id != user.id {
                                    ProfileImageView(
                                        photo: user.profilePhoto?.big,
                                        minithumbnail: user.profilePhoto?.minithumbnail,
                                        title: user.firstName,
                                        userId: user.id,
                                    )
                                    .frame(width: 30, height: 30)
                                } else {
                                    Spacer()
                                        .frame(width: 30, height: 30)
                                }
                                Spacer()
                                    .frame(width: 6)
                            }
                        }
                        
                        MessageView(customMessage: customMessage)
                            .frame(
                                maxWidth: Utils.maxMessageContentWidth,
                                alignment: customMessage.message.isOutgoing ? .trailing : .leading,
                            )
                            .onScrollVisibilityChange { visible in
                                guard !isPreview, visible else { return }
                                chatVM.viewMessage(id: customMessage.message.id)
                            }
                        
                        if !customMessage.message.isOutgoing { Spacer(minLength: 0) }
                    }
                    .padding(customMessage.message.isOutgoing ? .trailing : .leading, 12)
                    .transition(
                        .asymmetric(
                            insertion: .push(from: customMessage.message.isOutgoing ? .trailing : .leading),
                            removal: .move(edge: customMessage.message.isOutgoing ? .trailing : .leading),
                        )
                        .combined(with: .opacity),
                    )
                    .flipped()
                }
            }
            .padding(.top, chatVM.extraBottomPadding)
            .padding(.horizontal, 4)
            .readOffset(in: .named(chatVM.chatScrollNamespaceId), onChange: chatVM.onPreferenceChange)
        }
        .background { TelegramBackground() }
        .flipped()
        .coordinateSpace(name: chatVM.chatScrollNamespaceId)
        .scrollDismissesKeyboard(.interactively)
        .scrollBounceBehavior(.always)
        .scrollIndicators(.hidden)
        .compatibleScrollEdgeEffectHidden()
        .onTapGesture { focused = false }
        .animation(.smooth(duration: 0.3), value: chatVM.extraBottomPadding)
        .overlay(alignment: .bottomTrailing) {
            if chatVM.showScrollToBottomButton {
                scrollToBottomButton
                    .padding(.bottom, chatVM.extraBottomPadding + 8)
                    .padding(.trailing, 12)
            }
        }
    }
    
    var scrollToBottomButton: some View {
        Button(action: chatVM.scrollToLast) {
            Image(systemName: "chevron.down")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color(red: 0.2, green: 0.2, blue: 0.22, opacity: 1))
                .clipShape(.circle)
                .overlay {
                    Circle().stroke(.white.opacity(0.15), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
                .overlay(alignment: .top) {
                    if chatVM.customChat.unreadCount != 0 {
                        Text("\(chatVM.customChat.unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(.blue)
                            .clipShape(.capsule)
                            .offset(y: -8)
                    }
                }
        }
        .transition(
            .asymmetric(
                insertion: .scale(scale: 0.7).combined(with: .opacity),
                removal: .scale(scale: 0.7).combined(with: .opacity),
            )
            .animation(.spring(duration: 0.25)),
        )
    }
    
    // MARK: Private

    @State private var navigationBarHeight = CGFloat.zero

    private var principal: some View {
        VStack(spacing: 1) {
            Text(chatVM.customChat.chat.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
            
            Group {
                if !chatVM.actionStatus.isEmpty {
                    Text(chatVM.actionStatus)
                        .foregroundStyle(.blue)
                } else if !chatVM.onlineStatus.isEmpty {
                    Text(chatVM.onlineStatus)
                        .foregroundStyle(chatVM.onlineStatus == "online" ? .green : .secondary)
                }
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .top),
                    removal: .move(edge: .bottom),
                )
                .combined(with: .opacity),
            )
            .font(.system(size: 12))
        }
        .frame(minWidth: Utils.screen.bounds.width * 0.45)
        .padding(.horizontal, 10)
        .animation(.smooth(duration: 0.2), value: chatVM.actionStatus)
        .animation(.smooth(duration: 0.2), value: chatVM.onlineStatus)
    }
    
    @ViewBuilder private var topBarTrailing: some View {
        let chat = chatVM.customChat.chat
        ProfileImageView(
            photo: chat.photo?.big,
            minithumbnail: chat.photo?.minithumbnail,
            title: chat.title,
            userId: chat.id,
        )
        .frame(width: 32, height: 32)
    }
}
