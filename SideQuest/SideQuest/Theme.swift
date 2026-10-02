import SwiftUI

// MARK: - Paleta (de la landing de SideQuest)
enum SQ {
    static let violet = Color(red: 0x6c/255, green: 0x3d/255, blue: 0xf4/255)
    static let violetDeep = Color(red: 0x5b/255, green: 0x30/255, blue: 0xe0/255)
    static let violetSoft = Color(red: 0x8b/255, green: 0x5c/255, blue: 0xf6/255)
    static let ink = Color(red: 0x17/255, green: 0x14/255, blue: 0x1f/255)
    static let inkSoft = Color(red: 0x1b/255, green: 0x14/255, blue: 0x30/255)
    static let muted = Color(red: 0x6b/255, green: 0x68/255, blue: 0x80/255)
    static let line = Color(red: 0xec/255, green: 0xea/255, blue: 0xf4/255)
    static let lav = Color(red: 0xf5/255, green: 0xf3/255, blue: 0xfe/255)
    static let gold = Color(red: 0xf5/255, green: 0xa6/255, blue: 0x23/255)
    static let goldInk = Color(red: 0x3a/255, green: 0x27/255, blue: 0x03/255)
    static let pink = Color(red: 0xff/255, green: 0x54/255, blue: 0x70/255)
    static let green = Color(red: 0x58/255, green: 0xcc/255, blue: 0x02/255)
    static let card = Color.white
}

extension Font {
    static func px(_ size: CGFloat) -> Font { .custom("PressStart2P-Regular", size: size) }
    static func fredoka(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .custom("Fredoka", size: size).weight(weight)
    }
}

// MARK: - Botón estilo "pixel block" (borde inferior duro, como juego)
struct PixelButtonStyle: ButtonStyle {
    var bg: Color = SQ.violet
    var fg: Color = .white
    var pressedBg: Color = SQ.violetDeep

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.fredoka(17, weight: .semibold))
            .foregroundStyle(fg)
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? pressedBg : bg)
            .overlay(alignment: .bottom) {
                Rectangle().fill(.black.opacity(0.18)).frame(height: 4)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension View {
    func sqCard(corner: CGFloat = 22) -> some View {
        self
            .background(SQ.card)
            .overlay(RoundedRectangle(cornerRadius: corner).stroke(SQ.line, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .shadow(color: SQ.ink.opacity(0.06), radius: 16, y: 8)
    }
}

// MARK: - Avatar pixel-art determinista
struct PixelAvatar: View {
    var seed: String
    var palette: SkinPalette = .default
    var size: CGFloat = 64

    private let grid = 8

    var body: some View {
        let bits = Self.bits(for: seed)
        Canvas { ctx, canvasSize in
            let cell = min(canvasSize.width, canvasSize.height) / CGFloat(grid)
            for y in 0..<grid {
                for x in 0..<grid {
                    let i = y * grid + x
                    let color: Color? = {
                        switch bits[i] {
                        case 1: return palette.skin
                        case 2: return palette.hair
                        case 3: return SQ.ink      // ojos / detalle
                        case 4: return palette.shirt
                        default: return nil
                        }
                    }()
                    if let color {
                        ctx.fill(Path(CGRect(x: CGFloat(x) * cell, y: CGFloat(y) * cell,
                                             width: cell, height: cell)), with: .color(color))
                    }
                }
            }
        }
        .frame(width: size, height: size)
        .background(palette.bg)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.18, style: .continuous))
    }

    // 8x8: simétrico; filas 0-1 pelo, 2-5 cara, 6-7 cuerpo
    static func bits(for seed: String) -> [Int] {
        var rng = SeededRNG(seed: seed)
        var bits = [Int](repeating: 0, count: 64)
        for y in 0..<8 {
            for x in 0..<4 {
                var v = 0
                if y < 2 {
                    v = rng.next() % 4 < 3 ? 2 : 0
                } else if y < 6 {
                    v = 1
                    if y == 3 && (x == 1 || x == 2) { v = 3 }          // ojos
                    if y == 5 && x == 1 && rng.next() % 3 == 0 { v = 3 } // boca
                } else {
                    v = rng.next() % 5 < 4 ? 4 : 0
                }
                bits[y * 8 + x] = v
                bits[y * 8 + (7 - x)] = v
            }
        }
        return bits
    }
}

struct SeededRNG {
    private var state: UInt64
    init(seed: String) {
        var h: UInt64 = 5381
        for b in seed.utf8 { h = ((h << 5) &+ h) &+ UInt64(b) }
        state = h == 0 ? 0x9e3779b97f4a7c15 : h
    }
    mutating func next() -> Int {
        state ^= state << 13; state ^= state >> 7; state ^= state << 17
        return Int(state % 1000)
    }
}
