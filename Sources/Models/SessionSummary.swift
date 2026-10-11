// Made by Lumaa

import Foundation

/// One of the requesting user's active login sessions (one per device/login), from `User.sessions`.
///
/// A session's ID is the `jti` claim of the token issued at login. Revoke one with
/// `User.deleteSession(id:)`, or the current one with `Auth.logout`.
public struct SessionSummary: Codable, Sendable, Hashable, Identifiable {
	/// The session's ID.
	public let id: String

	/// A label derived from the device's User-Agent, e.g. `"Chrome on macOS"`.
	public let deviceLabel: String

	/// When the session was created, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	/// When the session was last seen, as a Unix timestamp in milliseconds.
	///
	/// The server does not update this yet, so it currently equals ``createdAt``.
	public let lastSeenAt: Int64

	/// Whether this is the session making the request.
	public let isCurrent: Bool

	public init(id: String, deviceLabel: String, createdAt: Int64, lastSeenAt: Int64, isCurrent: Bool) {
		self.id = id
		self.deviceLabel = deviceLabel
		self.createdAt = createdAt
		self.lastSeenAt = lastSeenAt
		self.isCurrent = isCurrent
	}

	/// `createdAt` converted to a `Date`.
	public var createdAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
	}

	/// `lastSeenAt` converted to a `Date`.
	public var lastSeenAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(lastSeenAt) / 1000)
	}
}
