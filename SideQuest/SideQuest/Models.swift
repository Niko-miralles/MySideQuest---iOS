import Foundation
import SwiftData
import SwiftUI

// MARK: - Catálogo de misiones (datos locales; sustituible por backend)
struct Mission: Identifiable {
    enum Kind: String, CaseIterable {
        case photo, riddle, checkpoint
        var icon: String {
            switch self {
            case .photo: return "camera.fill"
            case .riddle: return "book.fill"
            case .checkpoint: return "mappin.and.ellipse"
            }
        }
    }
    let id: String
    let title: String
    let city: String
    let xp: Int
    let kind: Kind
    let clue: String
    let accent: Color

    static let catalog: [Mission] = [
        .init(id: "m1", title: "El guardián del puerto", city: "Barcelona", xp: 120, kind: .photo,
              clue: "Busca el monumento que señala al mar. Sube una foto del punto más alto que veas.", accent: SQ.violet),
        .init(id: "m2", title: "Sombras del Gòtic", city: "Barcelona", xp: 90, kind: .riddle,
              clue: "Tiene cara pero no habla, da las horas sin mirar. ¿Qué es? Encuentra uno y márcalo.", accent: SQ.gold),
        .init(id: "m3", title: "Tesoro de La Rambla", city: "Barcelona", xp: 150, kind: .checkpoint,
              clue: "Camina del mar a la montaña por la rambla. Activa el checkpoint en el mosaico de Miró.", accent: SQ.pink),
        .init(id: "m4", title: "El dragón de Park Güell", city: "Barcelona", xp: 200, kind: .photo,
              clue: "El drac custodia la escalinata. Foto obligatoria con mosaico visible.", accent: SQ.green),
        .init(id: "m5", title: "Ecos de la Sagrada Família", city: "Barcelona", xp: 220, kind: .checkpoint,
              clue: "Rodea la basílica y encuentra la fachada del Nacimiento. Activa el punto en la esquina.", accent: SQ.violetSoft),
        .init(id: "m6", title: "El mercado perdido", city: "Barcelona", xp: 80, kind: .riddle,
              clue: "Frutas de colores, techo de hierro. Adivina el mercado y marca tu respuesta.", accent: SQ.gold),
        .init(id: "m7", title: "Bunkers del Carmel", city: "Barcelona", xp: 180, kind: .photo,
              clue: "La mejor vista de la ciudad está en antiguos búnkers. Foto del skyline al atardecer.", accent: SQ.pink),
        .init(id: "m8", title: "Fantasma del Born", city: "Barcelona", xp: 110, kind: .riddle,
              clue: "Santa María del Mar guarda un secreto en sus gárgolas. Descúbrelo.", accent: SQ.violet),
        .init(id: "m9", title: "Castillo de Montjuïc", city: "Barcelona", xp: 160, kind: .checkpoint,
              clue: "Sube al castillo y activa el checkpoint en el patio de armas.", accent: SQ.green),
        .init(id: "m10", title: "Las cuatro barras", city: "Barcelona", xp: 140, kind: .photo,
              clue: "Encuentra la senyera escondida entre los edificios modernistas.", accent: SQ.gold),
    ]
}

// MARK: - Battle pass: skins desbloqueables por XP total
struct SkinPalette: Hashable {
    let id: String
    let name: String
    let xpRequired: Int
    let skin: Color
    let hair: Color
    let shirt: Color
    let bg: Color

    static let `default` = SkinPalette(
        id: "classic", name: "Classic", xpRequired: 0,
        skin: Color(red: 1.0, green: 0.8, blue: 0.6),
        hair: SQ.ink, shirt: SQ.violet, bg: SQ.lav)

    static let track: [SkinPalette] = [
        .default,
        .init(id: "mint", name: "Mint", xpRequired: 100,
              skin: Color(red: 0.8, green: 1.0, blue: 0.75), hair: SQ.green, shirt: SQ.green,
              bg: Color(red: 0.90, green: 0.98, blue: 0.90)),
        .init(id: "gold", name: "Gold", xpRequired: 250,
              skin: Color(red: 1.0, green: 0.85, blue: 0.55), hair: SQ.goldInk, shirt: SQ.gold,
              bg: Color(red: 1.0, green: 0.96, blue: 0.85)),
        .init(id: "bubble", name: "Bubblegum", xpRequired: 450,
              skin: Color(red: 1.0, green: 0.72, blue: 0.78), hair: SQ.pink, shirt: SQ.pink,
              bg: Color(red: 1.0, green: 0.92, blue: 0.95)),
        .init(id: "void", name: "Void", xpRequired: 700,
              skin: Color(red: 0.75, green: 0.70, blue: 1.0), hair: SQ.inkSoft, shirt: SQ.violetDeep,
              bg: Color(red: 0.16, green: 0.12, blue: 0.28)),
        .init(id: "legend", name: "Legend", xpRequired: 1000,
              skin: SQ.gold, hair: .white, shirt: SQ.violetDeep,
              bg: Color(red: 0.14, green: 0.10, blue: 0.24)),
    ]
}

// MARK: - Persistencia (SwiftData)
@Model
final class Player {
    var name: String
    var email: String
    var password: String
    var xp: Int
    var selectedSkinId: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade) var completions: [Completion] = []
    @Relationship(deleteRule: .cascade) var posts: [Post] = []
    @Relationship(deleteRule: .cascade) var friends: [Friend] = []
    @Relationship(deleteRule: .cascade) var messages: [ChatMessage] = []

    init(name: String, email: String, password: String) {
        self.name = name; self.email = email; self.password = password
        self.xp = 0; self.selectedSkinId = SkinPalette.default.id; self.createdAt = .now
    }
}

@Model
final class Completion {
    var missionId: String
    var date: Date
    var xpEarned: Int       // 0 en repeticiones
    var rewarded: Bool

    init(missionId: String, xpEarned: Int, rewarded: Bool) {
        self.missionId = missionId; self.date = .now
        self.xpEarned = xpEarned; self.rewarded = rewarded
    }
}

@Model
final class Post {
    var missionId: String
    var caption: String
    var date: Date
    var imageSeed: String   // determina la "imagen" pixel del post

    init(missionId: String, caption: String) {
        self.missionId = missionId; self.caption = caption
        self.date = .now; self.imageSeed = missionId + String(Int(Date().timeIntervalSince1970) % 997)
    }
}

@Model
final class Friend {
    var name: String
    var level: Int
    var addedAt: Date

    init(name: String, level: Int) {
        self.name = name; self.level = level; self.addedAt = .now
    }
}

@Model
final class ChatMessage {
    var friendName: String
    var text: String
    var isFromMe: Bool
    var attachedMissionId: String?
    var date: Date

    init(friendName: String, text: String, isFromMe: Bool, attachedMissionId: String? = nil) {
        self.friendName = friendName; self.text = text
        self.isFromMe = isFromMe; self.attachedMissionId = attachedMissionId; self.date = .now
    }
}
