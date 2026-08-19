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

/// The `/api/_nafyn` health check response, used internally by ``NafynInstance/connect(to:session:)``.
struct NafynPingResponse: Codable, Sendable {
	struct ServerInfo: Codable, Sendable {
		let id: UUID
		let date: Int64
	}

	let nafyn: Bool
	let response: ServerInfo
}
