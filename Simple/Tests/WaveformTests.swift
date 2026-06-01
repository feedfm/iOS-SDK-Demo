import Testing

struct WaveformTests {
    @Test func returnsRequestedCount() {
        #expect(Waveform.barHeights(seed: 1, bars: 7).count == 7)
        #expect(Waveform.barHeights(seed: 3, bars: 11).count == 11)
    }

    @Test func zeroBarsReturnsEmpty() {
        #expect(Waveform.barHeights(seed: 1, bars: 0).isEmpty)
    }

    @Test func heightsWithinRange() {
        for h in Waveform.barHeights(seed: 5, bars: 20) {
            #expect(h >= 0.32)
            #expect(h <= 0.94)
        }
    }

    @Test func deterministicForSameSeed() {
        #expect(Waveform.barHeights(seed: 2, bars: 9) == Waveform.barHeights(seed: 2, bars: 9))
    }

    @Test func differsBySeed() {
        #expect(Waveform.barHeights(seed: 1, bars: 9) != Waveform.barHeights(seed: 2, bars: 9))
    }
}
