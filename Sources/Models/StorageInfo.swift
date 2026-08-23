// Made by Lumaa

import Foundation

/// Disk and per-user storage usage stats for the server's music directory, returned by `Settings.storage()`.
public struct StorageInfo: Codable, Sendable, Hashable {
	/// A single user's storage usage breakdown.
	public struct UserUsage: Codable, Sendable, Hashable {
		/// The user's ID.
		public let userId: String

		/// The user's username.
		public let username: String

		/// A display name, if the user set one.
		public let displayName: String?

		/// Bytes owned by this user. Shared tracks count for each owner.
		public let bytes: Double

		public init(userId: String, username: String, displayName: String?, bytes: Double) {
			self.userId = userId
			self.username = username
			self.displayName = displayName
			self.bytes = bytes
		}
	}

	/// The total disk size, in bytes.
	public let totalBytes: Double

	/// The free disk space remaining, in bytes.
	public let freeBytes: Double

	/// Bytes used by Nafyn's music directory specifically.
	public let usedByNafynBytes: Double

	/// A per-user storage breakdown.
	public let perUser: [UserUsage]

	public init(totalBytes: Double, freeBytes: Double, usedByNafynBytes: Double, perUser: [UserUsage]) {
		self.totalBytes = totalBytes
		self.freeBytes = freeBytes
		self.usedByNafynBytes = usedByNafynBytes
		self.perUser = perUser
	}
}
