/// Formats track metadata for display.
enum MetadataFormat {
    /// Joins artist and album as "Artist - Album", omitting whichever is empty.
    static func artistAlbum(artist: String, album: String) -> String {
        [artist, album].filter { !$0.isEmpty }.joined(separator: " - ")
    }
}
