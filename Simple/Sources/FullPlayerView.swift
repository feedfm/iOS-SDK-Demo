import SwiftUI

struct FullPlayerView: View {
    @ObservedObject var store: PlayerStore

    private var artSeed: Int {
        (store.stations.firstIndex { $0.id == store.activeStationId }).map { $0 + 1 } ?? 1
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 0)
            if let station = store.activeStation {
                ArtworkView(station: station, seed: artSeed, bars: 11, cornerRadius: 24)
                    .frame(maxWidth: 300)
                    .aspectRatio(1, contentMode: .fit)
                    .shadow(color: .black.opacity(0.5), radius: 30, y: 24)
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 5) {
                Text(store.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(FRTheme.ink)
                Text(store.artist)
                    .font(.system(size: 16))
                    .foregroundColor(FRTheme.ink2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 18)

            ProgressBar(progress: store.progress).frame(height: 14)
            HStack {
                Text(TimeFormat.mmss(store.elapsed))
                Spacer()
                Text(store.remaining.map { "-" + TimeFormat.mmss($0) } ?? "--:--")
            }
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(FRTheme.ink2)
            .padding(.top, 8)

            controls.padding(.top, 22)

            Text("Tap the chevron or swipe down to minimize")
                .font(.system(size: 12))
                .foregroundColor(FRTheme.ink3)
                .padding(.top, 18)
        }
        .padding(.horizontal, 28)
        .padding(.top, 12)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                FRTheme.screenBG
                RadialGradient(colors: [FRTheme.accent.opacity(0.22), .clear],
                               center: .top, startRadius: 0, endRadius: 420)
            }.ignoresSafeArea()
        )
        .gesture(
            DragGesture().onEnded { value in
                if value.translation.height > 60 { store.minimize() }
            }
        )
    }

    private var header: some View {
        HStack {
            Button(action: store.minimize) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(FRTheme.ink)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            Spacer()
            VStack(spacing: 2) {
                Text("NOW PLAYING")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundColor(FRTheme.ink3)
                Text(store.activeStation?.name ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(FRTheme.ink)
            }
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
    }

    private var controls: some View {
        HStack {
            sideButton(
                system: store.disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown",
                tint: store.disliked ? FRTheme.dislike : FRTheme.ink2,
                bg: store.disliked ? FRTheme.dislike.opacity(0.14) : .clear,
                action: store.toggleDislike
            )
            Spacer()
            Button(action: store.togglePlay) {
                Image(systemName: store.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(FRTheme.screenBG)
                    .frame(width: 72, height: 72)
                    .background(FRTheme.accent)
                    .clipShape(Circle())
                    .shadow(color: FRTheme.accent.opacity(0.45), radius: 18, y: 8)
            }
            Spacer()
            Button(action: store.next) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 26))
                    .foregroundColor(store.canSkip ? FRTheme.ink : FRTheme.ink3)
                    .frame(width: 56, height: 56)
            }
            .disabled(!store.canSkip)
            Spacer()
            sideButton(
                system: store.liked ? "hand.thumbsup.fill" : "hand.thumbsup",
                tint: store.liked ? FRTheme.accent : FRTheme.ink2,
                bg: store.liked ? FRTheme.accentSoft : .clear,
                action: store.toggleLike
            )
        }
    }

    private func sideButton(system: String, tint: Color, bg: Color,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 26))
                .foregroundColor(tint)
                .frame(width: 52, height: 52)
                .background(bg)
                .clipShape(Circle())
        }
    }
}

/// Display-only progress bar with a knob (no seeking).
struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            let p = min(1, max(0, progress))
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.14)).frame(height: 6)
                Capsule().fill(FRTheme.accent).frame(width: p * geo.size.width, height: 6)
                Circle().fill(Color.white)
                    .frame(width: 14, height: 14)
                    .offset(x: p * geo.size.width - 7)
            }
            .frame(height: geo.size.height, alignment: .center)
        }
    }
}
