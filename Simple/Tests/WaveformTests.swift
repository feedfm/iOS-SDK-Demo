import XCTest

final class WaveformTests: XCTestCase {
    func testReturnsRequestedCount() {
        XCTAssertEqual(Waveform.barHeights(seed: 1, bars: 7).count, 7)
        XCTAssertEqual(Waveform.barHeights(seed: 3, bars: 11).count, 11)
    }

    func testZeroBarsReturnsEmpty() {
        XCTAssertTrue(Waveform.barHeights(seed: 1, bars: 0).isEmpty)
    }

    func testHeightsWithinRange() {
        for h in Waveform.barHeights(seed: 5, bars: 20) {
            XCTAssertGreaterThanOrEqual(h, 0.32)
            XCTAssertLessThanOrEqual(h, 0.94)
        }
    }

    func testDeterministicForSameSeed() {
        XCTAssertEqual(Waveform.barHeights(seed: 2, bars: 9),
                       Waveform.barHeights(seed: 2, bars: 9))
    }

    func testDiffersBySeed() {
        XCTAssertNotEqual(Waveform.barHeights(seed: 1, bars: 9),
                          Waveform.barHeights(seed: 2, bars: 9))
    }
}
