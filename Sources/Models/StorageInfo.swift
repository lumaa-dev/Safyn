// Made by Lumaa

import Foundation

/// Disk and per-user storage usage stats for the server's music directory, returned by `Settings.storage()`.
public struct StorageInfo: Codable, Sendable, Hashable {
	/// A single user's storage usage breakdown.
	///
	/// - Note: The OpenAPI spec doesn't fully detail this object's fields beyond it being a per-user
	///   breakdown, so only the fields that could be confidently inferred are decoded strictly;
	///   everything else degrades gracefully to `nil` rather than failing the whole decode.
	public struct UserUsage: Codable, Sendable, Hashable {
		/// The user's ID.
		public let userId: String

		/// The user's username, if included.
		public let username: String?

		/// Bytes used by this user, if included.
		public let usedBytes: Double?

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.userId = try container.decode(String.self, forKey: .userId)
			self.username = try? container.decodeIfPresent(String.self, forKey: .username)
			self.usedBytes = try? container.decodeIfPresent(Double.self, forKey: .usedBytes)
		}

		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(userId, forKey: .userId)
			try container.encodeIfPresent(username, forKey: .username)
			try container.encodeIfPresent(usedBytes, forKey: .usedBytes)
		}

		private enum CodingKeys: String, CodingKey {
			case userId, username, usedBytes
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
