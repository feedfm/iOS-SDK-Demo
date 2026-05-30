import SwiftUI

struct StationRow: View {
    let station: RadioStation
    let index: Int
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ArtworkView(station: station, seed: index + 1, bars: 7, cornerRadius: 14)
                    .frame(width: 58, height: 58)
                    .padding(EdgeInsets(top: 0 , leading: 14, bottom: 0, trailing: 8))
                VStack(alignment: .leading, spacing: 3) {
                    Text(station.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(FRTheme.ink)
                    if let sub = station.subheader {
                        Text(sub)
                            .font(.system(size: 13))
                            .foregroundColor(FRTheme.ink2)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 8)
                Image(systemName: isActive ? "pause.fill" : "play.fill")
                    .font(.system(size: 18))
                    .foregroundColor(FRTheme.accent)
                    .padding([ .horizontal ])
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isActive ? FRTheme.surface2 : FRTheme.surface1)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isActive ? FRTheme.accent.opacity(0.55) : FRTheme.hair, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
