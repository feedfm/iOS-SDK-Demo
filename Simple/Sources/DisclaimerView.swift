import SwiftUI

/// The music licensing disclaimer, presented from the "Powered by Feed.fm"
/// attribution in the full player as a bottom sheet that is only as tall as
/// the disclaimer text. Swiping down or tapping the dimmed area dismisses it.
struct DisclaimerView: View {
    @State private var contentHeight: CGFloat = 0

    static let text = """
    There is no affiliation, connection, association or endorsement of the \
    products, goods or services displayed on this page by the copyright \
    owners, featured recording artists and authors of the sound recordings \
    (and the musical works embodied therein) transmitted through the Feed.fm \
    player
    """

    /// Pre-computed sheet height so the sheet already has (nearly) its final
    /// size when the slide-up begins. Presenting at a too-small detent and
    /// letting the measured height correct it animates a resize mid-slide,
    /// which reads as the text stretching sideways.
    private var estimatedHeight: CGFloat {
        let width = UIScreen.main.bounds.width - 48   // horizontal padding
        let font = UIFont.preferredFont(forTextStyle: .callout)
        let bounds = (Self.text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil)
        return ceil(bounds.height) + 28 + 16          // top + bottom padding
    }

    var body: some View {
        Text(Self.text)
            .font(.callout)
            .foregroundColor(FRTheme.ink)
            // Always lay out at full natural height, even if the sheet is
            // smaller — otherwise the text truncates to fit the proposed
            // height and reports a one-line height (feedback loop).
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 28)    // clears the drag indicator
            .padding(.bottom, 16)
            .background(
                // Report the text block's real height; it fine-tunes the
                // estimate (SwiftUI and UIKit text wrapping can differ by a
                // hairline) without a visible resize.
                GeometryReader { geo in
                    Color.clear.preference(key: SheetHeightKey.self, value: geo.size.height)
                }
            )
            .onPreferenceChange(SheetHeightKey.self) { contentHeight = $0 }
            .presentationDetents([.height(contentHeight > 0 ? contentHeight : estimatedHeight)])
            .presentationDragIndicator(.visible)
            .presentationBackground(FRTheme.screenBG)
            .preferredColorScheme(.dark)
    }
}

private struct SheetHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
