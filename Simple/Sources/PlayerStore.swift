import SwiftUI
import FeedMedia

/// Observable wrapper around `FMAudioPlayer.shared()`. Mirrors SwiftDemo's
/// notification-driven pattern and exposes display state + intents to the UI.
final class PlayerStore: ObservableObject {
    // Library
    @Published private(set) var stations: [RadioStation] = []

    // Now playing
    @Published private(set) var activeStationId: String?
    @Published private(set) var title = ""
    @Published private(set) var artist = ""
    @Published private(set) var isPlaying = false
    @Published private(set) var canSkip = false
    @Published private(set) var liked = false
    @Published private(set) var disliked = false
    @Published private(set) var elapsed: Double = 0
    @Published private(set) var duration: Double = 0

    // UI
    @Published var isOpen = false
    @Published var isExpanded = false

    private let player = FMAudioPlayer.shared()

    var activeStation: RadioStation? {
        stations.first { $0.id == activeStationId }
    }
    /// Remaining seconds, or nil when the current item has no known duration.
    var remaining: Double? {
        duration > 0 ? max(0, duration - elapsed) : nil
    }
    var progress: Double {
        duration > 0 ? min(1, max(0, elapsed / duration)) : 0
    }

    init() {
        let sdkStations = (player.stationList as? [FMStation]) ?? []
        stations = sdkStations.enumerated().map { idx, s in
            RadioStation(id: s.identifier,
                         name: s.name,
                         options: (s.options as? [String: Any]) ?? [:],
                         index: idx)
        }
        activeStationId = player.activeStation.identifier
        sync()
        observe()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func observe() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(stateChanged),
                       name: .FMAudioPlayerPlaybackStateDidChange, object: player)
        nc.addObserver(self, selector: #selector(itemChanged),
                       name: .FMAudioPlayerCurrentItemDidBeginPlayback, object: player)
        nc.addObserver(self, selector: #selector(timeElapsed),
                       name: .FMAudioPlayerTimeElapse, object: player)
        nc.addObserver(self, selector: #selector(skipChanged),
                       name: .FMAudioPlayerSkipStatus, object: player)
        nc.addObserver(self, selector: #selector(likeChanged),
                       name: .FMAudioPlayerLikeStatusChange, object: player)
        nc.addObserver(self, selector: #selector(stationChanged),
                       name: .FMAudioPlayerActiveStationDidChange, object: player)
    }

    private func sync() {
        let item = player.currentItem
        title = item?.name ?? ""
        artist = item?.artist ?? ""
        duration = item?.duration ?? 0
        elapsed = player.currentPlaybackTime
        isPlaying = player.playbackState == .playing
        canSkip = player.canSkip
        liked = item?.liked ?? false
        disliked = item?.disliked ?? false
    }

    @objc private func stateChanged() {
        isPlaying = player.playbackState == .playing
        if player.playbackState == .complete { elapsed = 0 }
    }
    @objc private func itemChanged() {
        let item = player.currentItem
        title = item?.name ?? ""
        artist = item?.artist ?? ""
        duration = item?.duration ?? 0
        elapsed = 0
        canSkip = player.canSkip
        liked = item?.liked ?? false
        disliked = item?.disliked ?? false
    }
    @objc private func timeElapsed() { elapsed = player.currentPlaybackTime }
    @objc private func skipChanged() { canSkip = player.canSkip }
    @objc private func likeChanged() {
        liked = player.currentItem?.liked ?? false
        disliked = player.currentItem?.disliked ?? false
    }
    @objc private func stationChanged() {
        activeStationId = player.activeStation.identifier
    }

    // MARK: Intents

    func select(_ station: RadioStation) {
        if isOpen && activeStationId == station.id {
            expand()
            return
        }
        guard let fm = (player.stationList as? [FMStation])?
            .first(where: { $0.identifier == station.id }) else { return }
        player.setActiveStation(fm, withCrossfade: false)
        _ = player.play()
        isOpen = true
        isExpanded = false
        // render the mini first, then grow into the full sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) { [weak self] in
            self?.expand()
        }
    }

    func togglePlay() {
        if isPlaying { player.pause() } else { _ = player.play() }
    }
    func next() { player.skip() }
    func toggleLike() { liked ? player.unlike() : player.like() }
    func toggleDislike() { disliked ? player.unlike() : player.dislike() }
    func expand() { withAnimation(FRTheme.expand) { isExpanded = true } }
    func minimize() { withAnimation(FRTheme.expand) { isExpanded = false } }
}
