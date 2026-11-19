// Made by Lumaa

import Foundation

/// A Nafyn user account.
public struct NafynUser: Codable, Sendable, Hashable {
	/// The user's unique identifier.
	public let id: String

	/// The user's login username.
	public let username: String

	/// A display name, if the user set one.
	public let displayName: String?

	/// The user's avatar URL, if they have one set.
	public let avatar: String?

	/// The user's granted permissions.
	public let permissions: Permissions

	/// The user's linked ListenBrainz username, if any.
	public let listenBrainz: String?

	/// The user's linked Discogs username, if any.
	public let discogs: String?

	public init(id: String, username: String, displayName: String? = nil, avatar: String? = nil, permissions: Permissions = [], listenBrainz: String? = nil, discogs: String? = nil) {
		self.id = id
		self.username = username
		self.displayName = displayName
		self.avatar = avatar
		self.permissions = permissions
		self.listenBrainz = listenBrainz
		self.discogs = discogs
	}
}
