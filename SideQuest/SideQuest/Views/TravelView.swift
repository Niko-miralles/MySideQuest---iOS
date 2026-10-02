import SwiftUI

// Panel Travel: la lista de misiones (lo que era /play)
struct TravelView: View {
    @Environment(GameStore.self) private var store
    @State private var active: Mission?

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.white, SQ.lav], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        header
                        ForEach(Mission.catalog) { mission in
                            MissionCard(mission: mission,
                                        completed: store.completion(for: mission) != nil) {
                                active = mission
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Travel")
            .sheet(item: $active) { MissionPlayView(mission: $0) }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            PixelAvatar(seed: store.player?.name ?? "?", palette: store.currentSkin, size: 52)
            VStack(alignment: .leading, spacing: 2) {
                Text(store.player?.name ?? "")
                    .font(.fredoka(19, weight: .bold))
                Text("Nivel \(store.level) · \(store.player?.xp ?? 0) XP")
                    .font(.fredoka(14)).foregroundStyle(SQ.muted)
            }
            Spacer()
            Label("\(store.streak)", systemImage: "flame.fill")
                .font(.fredoka(16, weight: .bold))
                .foregroundStyle(SQ.gold)
        }
        .padding(16)
        .sqCard()
    }
}

struct MissionCard: View {
    let mission: Mission
    let completed: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(mission.accent.opacity(0.15))
                        .frame(width: 56, height: 56)
                    Image(systemName: mission.kind.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(mission.accent)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title)
                        .font(.fredoka(17, weight: .semibold))
                        .foregroundStyle(SQ.ink)
                    HStack(spacing: 6) {
                        Image(systemName: "mappin")
                        Text(mission.city)
                    }
                    .font(.fredoka(13)).foregroundStyle(SQ.muted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(mission.xp) XP")
                        .font(.px(9))
                        .foregroundStyle(completed ? SQ.muted : SQ.violet)
                    if completed {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(SQ.green)
                    }
                }
            }
            .padding(16)
        }
        .buttonStyle(.plain)
        .sqCard()
        .opacity(completed ? 0.75 : 1)
    }
}

// Jugar una misión: pista → verificación (foto/checkpoint/acertijo) → recompensa → ¿publicar?
struct MissionPlayView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let mission: Mission

    @State private var verified = false
    @State private var finished = false
    @State private var earnedXP = 0
    @State private var caption = ""
    @State private var published = false

    private var alreadyDone: Bool { store.completion(for: mission)?.rewarded == true }

    var body: some View {
        NavigationStack {
            ZStack {
                SQ.ink.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 22) {
                        Text("GAME MASTER")
                            .font(.px(10)).foregroundStyle(SQ.violetSoft)
                        clueCard
                        if !finished { verifySection }
                        if finished { rewardSection }
                    }
                    .padding(22)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Salir") { dismiss() }.foregroundStyle(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text(mission.title).font(.fredoka(16, weight: .semibold)).foregroundStyle(.white)
                }
            }
        }
    }

    private var clueCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PISTA").font(.px(8)).foregroundStyle(SQ.gold)
            Text(mission.clue)
                .font(.fredoka(16))
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white.opacity(0.07))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(SQ.violetSoft.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [6])))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var verifySection: some View {
        VStack(spacing: 14) {
            if alreadyDone {
                Text("Ya completaste esta misión — puedes repetirla, pero no ganarás XP ni recompensas.")
                    .font(.fredoka(14))
                    .foregroundStyle(SQ.muted)
                    .multilineTextAlignment(.center)
            }
            Button {
                withAnimation { verified = true }
            } label: {
                Label(mission.kind == .photo ? "Subir foto" : "Verificar ubicación",
                      systemImage: mission.kind == .photo ? "camera.fill" : "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PixelButtonStyle(bg: verified ? SQ.green : SQ.violet))

            if verified {
                Button("Completar misión") { finish() }
                    .buttonStyle(PixelButtonStyle(bg: SQ.gold, fg: SQ.goldInk, pressedBg: SQ.gold.opacity(0.8)))
            }
        }
    }

    private var rewardSection: some View {
        VStack(spacing: 18) {
            Text("¡MISIÓN COMPLETADA!")
                .font(.px(13)).foregroundStyle(SQ.gold)
            if earnedXP > 0 {
                Text("+\(earnedXP) XP")
                    .font(.px(22)).foregroundStyle(.white)
            } else {
                Text("Repetición · sin XP")
                    .font(.fredoka(16)).foregroundStyle(SQ.muted)
            }

            if !published {
                VStack(spacing: 12) {
                    Text("¿Publicar en tu perfil?")
                        .font(.fredoka(17, weight: .semibold)).foregroundStyle(.white)
                    TextField("Añade un texto…", text: $caption)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(.white.opacity(0.1))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    HStack(spacing: 12) {
                        Button("Publicar") {
                            store.publishPost(for: mission,
                                              caption: caption.isEmpty ? mission.title : caption)
                            published = true
                        }
                        .buttonStyle(PixelButtonStyle())
                        Button("Ahora no") { dismiss() }
                            .buttonStyle(PixelButtonStyle(bg: .white.opacity(0.12), fg: .white,
                                                          pressedBg: .white.opacity(0.2)))
                    }
                }
            } else {
                Button("Hecho") { dismiss() }
                    .buttonStyle(PixelButtonStyle())
            }
        }
    }

    private func finish() {
        let c = store.completeMission(mission)
        earnedXP = c.xpEarned
        withAnimation { finished = true }
    }
}
