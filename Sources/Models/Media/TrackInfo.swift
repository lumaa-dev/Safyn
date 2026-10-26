// Made by Lumaa

import Foundation

/// A single track within an ``AlbumDetail``'s tracklist.
public struct TrackInfo: Codable, Sendable, Hashable {
	/// The track's MusicBrainz recording ID.
	public let id: String

	/// The track's title.
	public let title: String

	/// The track's position within its disc. A multi-disc album repeats the numbers once per disc.
	public let trackNumber: Double

	/// The disc the track is on; see ``AlbumDetail/discs``.
	public let discNumber: Double

	/// The track's duration, in seconds.
	public let duration: Double

	/// The release's release date, if known.
	public let releaseDate: Date?

	/// Whether `releaseDate` has already passed.
	public let released: Bool

	/// Whether the requesting user already has this track in their library.
	public let inLibrary: Bool

	/// Whether the requesting user has an active (non-failed) request for this track.
	public let requested: Bool

	/// Nafyn's internal media ID, if this recording has been downloaded by anyone.
	public let mediaId: String?

	public init(id: String, title: String, trackNumber: Double, discNumber: Double, duration: Double, releaseDate: Date?, released: Bool, inLibrary: Bool, requested: Bool, mediaId: String?) {
		self.id = id
		self.title = title
		self.trackNumber = trackNumber
		self.discNumber = discNumber
		self.duration = duration
		self.releaseDate = releaseDate
		self.released = released
		self.inLibrary = inLibrary
		self.requested = requested
		self.mediaId = mediaId
	}
}
