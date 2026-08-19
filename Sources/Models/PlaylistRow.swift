// Made by Lumaa

import Foundation

/// A playlist's metadata.
public struct PlaylistRow: Codable, Sendable, Hashable {
	/// The playlist's ID.
	public let id: String

	/// The owner's user ID.
	public let ownerId: String

	/// The playlist's title.
	public let title: String

	/// A description, if one is set.
	public let description: String?

	/// Whether this playlist is readable by anonymous visitors.
	public let privacy: PlaylistPrivacy

	/// An opaque, cache-busting version stamp for this playlist's cover image, if it has one.
	///
	/// This is not a URL — fetch the actual image from `Playlist.image(pid:token:)`.
	public let image: String?

	/// How this playlist's entries are ordered.
	public let sortMode: PlaylistSortMode

	/// When this playlist was created, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	/// When this playlist was last updated, as a Unix timestamp in milliseconds.
	public let updatedAt: Int64

	public init(id: String, ownerId: String, title: String, description: String?, privacy: PlaylistPrivacy, image: String?, sortMode: PlaylistSortMode, createdAt: Int64, updatedAt: Int64) {
		self.id = id
		self.ownerId = ownerId
		self.title = title
		self.description = description
		self.privacy = privacy
		self.image = image
		self.sortMode = sortMode
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}

	/// `createdAt` converted to a `Date`.
	public var createdAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
	}

	/// `updatedAt` converted to a `Date`.
	public var updatedAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(updatedAt) / 1000)
	}
}
