import SwiftUI
import SwiftData

@main
struct SideQuestApp: App {
    @State private var store = GameStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.light)
        }
        .modelContainer(for: [Player.self, Completion.self, Post.self,
                              Friend.self, ChatMessage.self]) { result in
            if case .success(let container) = result {
                Task { @MainActor in store.attach(context: container.mainContext) }
            }
        }
    }
}
