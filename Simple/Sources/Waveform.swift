import Foundation

/// Deterministic bar-graph "waveform" heights for fallback station artwork,
/// ported from the design bundle's `data.jsx` generator. Seeds are expected to
/// be non-negative (station indices).
enum Waveform {
    /// Returns `bars` heights in `0.32...0.94`, deterministic for a given `seed`.
    static func barHeights(seed: Int, bars: Int) -> [Double] {
        guard bars > 0 else { return [] }
        var x = (seed + 1) * 9301 + 49297
        var out: [Double] = []
        out.reserveCapacity(bars)
        for _ in 0..<bars {
            x = (x * 9301 + 49297) % 233280
            out.append(0.32 + (Double(x) / 233280.0) * 0.62)
        }
        return out
    }
}
