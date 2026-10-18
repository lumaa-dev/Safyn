// Made by Lumaa

import Foundation

/// A one-time registration token that unlocks account creation when open registration is disabled.
public struct RegisterTokenRow: Codable, Sendable, Hashable {
	/// The token record's ID.
	public let id: String

	/// The token string itself, passed as `Auth.register(..., token:)`.
	public let token: String

	/// The user ID of whoever created this token.
	public let createdBy: String

	/// When this token was created, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	/// When this token expires, as a Unix timestamp in milliseconds.
	public let expiresAt: Int64

	/// When this token was consumed, as a Unix timestamp in milliseconds, if it has been used.
	public let usedAt: Int64?

	public init(id: String, token: String, createdBy: String, createdAt: Int64, expiresAt: Int64, usedAt: Int64?) {
		self.id = id
		self.token = token
		self.createdBy = createdBy
		self.createdAt = createdAt
		self.expiresAt = expiresAt
		self.usedAt = usedAt
	}
}
