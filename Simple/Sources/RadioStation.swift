import Foundation

/// A station prepared for display, decoupled from the SDK's `FMStation` so it can
/// be constructed and tested from a plain options dictionary.
struct RadioStation: Identifiable, Equatable {
    let id: String
    let name: String
    let subheader: String?
    let backgroundImageURL: URL?
    let gradient: [String]

    /// Brand-derived gradient pairs (from the design bundle's `data.jsx`), used for
    /// fallback artwork when a station has no `background_image_url`.
    static let gradientPalette: [[String]] = [
        ["#61B978", "#007680"],
        ["#02B2AF", "#001E2A"],
        ["#9747FF", "#001E2A"],
        ["#26A69A", "#004D40"],
        ["#FB7460", "#5A23B3"],
        ["#FA5E49", "#9747FF"],
        ["#6FC084", "#2C763F"],
        ["#007680", "#0F3A56"],
    ]

    init(id: String, name: String, options: [String: Any], index: Int) {
        self.id = id
        self.name = name

        if let sub = options["subheader"] as? String, !sub.isEmpty {
            subheader = sub
        } else {
            subheader = nil
        }

        if let raw = options["background_image_url"] as? String,
           !raw.isEmpty,
           let url = URL(string: raw) {
            backgroundImageURL = url
        } else {
            backgroundImageURL = nil
        }

        let palette = RadioStation.gradientPalette
        gradient = palette[((index % palette.count) + palette.count) % palette.count]
    }
}
