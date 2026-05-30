import SwiftUI

/// Station artwork: a remote background image when available, otherwise a brand
/// gradient with a static bar-graph waveform.
struct ArtworkView: View {
    let station: RadioStation
    var seed: Int = 1
    var bars: Int = 7
    var cornerRadius: CGFloat = 14

    var body: some View {
        Group {
            if let url = station.backgroundImageURL {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        fallback
                    }
                }
            } else {
                fallback
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private var fallback: some View {
        ZStack {
            FRTheme.artworkGradient(station.gradient)
            LinearGradient(colors: [Color.white.opacity(0.22), .clear],
                           startPoint: .topLeading, endPoint: .center)
                .blendMode(.screen)
            WaveformBars(heights: Waveform.barHeights(seed: seed, bars: bars))
        }
    }
}

/// Static bar-graph waveform, positioned along the lower portion of the artwork.
private struct WaveformBars: View {
    let heights: [Double]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let inset = w * 0.10
            let areaW = w - inset * 2
            let areaH = h * 0.38
            let count = max(1, heights.count)
            let gap = areaW * 0.07 / CGFloat(count)
            let barW = (areaW - gap * CGFloat(count - 1)) / CGFloat(count)
            HStack(alignment: .bottom, spacing: gap) {
                ForEach(Array(heights.enumerated()), id: \.offset) { _, value in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.85))
                        .frame(width: barW, height: max(1, areaH * CGFloat(value)))
                }
            }
            .frame(width: areaW, height: areaH, alignment: .bottom)
            .position(x: w / 2, y: h - h * 0.14 - areaH / 2)
        }
    }
}
