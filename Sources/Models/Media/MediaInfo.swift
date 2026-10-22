// Made by Lumaa

import Foundation

/// A search result or track/album lookup result.
public struct MediaInfo: Codable, Sendable, Hashable {
	/// A reference to the album a ``MediaInfo`` belongs to, embedded when `type == .track`.
	public struct AlbumRef: Codable, Sendable, Hashable {
		/// The album's MusicBrainz release-group ID, if known.
		public let id: String?

		/// Whether the album is a full album or an EP, if known.
		public let type: AlbumKind?

		/// The album's title, if known.
		public let title: String?

		public init(id: String?, type: AlbumKind?, title: String?) {
			self.id = id
			self.type = type
			self.title = title
		}
	}

	/// Cross-service identifiers for a ``MediaInfo``, only present on some lookups.
	public struct Relations: Codable, Sendable, Hashable {
		/// The Apple Music identifier, if known.
		public let amId: String?

		public init(amId: String?) {
			self.amId = amId
		}
	}

	/// The MusicBrainz ID (recording or release-group).
	public let id: String

	/// The item's title.
	public let title: String

	/// The item's artist.
	public let artist: ArtistRef

	/// The album this item belongs to, if `type == .track`.
	public let album: AlbumRef?

	/// The kind of media this is, if known.
	public let type: MediaKind?

	/// A cover art URL, if known.
	public let coverArt: String?

	/// The release date, if known.
	public let releaseDate: Date?

	/// Whether the requesting user already has this item in their library, if known.
	public let inLibrary: Bool?

	/// The item's duration, in seconds.
	public let duration: Double

	/// The record label, if known.
	public let label: String?

	/// Cross-service identifiers, only present on some lookups.
	public let relations: Relations?

	/// Dominant colors extracted from `coverArt`, most-dominant first. Only present on single-item
	/// lookups (`Track.get(tid:)`/`Track.getByIsrc(isrc:)`) — `nil` on search results, artist
	/// discography, and request info.
	public let imageColors: [String]?

	/// Black or white, whichever contrasts best (WCAG) against `imageColors?[0]`. Only present
	/// alongside `imageColors`.
	public let textColor: String?

	/// `true` on at most one album/track search result: the top-ranked one, when it clears the minimum
	/// score and clearly beats the runner-up. Only present on search results.
	public let bestResult: Bool?

	/// Score breakdown of this result. Only present on album/track search results.
	public let match: SearchMatch?

	public init(id: String, title: String, artist: ArtistRef, album: AlbumRef?, type: MediaKind?, coverArt: String?, releaseDate: Date?, inLibrary: Bool?, duration: Double, label: String?, relations: Relations? = nil, imageColors: [String]? = nil, textColor: String? = nil, bestResult: Bool? = nil, match: SearchMatch? = nil) {
		self.id = id
		self.title = title
		self.artist = artist
		self.album = album
		self.type = type
		self.coverArt = coverArt
		self.releaseDate = releaseDate
		self.inLibrary = inLibrary
		self.duration = duration
		self.label = label
		self.relations = relations
		self.imageColors = imageColors
		self.textColor = textColor
		self.bestResult = bestResult
		self.match = match
	}
}
