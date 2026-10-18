// Made by Lumaa

import Foundation

/// A summary of an album derived from the requesting user's library, as returned by `Library.albums`.
public struct AlbumRow: Codable, Sendable, Hashable {
	/// The MusicBrainz release-group ID.
	public let id: String

	/// The MusicBrainz recording ID of one of the album's owned tracks.
	public let mbId: String

	/// The album's title.
	public let title: String

	/// The album's artist name.
	public let artistName: String

	/// The artist's MusicBrainz ID, if known.
	public let artistMbid: String?

	/// A cover art URL, if known.
	public let coverArt: String?

	/// The release date, as a Unix timestamp in seconds, if known.
	public let releaseDate: Int64?

	/// The combined duration, in seconds, of all owned tracks from this album.
	public let duration: Double

	/// The number of owned tracks from this album.
	public let trackCount: Int

	/// When the earliest owned track from this album was added, as a Unix timestamp in milliseconds.
	public let addedAt: Int64

	public init(id: String, mbId: String, title: String, artistName: String, artistMbid: String?, coverArt: String?, releaseDate: Int64?, duration: Double, trackCount: Int, addedAt: Int64) {
		self.id = id
		self.mbId = mbId
		self.title = title
		self.artistName = artistName
		self.artistMbid = artistMbid
		self.coverArt = coverArt
		self.releaseDate = releaseDate
		self.duration = duration
		self.trackCount = trackCount
		self.addedAt = addedAt
	}

	/// `releaseDate` converted to a `Date`, if known.
	public var releaseDateValue: Date? {
		releaseDate.map { Date(timeIntervalSince1970: TimeInterval($0)) }
	}

	/// `addedAt` converted to a `Date`.
	public var addedAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(addedAt) / 1000)
	}
}
