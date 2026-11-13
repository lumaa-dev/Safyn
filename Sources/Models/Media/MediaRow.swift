// Made by Lumaa

import Foundation

/// A single track in a user's library.
public struct MediaRow: Codable, Sendable, Hashable {
	/// Nafyn's internal media ID.
	public let id: String

	/// The MusicBrainz recording ID.
	public let musicbrainzId: String

	/// The track's title.
	public let title: String

	/// The track's artist name.
	public let artistName: String

	/// The artist's MusicBrainz ID, if known.
	public let artistMbid: String?

	/// The album title, if known.
	public let album: String?

	/// The MusicBrainz release-group ID.
	public let albumId: String

	/// Whether the album is a full album or an EP, if known.
	public let albumType: AlbumKind?

	/// A cover art URL, if known.
	public let coverArt: String?

	/// The track's position within its disc, if the server sends it. A multi-disc album repeats the numbers once per disc.
	public let trackNumber: Double?

	/// The disc the track is on, if the server sends it; see ``LibraryAlbumResponse/discs``.
	public let discNumber: Double?

	/// The release date, as a Unix timestamp in seconds, if known.
	public let releaseDate: Int64?

	/// The track's duration, in seconds.
	public let duration: Double

	/// The record label, if known.
	public let label: String?

	/// The AcoustID fingerprint, if known.
	public let fingerprint: String?

	/// The Apple Music identifier, if known.
	public let amId: String?

	/// The file size, in bytes, if known.
	public let fileSize: Int64?

	/// When this track was added to the library, as a Unix timestamp in milliseconds.
	public let addedAt: Int64

	/// The track carries a cover uploaded by a user, served by `Library.cover(id:token:)`; it wins over ``coverArt``.
	/// See ``hasUploadedCover``.
	public let hasCustomCover: LenientBool?

	/// Whether ``hasCustomCover`` is set: show `Library.cover(id:token:)` rather than ``coverArt``.
	public var hasUploadedCover: Bool { self.hasCustomCover?.value ?? false }

	public init(id: String, musicbrainzId: String, title: String, artistName: String, artistMbid: String?, album: String?, albumId: String, albumType: AlbumKind?, coverArt: String?, releaseDate: Int64?, duration: Double, label: String?, fingerprint: String?, amId: String?, fileSize: Int64?, addedAt: Int64, trackNumber: Double? = nil, discNumber: Double? = nil, hasCustomCover: Bool = false) {
		self.id = id
		self.musicbrainzId = musicbrainzId
		self.title = title
		self.artistName = artistName
		self.artistMbid = artistMbid
		self.album = album
		self.albumId = albumId
		self.albumType = albumType
		self.coverArt = coverArt
		self.releaseDate = releaseDate
		self.duration = duration
		self.label = label
		self.fingerprint = fingerprint
		self.amId = amId
		self.fileSize = fileSize
		self.addedAt = addedAt
		self.trackNumber = trackNumber
		self.discNumber = discNumber
		self.hasCustomCover = LenientBool(hasCustomCover)
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
