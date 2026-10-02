import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class GameStore {
    private(set) var player: Player?
    private var context: ModelContext?

    var isLoggedIn: Bool { player != nil }

    func attach(context: ModelContext) {
        self.context = context
        if player == nil {
            // Sesión persistente: último usuario logueado
            if let saved = UserDefaults.standard.string(forKey: "sq.session"),
               let p = try? context.fetch(FetchDescriptor<Player>(
                    predicate: #Predicate { $0.email == saved })).first {
                player = p
            }
            seedDemoFriendsIfNeeded()
        }
    }

    // MARK: - Auth
    enum AuthError: LocalizedError {
        case exists, notFound, badPassword, invalid
        var errorDescription: String? {
            switch self {
            case .exists: return "Ya existe una cuenta con ese email"
            case .notFound: return "No existe ninguna cuenta con ese email"
            case .badPassword: return "Contraseña incorrecta"
            case .invalid: return "Revisa los campos"
            }
        }
    }

    func signUp(name: String, email: String, password: String) throws {
        guard let context, !name.isEmpty, email.contains("@"), password.count >= 4
        else { throw AuthError.invalid }
        let existing = try context.fetch(FetchDescriptor<Player>(
            predicate: #Predicate { $0.email == email }))
        guard existing.isEmpty else { throw AuthError.exists }
        let p = Player(name: name, email: email, password: password)
        context.insert(p)
        try context.save()
        finishLogin(p)
    }

    func logIn(email: String, password: String) throws {
        guard let context else { return }
        guard let p = try context.fetch(FetchDescriptor<Player>(
            predicate: #Predicate { $0.email == email })).first
        else { throw AuthError.notFound }
        guard p.password == password else { throw AuthError.badPassword }
        finishLogin(p)
    }

    func logOut() {
        player = nil
        UserDefaults.standard.removeObject(forKey: "sq.session")
    }

    private func finishLogin(_ p: Player) {
        player = p
        UserDefaults.standard.set(p.email, forKey: "sq.session")
        seedDemoFriendsIfNeeded()
    }

    // MARK: - Misiones
    func completion(for mission: Mission) -> Completion? {
        player?.completions.first { $0.missionId == mission.id }
    }

    /// Completa una misión. Si ya estaba completada, se registra la repetición
    /// pero sin XP ni recompensas.
    @discardableResult
    func completeMission(_ mission: Mission) -> Completion {
        guard let p = player else { return .init(missionId: mission.id, xpEarned: 0, rewarded: false) }
        let alreadyDone = p.completions.contains { $0.missionId == mission.id && $0.rewarded }
        let c = Completion(missionId: mission.id, xpEarned: alreadyDone ? 0 : mission.xp, rewarded: !alreadyDone)
        p.completions.append(c)
        if !alreadyDone { p.xp += mission.xp }
        save()
        return c
    }

    // MARK: - Skins / pase
    var unlockedSkins: [SkinPalette] {
        SkinPalette.track.filter { $0.xpRequired <= (player?.xp ?? 0) }
    }
    var currentSkin: SkinPalette {
        unlockedSkins.first { $0.id == player?.selectedSkinId } ?? .default
    }
    func selectSkin(_ skin: SkinPalette) {
        guard unlockedSkins.contains(skin) else { return }
        player?.selectedSkinId = skin.id
        save()
    }

    // MARK: - Racha
    /// Días consecutivos (hasta hoy o ayer) con al menos una misión completada.
    var streak: Int {
        let cal = Calendar.current
        let days = Set((player?.completions ?? []).map { cal.startOfDay(for: $0.date) })
        var count = 0
        var day = cal.startOfDay(for: .now)
        if !days.contains(day) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: day),
                  days.contains(yesterday) else { return 0 }
            day = yesterday
        }
        while days.contains(day) {
            count += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return count
    }

    func completedToday() -> Bool {
        let today = Calendar.current.startOfDay(for: .now)
        return (player?.completions ?? []).contains { Calendar.current.startOfDay(for: $0.date) == today }
    }

    // MARK: - Posts
    func publishPost(for mission: Mission, caption: String) {
        player?.posts.append(Post(missionId: mission.id, caption: caption))
        save()
    }

    // MARK: - Amigos y mensajes
    func addFriend(named name: String) {
        guard !name.isEmpty,
              !(player?.friends.contains { $0.name == name } ?? false) else { return }
        player?.friends.append(Friend(name: name, level: Int(name.count % 9) + 1))
        save()
    }

    func sendMessage(to friend: String, text: String) {
        guard !text.isEmpty else { return }
        player?.messages.append(ChatMessage(friendName: friend, text: text, isFromMe: true))
        save()
    }

    func sendMission(_ mission: Mission, to friend: String) {
        player?.messages.append(ChatMessage(
            friendName: friend, text: "¡Te reto a esta misión!", isFromMe: true,
            attachedMissionId: mission.id))
        save()
    }

    func messages(with friend: String) -> [ChatMessage] {
        (player?.messages.filter { $0.friendName == friend } ?? [])
            .sorted { $0.date < $1.date }
    }

    var level: Int { (player?.xp ?? 0) / 200 + 1 }

    private func seedDemoFriendsIfNeeded() {
        guard let p = player, p.friends.isEmpty else { return }
        ["Aitana", "Marc", "Júlia", "Pol"].forEach { p.friends.append(Friend(name: $0, level: $0.count + 2)) }
        p.messages.append(ChatMessage(friendName: "Marc", text: "¡He completado el Bunkers! 🔥", isFromMe: false))
        save()
    }

    private func save() { try? context?.save() }
}
