import SwiftUI

struct StationListView: View {
    @ObservedObject var store: PlayerStore

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                HStack {
                    Image("feedradio_wordmark_white")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                    Spacer()
                }
                .padding(.vertical, 12)

                ForEach(Array(store.stations.enumerated()), id: \.element.id) { idx, station in
                    StationRow(
                        station: station,
                        index: idx,
                        isActive: store.isOpen && store.activeStationId == station.id
                    ) {
                        store.select(station)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, store.isOpen ? 96 : 40)
        }
        .background(FRTheme.screenBG.ignoresSafeArea())
    }
}
