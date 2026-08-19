// Made by Lumaa

import Foundation

/// Search results across albums, tracks, and artists, returned by `Search.search(q:filter:limit:offset:)`.
public struct SearchResult: Codable, Sendable, Hashable {
	/// Matching albums.
	public let albums: [MediaInfo]

	/// Matching tracks.
	public let tracks: [MediaInfo]

	/// Matching artists.
	public let artists: [ArtistInfo]

	public init(albums: [MediaInfo], tracks: [MediaInfo], artists: [ArtistInfo]) {
		self.albums = albums
		self.tracks = tracks
		self.artists = artists
	}
}
