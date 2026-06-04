import SwiftUI
import FeedMedia

/// `FMMarqueeLabel` refuses to animate unless its `firstAvailableViewController`
/// helper (which predates SwiftUI) finds the owning view controller — and in a
/// SwiftUI hosting hierarchy it returns nil, so the label sizes itself, decides
/// it should scroll, and then never starts. Shadowing the helper with a plain
/// responder-chain walk finds the `UIHostingController` and unblocks scrolling.
private final class HostedMarqueeLabel: FMMarqueeLabel {
    @objc func firstAvailableViewController() -> UIViewController? {
        var responder = next
        while let current = responder {
            if let viewController = current as? UIViewController { return viewController }
            responder = current.next
        }
        return nil
    }
}

/// A single line of text rendered with the SDK's `FMMarqueeLabel`, which
/// scrolls (marquees) automatically when the text is too wide to fit and
/// stays static otherwise.
struct MarqueeText: UIViewRepresentable {
    let text: String
    let font: UIFont
    let color: Color

    func makeUIView(context: Context) -> FMMarqueeLabel {
        // The SDK header is nullability-unaudited, so without the explicit type
        // annotation Swift would infer an optional here.
        let label: FMMarqueeLabel = HostedMarqueeLabel(frame: .zero)
        // 30 pt/s scroll with a small transparency fade at the clipped edges.
        label.rate = 30
        label.fadeLength = 8
        return label
    }

    func updateUIView(_ label: FMMarqueeLabel, context: Context) {
        label.text = text
        label.font = font
        label.textColor = UIColor(color)
    }

    // Without this, SwiftUI sizes the label at its full intrinsic (text) width
    // and the surrounding stack clips it — the label never sees an overflow, so
    // it never scrolls. Clamping to the proposed width makes long text overflow
    // the label itself, which is what triggers the marquee.
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: FMMarqueeLabel, context: Context) -> CGSize? {
        let intrinsic = uiView.intrinsicContentSize
        let height = max(intrinsic.height, uiView.font.lineHeight)
        guard let width = proposal.width, width.isFinite else {
            return CGSize(width: intrinsic.width, height: height)
        }
        return CGSize(width: min(intrinsic.width, width), height: height)
    }
}
