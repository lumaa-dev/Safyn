// Made by Lumaa

import Foundation

/// A single member of a playlist, returned when inviting a member via `Playlist.addMember(pid:username:)`.
public struct PlaylistMemberRow: Codable, Sendable, Hashable {
	/// The membership record's ID.
	public let id: String

	/// The playlist's ID.
	public let playlistId: String

	/// The member's user ID.
	public let userId: String

	/// When this member was added, as a Unix timestamp in milliseconds.
	public let addedAt: Int64

	public init(id: String, playlistId: String, userId: String, addedAt: Int64) {
		self.id = id
		self.playlistId = playlistId
		self.userId = userId
		self.addedAt = addedAt
	}

	/// `addedAt` converted to a `Date`.
	public var addedAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(addedAt) / 1000)
	}
}
