import Foundation

/// Formats playback times for the player UI.
enum TimeFormat {
    /// Formats seconds as `m:ss` (e.g. `0:01`, `3:33`).
    /// Non-finite or non-positive input formats as `0:00`.
    static func mmss(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds > 0 else { return "0:00" }
        let total = Int(seconds.rounded())
        return "\(total / 60):" + String(format: "%02d", total % 60)
    }
}
