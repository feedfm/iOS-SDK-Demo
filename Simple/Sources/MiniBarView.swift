import SwiftUI

struct MiniBarView: View {
    let store: PlayerStore

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if let station = store.activeStation {
                    ArtworkView(station: station, seed: store.artSeed, bars: 6, cornerRadius: 9)
                        .frame(width: 46, height: 46)
                        .padding(EdgeInsets(top: 0 , leading: 8 , bottom: 0, trailing: 8))
                }
                VStack(alignment: .leading, spacing: 2) {
                    MarqueeText(text: store.title,
                                font: .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize,
                                                  weight: .semibold),
                                color: FRTheme.ink)
                    MarqueeText(text: store.artistAlbum,
                                font: .preferredFont(forTextStyle: .caption1),
                                color: FRTheme.ink2)
                }
                Spacer(minLength: 8)
                Button(action: store.togglePlay) {
                    Image(systemName: store.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 22))
                        .foregroundColor(FRTheme.ink)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(store.isPlaying ? "Pause" : "Play")
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // live progress bar: its own strip flush along the bottom edge,
            // clear of the artwork/text above it
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.16))
                    Capsule().fill(FRTheme.accent)
                        .frame(width: store.progress * geo.size.width)
                }
            }
            .frame(height: 3)
            .padding(.horizontal, 10)
            .padding(.bottom, 6)
        }
        .frame(height: 64)
        .background(
            LinearGradient(colors: [FRTheme.accent.opacity(0.14), FRTheme.surface1],
                           startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(FRTheme.hair, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.5), radius: 15, y: 10)
        .contentShape(Rectangle())
        .onTapGesture { store.expand() }
        .padding(.horizontal, 12)
        .padding(.bottom, 14)
    }
}
