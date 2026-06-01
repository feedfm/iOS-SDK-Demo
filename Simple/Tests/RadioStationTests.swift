import Foundation
import Testing

struct RadioStationTests {
    @Test func parsesNameAndId() {
        let s = RadioStation(id: "abc", name: "Deep Focus", options: [:], index: 0)
        #expect(s.id == "abc")
        #expect(s.name == "Deep Focus")
    }

    @Test func parsesSubheaderWhenPresent() {
        let s = RadioStation(id: "1", name: "X",
                             options: ["subheader": "Minimal beats for flow"], index: 0)
        #expect(s.subheader == "Minimal beats for flow")
    }

    @Test func subheaderNilWhenMissingOrEmpty() {
        #expect(RadioStation(id: "1", name: "X", options: [:], index: 0).subheader == nil)
        #expect(RadioStation(id: "1", name: "X", options: ["subheader": ""], index: 0).subheader == nil)
    }

    @Test func parsesBackgroundImageURLWhenValid() {
        let s = RadioStation(id: "1", name: "X",
                             options: ["background_image_url": "https://example.com/a.jpg"], index: 0)
        #expect(s.backgroundImageURL == URL(string: "https://example.com/a.jpg"))
    }

    @Test func backgroundImageURLNilWhenMissing() {
        #expect(RadioStation(id: "1", name: "X", options: [:], index: 0).backgroundImageURL == nil)
    }

    @Test func gradientIsDeterministicByIndex() {
        let palette = RadioStation.gradientPalette
        #expect(RadioStation(id: "1", name: "X", options: [:], index: 0).gradient == palette[0])
        #expect(RadioStation(id: "1", name: "X", options: [:], index: 1).gradient == palette[1])
    }

    @Test func gradientWrapsAroundPalette() {
        let palette = RadioStation.gradientPalette
        let wrapped = RadioStation(id: "1", name: "X", options: [:], index: palette.count).gradient
        #expect(wrapped == palette[0])
    }
}
