// Made by Lumaa

import Foundation

/// A playlist's full details: metadata, owner, members, and entries.
///
/// Returned by `Playlist.get(pid:)`. Public playlists are readable by anonymous visitors, so `viewer.userId`
/// may be `nil` when no `authToken` was set.
public struct PlaylistDetail: Codable, Sendable, Hashable {
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

	/// The first page of the playlist's track entries, in order. Page through the rest via `Playlist.tracks(pid:)`.
	public let entries: [PlaylistEntry]

	/// The total number of entries in the playlist, across all pages.
	public let entriesTotal: Int

	/// Whether there are more entries beyond ``entries`` to page through via `Playlist.tracks(pid:)`.
	public let entriesHasMore: Bool

	/// The requesting viewer's relationship to this playlist.
	public let viewer: Viewer

	public init(playlist: PlaylistRow, owner: NafynUser, members: [NafynUser], entries: [PlaylistEntry], entriesTotal: Int, entriesHasMore: Bool, viewer: Viewer) {
		self.playlist = playlist
		self.owner = owner
		self.members = members
		self.entries = entries
		self.entriesTotal = entriesTotal
		self.entriesHasMore = entriesHasMore
		self.viewer = viewer
	}
}
