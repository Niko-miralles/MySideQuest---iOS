import SwiftUI

// Perfil estilo Instagram: avatar, stats, grid de publicaciones de misiones
struct ProfileView: View {
    @Environment(GameStore.self) private var store
    private let cols = [GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2)]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.white, SQ.lav], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        // header
                        HStack(spacing: 18) {
                            PixelAvatar(seed: store.player?.name ?? "?",
                                        palette: store.currentSkin, size: 86)
                            HStack(spacing: 0) {
                                stat("\(store.player?.posts.count ?? 0)", "posts")
                                stat("\(store.player?.friends.count ?? 0)", "friends")
                                stat("\(store.level)", "nivel")
                            }
                        }
                        .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.player?.name ?? "").font(.fredoka(17, weight: .bold))
                            Text("Skin: \(store.currentSkin.name) · \(store.player?.xp ?? 0) XP · 🔥 \(store.streak)")
                                .font(.fredoka(14)).foregroundStyle(SQ.muted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                        Button("Cerrar sesión") { store.logOut() }
                            .font(.fredoka(14, weight: .semibold))
                            .foregroundStyle(SQ.pink)

                        // grid de publicaciones
                        if (store.player?.posts.isEmpty ?? true) {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.on.rectangle")
                                    .font(.system(size: 34)).foregroundStyle(SQ.line)
                                Text("Aún no hay publicaciones.\nCompleta una misión y publícala aquí.")
                                    .font(.fredoka(14)).foregroundStyle(SQ.muted)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 30)
                        } else {
                            LazyVGrid(columns: cols, spacing: 2) {
                                ForEach((store.player?.posts.sorted { $0.date > $1.date }) ?? []) { post in
                                    PostCell(post: post)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Perfil")
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.fredoka(19, weight: .bold))
            Text(label).font(.fredoka(13)).foregroundStyle(SQ.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

// "Imagen" del post: pixel-art generado de la misión
struct PostCell: View {
    let post: Post
    private var mission: Mission? { Mission.catalog.first { $0.id == post.missionId } }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            PixelAvatar(seed: post.imageSeed, size: 140)
                .clipShape(Rectangle())
            VStack(alignment: .leading, spacing: 2) {
                Text(mission?.title ?? post.missionId)
                    .font(.fredoka(11, weight: .semibold))
                    .lineLimit(1)
                Text(post.caption)
                    .font(.fredoka(10))
                    .lineLimit(1)
                    .opacity(0.9)
            }
            .padding(6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .foregroundStyle(SQ.ink)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipped()
    }
}
