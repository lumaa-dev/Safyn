// Made by Lumaa

import Foundation

/// The public profile of a user, as returned by `Users.profile`.
public struct UserProfile: Codable, Sendable, Hashable {
	/// A public playlist listed on a profile.
	public struct PlaylistSummary: Codable, Sendable, Hashable, Identifiable {
		/// The playlist ID.
		public let id: String

		/// The playlist's title.
		public let title: String

		/// The playlist's description, if any.
		public let description: String?

		/// The playlist's cover version token, if it has one.
		public let image: String?

		/// The number of tracks in the playlist.
		public let trackCount: Int

		/// When the playlist was last updated. The spec doesn't document the unit.
		public let updatedAt: Int64?

		public init(id: String, title: String, description: String? = nil, image: String? = nil, trackCount: Int, updatedAt: Int64? = nil) {
			self.id = id
			self.title = title
			self.description = description
			self.image = image
			self.trackCount = trackCount
			self.updatedAt = updatedAt
		}
	}

	/// The user's ID.
	public let id: String

	/// The user's username.
	public let username: String

	/// A display name, if the user set one.
	public let displayName: String?

	/// The avatar version token. The image is at `User.avatar(id:)`.
	public let avatar: String?

	/// The user's ListenBrainz handle, if linked.
	public let listenBrainz: String?

	/// The user's Discogs handle, if linked.
	public let discogs: String?

	/// The number of tracks in the user's library.
	public let trackCount: Int

	/// The user's public playlists.
	public let playlists: [PlaylistSummary]

	public init(id: String, username: String, displayName: String? = nil, avatar: String? = nil, listenBrainz: String? = nil, discogs: String? = nil, trackCount: Int, playlists: [PlaylistSummary] = []) {
		self.id = id
		self.username = username
		self.displayName = displayName
		self.avatar = avatar
		self.listenBrainz = listenBrainz
		self.discogs = discogs
		self.trackCount = trackCount
		self.playlists = playlists
	}
}
