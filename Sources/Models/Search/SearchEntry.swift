// Made by Lumaa

import Foundation

/// One row of the search list: a track, an album or an artist.
///
/// ``SearchResult/results`` holds them in a single ranking, the most likely answer first and the least likely last.
public struct SearchEntry: Codable, Sendable, Hashable, Identifiable {
	/// What a row is.
	public enum Kind: String, Codable, Sendable, Hashable {
		case track
		case album
		case artist
		/// A kind this client doesn't know yet.
		case unknown

		public init(from decoder: Decoder) throws {
			let raw = try decoder.singleValueContainer().decode(String.self)
			self = Kind(rawValue: raw) ?? .unknown
		}
	}

	/// Whether the row is a track, an album or an artist.
	public let kind: Kind

	/// How well the row matches the query, `0...1` (above `1` with a UPC/ISRC match), comparable across kinds.
	public let relevance: Double

	/// The track or album, when ``kind`` is ``Kind/track`` or ``Kind/album``.
	public let media: MediaInfo?

	/// The artist, when ``kind`` is ``Kind/artist``.
	public let artist: ArtistInfo?

	/// Unique within one response: the kind and the MusicBrainz ID.
	public var id: String {
		"\(kind.rawValue)-\(artist?.musicbrainzId ?? media?.id ?? "")"
	}

	public init(kind: Kind, relevance: Double, media: MediaInfo? = nil, artist: ArtistInfo? = nil) {
		self.kind = kind
		self.relevance = relevance
		self.media = media
		self.artist = artist
	}
}
