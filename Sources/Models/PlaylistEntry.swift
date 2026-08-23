// Made by Lumaa

import Foundation

/// A single track entry within a playlist, alongside who added it and when, with the track fully resolved.
///
/// Appears as the first page of entries in ``PlaylistDetail``, and is the (spec-untyped) shape returned
/// by `Playlist.tracks(pid:)` for subsequent pages.
public struct PlaylistEntry: Codable, Sendable, Hashable {
	/// The entry's ID.
	public let entryId: String

	/// The user who added this entry.
	public let addedBy: NafynUser

	/// The entry's position within the playlist.
	public let position: Double

	/// When this entry was added, as a Unix timestamp in milliseconds.
	public let addedAt: Int64

	/// The referenced track.
	public let media: MediaRow

	public init(entryId: String, addedBy: NafynUser, position: Double, addedAt: Int64, media: MediaRow) {
		self.entryId = entryId
		self.addedBy = addedBy
		self.position = position
		self.addedAt = addedAt
		self.media = media
	}

	/// `addedAt` converted to a `Date`.
	public var addedAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(addedAt) / 1000)
	}
}
