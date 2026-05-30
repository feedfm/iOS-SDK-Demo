import XCTest

final class RadioStationTests: XCTestCase {
    func testParsesNameAndId() {
        let s = RadioStation(id: "abc", name: "Deep Focus", options: [:], index: 0)
        XCTAssertEqual(s.id, "abc")
        XCTAssertEqual(s.name, "Deep Focus")
    }

    func testParsesSubheaderWhenPresent() {
        let s = RadioStation(id: "1", name: "X",
                             options: ["subheader": "Minimal beats for flow"], index: 0)
        XCTAssertEqual(s.subheader, "Minimal beats for flow")
    }

    func testSubheaderNilWhenMissingOrEmpty() {
        XCTAssertNil(RadioStation(id: "1", name: "X", options: [:], index: 0).subheader)
        XCTAssertNil(RadioStation(id: "1", name: "X", options: ["subheader": ""], index: 0).subheader)
    }

    func testParsesBackgroundImageURLWhenValid() {
        let s = RadioStation(id: "1", name: "X",
                             options: ["background_image_url": "https://example.com/a.jpg"], index: 0)
        XCTAssertEqual(s.backgroundImageURL, URL(string: "https://example.com/a.jpg"))
    }

    func testBackgroundImageURLNilWhenMissing() {
        XCTAssertNil(RadioStation(id: "1", name: "X", options: [:], index: 0).backgroundImageURL)
    }

    func testGradientIsDeterministicByIndex() {
        let palette = RadioStation.gradientPalette
        XCTAssertEqual(RadioStation(id: "1", name: "X", options: [:], index: 0).gradient, palette[0])
        XCTAssertEqual(RadioStation(id: "1", name: "X", options: [:], index: 1).gradient, palette[1])
    }

    func testGradientWrapsAroundPalette() {
        let palette = RadioStation.gradientPalette
        let wrapped = RadioStation(id: "1", name: "X", options: [:], index: palette.count).gradient
        XCTAssertEqual(wrapped, palette[0])
    }
}
