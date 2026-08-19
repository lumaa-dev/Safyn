// Made by Lumaa

import Foundation

/// A playlist's full details: metadata, owner, members, and entries.
///
/// Returned by `Playlist.get(pid:)`. Public playlists are readable by anonymous visitors, so `viewer.userId`
/// may be `nil` when no `authToken` was set.
public struct PlaylistDetail: Codable, Sendable, Hashable {
	/// A single track entry within the playlist, alongside who added it and when.
	public struct Entry: Codable, Sendable, Hashable {
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
	}

	/// The requesting viewer's relationship to this playlist.
	public struct Viewer: Codable, Sendable, Hashable {
		/// The viewer's user ID, or `nil` if the request was unauthenticated.
		public let userId: String?

		/// Whether the viewer owns this playlist.
		public let isOwner: Bool

		/// Whether the viewer is an invited member of this playlist.
		public let isMember: Bool

		public init(userId: String?, isOwner: Bool, isMember: Bool) {
			self.userId = userId
			self.isOwner = isOwner
			self.isMember = isMember
		}
	}

	/// The playlist's metadata.
	public let playlist: PlaylistRow

	/// The playlist's owner.
	public let owner: NafynUser

	/// Every invited member of this playlist.
	public let members: [NafynUser]

	/// The playlist's track entries, in order.
	public let entries: [Entry]

	/// The requesting viewer's relationship to this playlist.
	public let viewer: Viewer

	public init(playlist: PlaylistRow, owner: NafynUser, members: [NafynUser], entries: [Entry], viewer: Viewer) {
		self.playlist = playlist
		self.owner = owner
		self.members = members
		self.entries = entries
		self.viewer = viewer
	}
}
