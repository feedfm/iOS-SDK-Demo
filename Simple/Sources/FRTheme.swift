import SwiftUI

/// feed radio visual tokens, ported from the design bundle's app.css.
enum FRTheme {
    static let screenBG   = Color(hex: "#04141E")
    static let surface1   = Color(hex: "#08263A")
    static let surface2   = Color(hex: "#0C344E")
    static let accent     = Color(hex: "#61B978")
    static let accentSoft = Color(hex: "#61B978").opacity(0.16)
    static let dislike    = Color(hex: "#FF8A77")

    static let ink  = Color.white.opacity(0.92)
    static let ink2 = Color.white.opacity(0.60)
    static let ink3 = Color.white.opacity(0.38)
    static let hair = Color.white.opacity(0.08)

    static let expand = Animation.timingCurve(0.4, 0, 0.2, 1, duration: 0.4)

    /// Diagonal gradient for fallback artwork from a pair of hex strings.
    static func artworkGradient(_ hexes: [String]) -> LinearGradient {
        LinearGradient(colors: hexes.map { Color(hex: $0) },
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension Color {
    /// Creates a color from a `#RRGGBB` hex string; `.clear` on malformed input.
    init(hex: String) {
        let s = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        var value: UInt64 = 0
        guard s.count == 6, Scanner(string: s).scanHexInt64(&value) else {
            self = .clear
            return
        }
        self = Color(
            red:   Double((value & 0xFF0000) >> 16) / 255.0,
            green: Double((value & 0x00FF00) >> 8) / 255.0,
            blue:  Double(value & 0x0000FF) / 255.0
        )
    }
}
