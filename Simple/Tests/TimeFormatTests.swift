import XCTest

final class TimeFormatTests: XCTestCase {
    func testFormatsWholeMinutes() {
        XCTAssertEqual(TimeFormat.mmss(0), "0:00")
        XCTAssertEqual(TimeFormat.mmss(60), "1:00")
        XCTAssertEqual(TimeFormat.mmss(600), "10:00")
    }

    func testFormatsSecondsWithLeadingZero() {
        XCTAssertEqual(TimeFormat.mmss(1), "0:01")
        XCTAssertEqual(TimeFormat.mmss(9), "0:09")
        XCTAssertEqual(TimeFormat.mmss(213), "3:33")
    }

    func testRoundsToNearestSecond() {
        XCTAssertEqual(TimeFormat.mmss(1.4), "0:01")
        XCTAssertEqual(TimeFormat.mmss(1.6), "0:02")
    }

    func testClampsInvalidInput() {
        XCTAssertEqual(TimeFormat.mmss(-5), "0:00")
        XCTAssertEqual(TimeFormat.mmss(.nan), "0:00")
        XCTAssertEqual(TimeFormat.mmss(.infinity), "0:00")
    }
}
