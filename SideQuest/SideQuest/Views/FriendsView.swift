import SwiftUI

// Friends: lista, perfiles, chat y envío de misiones
struct FriendsView: View {
    @Environment(GameStore.self) private var store
    @State private var newFriend = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.white, SQ.lav], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack(spacing: 14) {
                    HStack(spacing: 8) {
                        TextField("Añadir amigo por nombre", text: $newFriend)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(SQ.line))
                        Button("Añadir") {
                            store.addFriend(named: newFriend)
                            newFriend = ""
                        }
                        .buttonStyle(PixelButtonStyle())
                        .frame(width: 110)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    List {
                        ForEach(store.player?.friends.sorted { $0.addedAt < $1.addedAt } ?? []) { f in
                            NavigationLink {
                                FriendDetailView(friend: f)
                            } label: {
                                HStack(spacing: 12) {
                                    PixelAvatar(seed: f.name, size: 44)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(f.name).font(.fredoka(16, weight: .semibold))
                                        Text("Nivel \(f.level)").font(.fredoka(13)).foregroundStyle(SQ.muted)
                                    }
                                    Spacer()
                                    Image(systemName: "bubble.left.fill").foregroundStyle(SQ.violetSoft)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Friends")
        }
    }
}

struct FriendDetailView: View {
    @Environment(GameStore.self) private var store
    let friend: Friend
    @State private var draft = ""
    @State private var pickingMission = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    PixelAvatar(seed: friend.name, size: 80)
                    Text(friend.name).font(.fredoka(22, weight: .bold))
                    Text("Nivel \(friend.level)").font(.fredoka(14)).foregroundStyle(SQ.muted)
                }
                .padding(.top, 20)

                LazyVStack(spacing: 8) {
                    ForEach(store.messages(with: friend.name)) { msg in
                        HStack {
                            if msg.isFromMe { Spacer(minLength: 60) }
                            VStack(alignment: msg.isFromMe ? .trailing : .leading, spacing: 4) {
                                Text(msg.text).font(.fredoka(15))
                                if let mid = msg.attachedMissionId,
                                   let m = Mission.catalog.first(where: { $0.id == mid }) {
                                    Label("\(m.title) · \(m.xp) XP", systemImage: m.kind.icon)
                                        .font(.px(8))
                                        .foregroundStyle(msg.isFromMe ? .white.opacity(0.85) : SQ.violet)
                                }
                            }
                            .padding(12)
                            .background(msg.isFromMe ? SQ.violet : .white)
                            .foregroundStyle(msg.isFromMe ? .white : SQ.ink)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            if !msg.isFromMe { Spacer(minLength: 60) }
                        }
                    }
                }
                .padding(16)
            }

            HStack(spacing: 8) {
                Button { pickingMission = true } label: {
                    Image(systemName: "map.fill").foregroundStyle(SQ.violet)
                        .frame(width: 40, height: 40)
                        .background(SQ.lav)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                TextField("Mensaje…", text: $draft)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(SQ.line))
                Button {
                    store.sendMessage(to: friend.name, text: draft)
                    draft = ""
                } label: {
                    Image(systemName: "paperplane.fill").foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(SQ.violet)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
        }
        .navigationTitle(friend.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $pickingMission) {
            NavigationStack {
                List(Mission.catalog) { m in
                    Button {
                        store.sendMission(m, to: friend.name)
                        pickingMission = false
                    } label: {
                        HStack {
                            Image(systemName: m.kind.icon).foregroundStyle(m.accent)
                            Text(m.title).font(.fredoka(15, weight: .semibold))
                            Spacer()
                            Text("\(m.xp) XP").font(.px(8)).foregroundStyle(SQ.violet)
                        }
                    }
                }
                .navigationTitle("Enviar misión")
            }
            .presentationDetents([.medium, .large])
        }
    }
}
