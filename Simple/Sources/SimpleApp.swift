import SwiftUI
import FeedMedia

@main
struct SimpleApp: App {
    @StateObject private var availability = PlayerAvailability()

    var body: some Scene {
        WindowGroup {
            ZStack {
                FRTheme.screenBG.ignoresSafeArea()
                switch availability.status {
                case .loading:
                    ProgressView("Starting feed radio…")
                        .tint(FRTheme.accent)
                        .foregroundColor(FRTheme.ink2)
                case .available:
                    RootView()
                case .unavailable:
                    Text("Player is not available")
                        .font(.title3)
                        .foregroundColor(FRTheme.ink2)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

/// Configures the player with the demo credentials and tracks availability.
final class PlayerAvailability: ObservableObject {
    enum Status { case loading, available, unavailable }
    @Published var status: Status = .loading

    init() {
        FMLogSetLevel(FMLogLevelDebug)
        FMAudioPlayer.setClientToken("demo", secret: "demo")

        FMAudioPlayer.shared().whenAvailable({ [weak self] in
            self?.status = .available
        }, notAvailable: { [weak self] in
            self?.status = .unavailable
        })
    }
}
