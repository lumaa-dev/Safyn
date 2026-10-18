// Made by Lumaa

import Foundation

/// A single track entry within a playlist.
public struct PlaylistEntryRow: Codable, Sendable, Hashable {
	/// The entry's ID.
	public let id: String

	/// The playlist's ID.
	public let playlistId: String

	/// The referenced track's media ID.
	public let mediaId: String

	/// The user ID of whoever added this entry.
	public let addedBy: String

	/// The entry's position within the playlist.
	public let position: Double

	/// When this entry was added, as a Unix timestamp in milliseconds.
	public let addedAt: Int64

	public init(id: String, playlistId: String, mediaId: String, addedBy: String, position: Double, addedAt: Int64) {
		self.id = id
		self.playlistId = playlistId
		self.mediaId = mediaId
		self.addedBy = addedBy
		self.position = position
		self.addedAt = addedAt
	}

	/// `addedAt` converted to a `Date`.
	public var addedAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(addedAt) / 1000)
	}
}
