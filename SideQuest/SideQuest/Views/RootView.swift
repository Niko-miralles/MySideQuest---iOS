import SwiftUI

struct RootView: View {
    @Environment(GameStore.self) private var store
    @State private var tab = 0

    var body: some View {
        if store.isLoggedIn {
            TabView(selection: $tab) {
                TravelView()
                    .tabItem { Label("Travel", systemImage: "map.fill") }.tag(0)
                PassView()
                    .tabItem { Label("Pase", systemImage: "flag.checkered") }.tag(1)
                StreakView()
                    .tabItem { Label("Racha", systemImage: "flame.fill") }.tag(2)
                FriendsView()
                    .tabItem { Label("Friends", systemImage: "person.2.fill") }.tag(3)
                ProfileView()
                    .tabItem { Label("Perfil", systemImage: "person.crop.square.fill") }.tag(4)
            }
            .tint(SQ.violet)
        } else {
            OnboardingView()
        }
    }
}
