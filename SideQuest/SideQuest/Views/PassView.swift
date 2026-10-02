import SwiftUI

// Pase de batalla: skins que se desbloquean con XP (estilo Duolingo)
struct PassView: View {
    @Environment(GameStore.self) private var store

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.white, SQ.lav], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        progressCard
                        trackPath
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Pase de batalla")
        }
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TU PROGRESO").font(.px(9)).foregroundStyle(SQ.violet)
            HStack {
                Text("\(store.player?.xp ?? 0) XP")
                    .font(.fredoka(22, weight: .bold))
                Spacer()
                if let next = SkinPalette.track.first(where: { $0.xpRequired > (store.player?.xp ?? 0) }) {
                    Text("Siguiente skin: \(next.name) (\(next.xpRequired) XP)")
                        .font(.fredoka(13)).foregroundStyle(SQ.muted)
                } else {
                    Text("¡Pase completo!").font(.fredoka(13, weight: .bold)).foregroundStyle(SQ.gold)
                }
            }
            let max = Double(SkinPalette.track.last?.xpRequired ?? 1)
            ProgressView(value: min(Double(store.player?.xp ?? 0) / max, 1))
                .tint(SQ.violet)
        }
        .padding(18)
        .sqCard()
    }

    private var trackPath: some View {
        VStack(spacing: 0) {
            ForEach(Array(SkinPalette.track.enumerated()), id: \.element.id) { i, skin in
                let unlocked = store.unlockedSkins.contains(skin)
                let selected = store.player?.selectedSkinId == skin.id
                HStack(spacing: 16) {
                    // nodo del camino (zigzag estilo Duolingo)
                    ZStack {
                        Circle()
                            .fill(unlocked ? SQ.violet : SQ.line)
                            .frame(width: 20, height: 20)
                        if i < SkinPalette.track.count - 1 {
                            Rectangle()
                                .fill(unlocked ? SQ.violet.opacity(0.4) : SQ.line)
                                .frame(width: 4, height: 96)
                                .offset(y: 48)
                        }
                    }
                    Button {
                        store.selectSkin(skin)
                    } label: {
                        HStack(spacing: 14) {
                            PixelAvatar(seed: store.player?.name ?? "?", palette: skin, size: 52)
                                .saturation(unlocked ? 1 : 0)
                                .opacity(unlocked ? 1 : 0.5)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(skin.name).font(.fredoka(17, weight: .semibold)).foregroundStyle(SQ.ink)
                                Text(unlocked ? "Desbloqueada" : "\(skin.xpRequired) XP")
                                    .font(.fredoka(13)).foregroundStyle(SQ.muted)
                            }
                            Spacer()
                            if selected {
                                Text("EQUIPADA").font(.px(8)).foregroundStyle(SQ.violet)
                            } else if !unlocked {
                                Image(systemName: "lock.fill").foregroundStyle(SQ.muted)
                            }
                        }
                        .padding(14)
                    }
                    .buttonStyle(.plain)
                    .sqCard()
                    .disabled(!unlocked)
                }
            }
        }
    }
}
