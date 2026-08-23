// Made by Lumaa

import Foundation

/// A summary of one of the requesting user's own API tokens (app passwords, currently used for Subsonic
/// auth), without its plaintext value.
///
/// Returned by `User.apiTokens`. The token's plaintext value is only ever included once, in the
/// ``CreateApiTokenResponse`` returned by `User.createApiToken(name:)` — it can't be retrieved again afterward.
public struct ApiTokenSummary: Codable, Sendable, Hashable {
	/// The token's ID.
	public let id: String

	/// The ID of the user this token belongs to.
	public let userId: String

	/// A user-assigned label for this token, if one was set.
	public let name: String?

	/// When this token was created, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	/// When this token was last used, as a Unix timestamp in milliseconds, if it's been used.
	public let lastUsedAt: Int64?

	public init(id: String, userId: String, name: String?, createdAt: Int64, lastUsedAt: Int64?) {
		self.id = id
		self.userId = userId
		self.name = name
		self.createdAt = createdAt
		self.lastUsedAt = lastUsedAt
	}

	/// `createdAt` converted to a `Date`.
	public var createdAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
	}

	/// `lastUsedAt` converted to a `Date`, if known.
	public var lastUsedAtDate: Date? {
		lastUsedAt.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000) }
	}
}
