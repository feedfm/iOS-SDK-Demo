import SwiftUI
import Observation
import FeedMedia

/// Observable wrapper around `FMAudioPlayer.shared(). Uses the SDK's
/// notification-driven pattern and exposes display state + intents to the UI.
@Observable @MainActor
final class PlayerStore {
    // Library
    private(set) var stations: [RadioStation] = []

    // Now playing
    private(set) var activeStationId: String?
    private(set) var title = ""
    private(set) var artist = ""
    private(set) var isPlaying = false
    private(set) var canSkip = false
    private(set) var liked = false
    private(set) var disliked = false
    private(set) var elapsed: Double = 0
    private(set) var duration: Double = 0

    // UI
    var isOpen = false
    var isExpanded = false

    @ObservationIgnored private let player = FMAudioPlayer.shared()

    var activeStation: RadioStation? {
        stations.first { $0.id == activeStationId }
    }
    /// Index-derived seed for the active station's fallback artwork.
    var artSeed: Int {
        (stations.firstIndex { $0.id == activeStationId }).map { $0 + 1 } ?? 1
    }
    /// Remaining seconds, or nil when the current item has no known duration.
    var remaining: Double? {
        duration > 0 ? max(0, duration - elapsed) : nil
    }
    var progress: Double {
        duration > 0 ? min(1, max(0, elapsed / duration)) : 0
    }

    init() {
        reloadStations()
        sync()
        observe()

        // This isn't strictly required in this app: `RootView` (and therefore
        // this store) is only constructed once the player is already available,
        // so the `reloadStations()` call above already has the station list.
        // It's only needed if the store were initialized *before* the player
        // became available — `stationList` is empty until then. `whenAvailable`
        // fires the first closure immediately if the player is already
        // available, or later once it becomes available, so the list loads in
        // both cases.
        player.whenAvailable({ [weak self] in
            self?.reloadStations()
        }, notAvailable: {})
    }

    /// Rebuilds the display station list from the player's current `stationList`.
    ///
    /// Safe to call repeatedly. It runs automatically once the player becomes
    /// available; call it again after `FMAudioPlayer.updateSession(_:)` refreshes
    /// the list, since the SDK posts no notification for that change.
    func reloadStations() {
        let sdkStations = (player.stationList as? [FMStation]) ?? []
        stations = sdkStations.enumerated().map { idx, s in
            RadioStation(id: s.identifier,
                         name: s.name,
                         options: (s.options as? [String: Any]) ?? [:],
                         index: idx)
        }
        // `activeStation` is declared non-null but the SDK returns nil before
        // the player is initialized, so bridge through an optional.
        let active: FMStation? = player.activeStation
        activeStationId = active?.identifier
    }

    private func observe() {
        // No matching `removeObserver` is needed: since iOS 9 the selector-based
        // API stores observers as zeroing weak references, so the center neither
        // retains this store nor messages it after deallocation. (A manual remove
        // would be required only for the block-based `addObserver(forName:...)`,
        // which retains its closure.)
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
        let active: FMStation? = player.activeStation
        activeStationId = active?.identifier
    }

    // MARK: Intents

    func select(_ station: RadioStation) {
        // Tapping the already-active station just re-opens the full player.
        if isOpen && activeStationId == station.id {
            expand()
            return
        }
        guard let fm = (player.stationList as? [FMStation])?
            .first(where: { $0.identifier == station.id }) else { return }

        let alreadyOpen = isOpen
        player.setActiveStation(fm, withCrossfade: false)
        _ = player.play()
        isOpen = true

        if alreadyOpen {
            // The player is already on screen (mini or minimized) — its
            // off-screen frame is committed, so we can grow straight up.
            expand()
        } else {
            // First open: start collapsed so the sheet has an off-screen frame
            // to animate from. `FullPlayerView.onAppear` triggers the expansion
            // once SwiftUI has committed that initial layout.
            isExpanded = false
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
