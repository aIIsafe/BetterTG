// MainView.swift

import SwiftUI
import TDLibKit

// MARK: - MainView

struct MainView: View {
    var body: some View {
        NavigationControllerWrapper(navigationController: navigationStorage.navigationController) {
            MainNavigationRootView()
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }

    private let navigationStorage = NavigationStorage.shared
}

// MARK: - MainNavigationRootView

private struct MainNavigationRootView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Paged folder scroll
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(rootVM.folders) { folder in
                        FolderView(
                            folder: folder,
                            navigationBarHeight: UIApplication.safeAreaInsets.top + navigationBarHeight,
                            bottomBarHeight: UIApplication.safeAreaInsets.bottom + tabBarHeight,
                        )
                        .frame(width: Utils.screen.bounds.width)
                        .id(folder.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $rootVM.currentFolder)
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("AnyGram")
            .background(Color.appDark)
            .toolbarBackground(Color.appDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarHeight($navigationBarHeight.animation())
            .searchable(
                text: $rootVM.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Поиск",
            )
            .confirmationDialog(
                "Удалить чат с \(rootVM.confirmChatDelete.chat?.title ?? "пользователем")?",
                isPresented: $rootVM.confirmChatDelete.show,
            ) {
                Button("Удалить", role: .destructive) {
                    guard let id = rootVM.confirmChatDelete.chat?.id else { return }
                    Task.background { [rootVM] in
                        try await td.deleteChatHistory(
                            chatId: id, removeFromChatList: true, revoke: rootVM.confirmChatDelete.forAll,
                        )
                    }
                }
            }
            .toolbar {
                if let archive = rootVM.archive {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(systemImage: "archivebox") {
                            navigationStorage.push(.archive(archive))
                        }
                    }
                }
            }
            .onAppear {
                navigationStorage.setDestinationBuilder { route in
                    switch route {
                    case .customChat(let customChat):
                        ChatView(customChat: customChat)
                    case .archive(let customFolder):
                        FolderView(folder: customFolder)
                            .navigationTitle(customFolder.name)
                            .navigationBarTitleDisplayMode(.inline)
                            .searchable(
                                text: $rootVM.query,
                                placement: .navigationBarDrawer(displayMode: .always),
                                prompt: "Поиск",
                            )
                    }
                }
            }

            // Liquid Glass tab bar
            if !rootVM.folders.isEmpty {
                LiquidGlassTabBar(
                    folders: rootVM.folders,
                    activeFolder: $rootVM.currentFolder,
                )
                .padding(.bottom, UIApplication.safeAreaInsets.bottom + 8)
                .padding(.horizontal, 20)
                .readSize { tabBarHeight = $0.height + UIApplication.safeAreaInsets.bottom + 8 }
            }
        }
    }

    @Bindable private var rootVM = RootVM.shared
    @State private var navigationBarHeight = CGFloat.zero
    @State private var tabBarHeight = CGFloat(72)

    private let navigationStorage = NavigationStorage.shared
}

// MARK: - LiquidGlassTabBar

private struct LiquidGlassTabBar: View {
    let folders: [CustomFolder]
    @Binding var activeFolder: Int?

    var body: some View {
        HStack(spacing: 0) {
            ForEach(folders) { folder in
                tabItem(folder)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            // Liquid Glass: ultraThinMaterial capsule with subtle border
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.25), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing,
                            ),
                            lineWidth: 0.7,
                        )
                }
        }
        .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 8)
    }

    @ViewBuilder
    private func tabItem(_ folder: CustomFolder) -> some View {
        let isActive = activeFolder == folder.id
        let unread = folder.chats.reduce(0) { $0 + $1.unreadCount }

        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.25)) {
                if activeFolder == folder.id {
                    folder.scrollViewProxy?.scrollTo("top", anchor: .top)
                } else {
                    activeFolder = folder.id
                }
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 3) {
                    Image(systemName: folderIcon(folder))
                        .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                        .frame(height: 26)

                    Text(folder.name)
                        .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                        .lineLimit(1)
                }
                .foregroundStyle(isActive ? Color.white : Color.white.opacity(0.55))
                .frame(minWidth: 60, maxWidth: .infinity)
                .frame(height: 52)
                .background {
                    if isActive {
                        // Active bubble — filled circle like in the screenshot
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.18, green: 0.61, blue: 0.96),
                                        Color(red: 0.12, green: 0.45, blue: 0.80),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing,
                                )
                            )
                            .frame(width: 58, height: 58)
                            .shadow(color: Color(red: 0.18, green: 0.61, blue: 0.96).opacity(0.4), radius: 8)
                    }
                }

                // Unread badge
                if unread > 0 && !isActive {
                    Text(unread > 99 ? "99+" : "\(unread)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(red: 0.18, green: 0.61, blue: 0.96)))
                        .offset(x: 8, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func folderIcon(_ folder: CustomFolder) -> String {
        switch folder.type {
        case .main:     return "message.fill"
        case .archive:  return "archivebox.fill"
        case .folder:   return "folder.fill"
        }
    }
}
