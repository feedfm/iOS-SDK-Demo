import Testing

struct TimeFormatTests {
    @Test func formatsWholeMinutes() {
        #expect(TimeFormat.mmss(0) == "0:00")
        #expect(TimeFormat.mmss(60) == "1:00")
        #expect(TimeFormat.mmss(600) == "10:00")
    }

    @Test func formatsSecondsWithLeadingZero() {
        #expect(TimeFormat.mmss(1) == "0:01")
        #expect(TimeFormat.mmss(9) == "0:09")
        #expect(TimeFormat.mmss(213) == "3:33")
    }

    @Test func roundsToNearestSecond() {
        #expect(TimeFormat.mmss(1.4) == "0:01")
        #expect(TimeFormat.mmss(1.6) == "0:02")
    }

    @Test func clampsInvalidInput() {
        #expect(TimeFormat.mmss(-5) == "0:00")
        #expect(TimeFormat.mmss(.nan) == "0:00")
        #expect(TimeFormat.mmss(.infinity) == "0:00")
    }
}
