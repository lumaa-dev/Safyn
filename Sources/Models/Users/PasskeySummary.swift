// Made by Lumaa

import Foundation

/// One of the requesting user's own registered passkeys, from `User.passkeys`. Public keys are never
/// returned.
public struct PasskeySummary: Codable, Sendable, Hashable, Identifiable {
	/// The passkey's ID.
	public let id: String

	/// The owning user's ID.
	public let userId: String

	/// A user-assigned label, if one was given at registration.
	public let label: String?

	/// The authenticator's reported device type, e.g. `"singleDevice"`/`"multiDevice"`.
	public let deviceType: String?

	/// Whether the credential is backed up (synced) by the platform.
	public let backedUp: Bool?

	/// When the passkey was registered, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	/// When the passkey was last used to log in, as a Unix timestamp in milliseconds.
	public let lastUsedAt: Int64?

	public init(id: String, userId: String, label: String?, deviceType: String?, backedUp: Bool?, createdAt: Int64, lastUsedAt: Int64?) {
		self.id = id
		self.userId = userId
		self.label = label
		self.deviceType = deviceType
		self.backedUp = backedUp
		self.createdAt = createdAt
		self.lastUsedAt = lastUsedAt
	}

	/// `createdAt` converted to a `Date`.
	public var createdAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
	}

	/// `lastUsedAt` converted to a `Date`, if present.
	public var lastUsedAtDate: Date? {
		lastUsedAt.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000) }
	}
}
