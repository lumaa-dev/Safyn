// Made by Lumaa

import Foundation

/// Search results across albums, tracks, and artists, returned by `Search.search(q:title:artist:upc:isrc:filter:limit:offset:)`.
public struct SearchResult: Codable, Sendable, Hashable {
	/// Every kind in ONE ranking, the most likely answer first and the least likely last. Honors the search
	/// `filter` (a single kind when it is not `.all`). Empty from a server older than the list.
	public let results: [SearchEntry]

	/// Matching albums.
	public let albums: [MediaInfo]

	/// Matching tracks.
	public let tracks: [MediaInfo]

	/// Matching artists.
	public let artists: [ArtistInfo]

	private enum CodingKeys: String, CodingKey {
		case results, albums, tracks, artists
	}

	public init(results: [SearchEntry] = [], albums: [MediaInfo], tracks: [MediaInfo], artists: [ArtistInfo]) {
		self.results = results
		self.albums = albums
		self.tracks = tracks
		self.artists = artists
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		results = try container.decodeIfPresent([SearchEntry].self, forKey: .results) ?? []
		albums = try container.decode([MediaInfo].self, forKey: .albums)
		tracks = try container.decode([MediaInfo].self, forKey: .tracks)
		artists = try container.decode([ArtistInfo].self, forKey: .artists)
	}
}
