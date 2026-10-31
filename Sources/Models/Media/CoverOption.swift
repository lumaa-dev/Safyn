// Made by Lumaa

import Foundation

/// Whether a ``CoverOption`` comes from the album's release-group or from one of its releases.
public enum CoverOptionKind: String, Codable, Sendable, Hashable {
	case releaseGroup = "release-group"
	case release
}

/// One cover art choice for an album, as returned by `Library.coverOptions`.
public struct CoverOption: Codable, Sendable, Hashable {
	/// The release or release-group MBID.
	public let id: String

	/// Whether `id` is a release-group or a release.
	public let kind: CoverOptionKind

	/// The release's title.
	public let title: String

	/// Extra detail such as date, country and format, if any.
	public let details: String?

	/// The Cover Art Archive URL to store as `coverArt`.
	public let url: String

	public init(id: String, kind: CoverOptionKind, title: String, details: String? = nil, url: String) {
		self.id = id
		self.kind = kind
		self.title = title
		self.details = details
		self.url = url
	}
}

/// The result of `Library.coverOptions`.
public struct CoverOptionsResponse: Codable, Sendable, Hashable {
	/// The available covers: the release-group's own front cover, then each release's.
	public let options: [CoverOption]

	public init(options: [CoverOption]) {
		self.options = options
	}
}

/// The result of `Artist.image`.
public struct ArtistImageResponse: Codable, Sendable, Hashable {
	/// The artist's picture URL, or `nil` when no source has one.
	public let image: String?

	public init(image: String?) {
		self.image = image
	}
}
