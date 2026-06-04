import Testing

struct MetadataFormatTests {
    @Test func joinsArtistAndAlbumWithDash() {
        #expect(MetadataFormat.artistAlbum(artist: "The Crocker Five", album: "Live at 510") == "The Crocker Five - Live at 510")
    }

    @Test func artistOnlyWhenAlbumEmpty() {
        #expect(MetadataFormat.artistAlbum(artist: "The Crocker Five", album: "") == "The Crocker Five")
    }

    @Test func albumOnlyWhenArtistEmpty() {
        #expect(MetadataFormat.artistAlbum(artist: "", album: "Live at 510") == "Live at 510")
    }

    @Test func emptyWhenBothEmpty() {
        #expect(MetadataFormat.artistAlbum(artist: "", album: "") == "")
    }
}
