// Made by Lumaa

import Foundation

/// The result of an authentication call (`Auth.login`/`Auth.register`): the authenticated user and their session token.
public struct AuthResponse: Codable, Sendable, Hashable {
	/// The authenticated user.
	public let user: NafynUser

	/// The user's session token. Assign this to ``NafynServer/authToken`` to authenticate subsequent calls.
	public let token: String

	public init(user: NafynUser, token: String) {
		self.user = user
		self.token = token
	}
}

/// The result of removing something that has no extra metadata (e.g. leaving a playlist, deleting a playlist).
public struct RemovedResponse: Codable, Sendable, Hashable {
	/// Whether the item was removed.
	public let removed: Bool

	public init(removed: Bool) {
		self.removed = removed
	}
}

/// The result of removing a library track, which may also delete the underlying file.
public struct RemovedWithFileResponse: Codable, Sendable, Hashable {
	/// Whether the library entry was removed.
	public let removed: Bool

	/// Whether the underlying file was deleted (no other user referenced it anymore).
	public let fileDeleted: Bool

	public init(removed: Bool, fileDeleted: Bool) {
		self.removed = removed
		self.fileDeleted = fileDeleted
	}
}

/// The result of `Library.album(id:)`: one album's metadata plus only the tracks the requesting user owns from it.
public struct LibraryAlbumResponse: Codable, Sendable, Hashable {
	/// The album's metadata.
	public let album: AlbumRow

	/// The tracks from this album the requesting user owns.
	public let tracks: [MediaRow]

	public init(album: AlbumRow, tracks: [MediaRow]) {
		self.album = album
		self.tracks = tracks
	}
}

/// The result of `Library.recordRecentlyPlayed(type:refId:)`.
public struct RecordedResponse: Codable, Sendable, Hashable {
	/// Whether the entry was recorded.
	public let recorded: Bool

	public init(recorded: Bool) {
		self.recorded = recorded
	}
}

/// The result of `Playlist.reorder(pid:order:)`.
public struct ReorderedResponse: Codable, Sendable, Hashable {
	/// Whether the playlist was reordered.
	public let reordered: Bool

	public init(reordered: Bool) {
		self.reordered = reordered
	}
}

/// Whether open registration is currently allowed, from `Settings.registrationOpen()`/`Settings.setRegistrationOpen(_:)`.
public struct RegistrationOpenResponse: Codable, Sendable, Hashable {
	/// Whether `/register` currently allows sign-up without a registration token.
	public let open: Bool

	public init(open: Bool) {
		self.open = open
	}
}

/// The result of `User.createApiToken(name:)`: a newly created API token, including its plaintext value.
///
/// The `token` field is only ever returned here, at creation time — it can't be retrieved again
/// afterward. Compare with ``ApiTokenSummary``, which omits it.
public struct CreateApiTokenResponse: Codable, Sendable, Hashable {
	/// The token's ID.
	public let id: String

	/// The ID of the user this token belongs to.
	public let userId: String

	/// A user-assigned label for this token, if one was set.
	public let name: String?

	/// The plaintext token value. Shown only this once.
	public let token: String

	/// When this token was created, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	/// When this token was last used, as a Unix timestamp in milliseconds, if it's been used.
	public let lastUsedAt: Int64?

	public init(id: String, userId: String, name: String?, token: String, createdAt: Int64, lastUsedAt: Int64?) {
		self.id = id
		self.userId = userId
		self.name = name
		self.token = token
		self.createdAt = createdAt
		self.lastUsedAt = lastUsedAt
	}
}

/// The `/api/_nafyn` health check response, used internally by ``NafynInstance/connect(to:session:)``.
struct NafynPingResponse: Codable, Sendable {
	struct ServerInfo: Codable, Sendable {
		let id: UUID
		let date: Int64
	}

	let nafyn: Bool
	let response: ServerInfo
}
