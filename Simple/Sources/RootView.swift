import SwiftUI

struct RootView: View {
    @State private var store = PlayerStore()

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                StationListView(store: store)

                if store.isOpen {
                    MiniBarView(store: store)
                        .opacity(store.isExpanded ? 0 : 1)
                        .offset(y: store.isExpanded ? 8 : 0)
                        .allowsHitTesting(!store.isExpanded)

                    FullPlayerView(store: store)
                        // collapsed: push fully off-screen. The sheet ignores the
                        // safe area (fills the physical screen), so it must travel
                        // the full physical height, not just the safe-area height.
                        .offset(y: store.isExpanded
                                ? 0
                                : geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom)
                }
            }
        }
    }
}
