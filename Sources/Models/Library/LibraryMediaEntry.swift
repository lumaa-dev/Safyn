// Made by Lumaa

import Foundation

/// A library track alongside every user who owns it, returned by `Library.all()`.
public struct LibraryMediaEntry: Codable, Sendable, Hashable {
	/// A minimal reference to a user who owns a given track.
	public struct Owner: Codable, Sendable, Hashable {
		/// The owner's user ID.
		public let userId: String

		/// The owner's username.
		public let username: String

		public init(userId: String, username: String) {
			self.userId = userId
			self.username = username
		}
	}

	/// The track itself.
	public let media: MediaRow

	/// Every user who has this track in their library.
	public let owners: [Owner]

	public init(media: MediaRow, owners: [Owner]) {
		self.media = media
		self.owners = owners
	}

	public init(from decoder: Decoder) throws {
		self.media = try MediaRow(from: decoder)
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.owners = try container.decode([Owner].self, forKey: .owners)
	}

	public func encode(to encoder: Encoder) throws {
		try media.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(owners, forKey: .owners)
	}

	private enum CodingKeys: String, CodingKey {
		case owners
	}
}
