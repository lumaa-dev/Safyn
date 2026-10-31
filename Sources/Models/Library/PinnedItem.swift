// Made by Lumaa

import Foundation

/// A pinned album, playlist or track, as returned by `Pins.list`.
public struct PinnedItem: Codable, Sendable, Hashable {
	/// Whether this pin is an album, a playlist or a track.
	public let kind: PinKind

	/// The Media ID (track), release-group MBID (album) or playlist ID this pin refers to.
	public let refId: String

	/// When this item was pinned, as a Unix timestamp in milliseconds.
	public let pinnedAt: Int64

	/// The item's title.
	public let title: String

	/// A subtitle (e.g. artist name), if applicable.
	public let subtitle: String?

	/// The page for this item in the web app.
	public let href: String

	/// A cover art URL, if known.
	public let coverArt: String?

	/// The Media ID whose cover represents this item, if any.
	public let coverMediaId: String?

	/// For `kind == .track` only: the track. The spec leaves its shape open, so it's untyped.
	public let media: JSONValue?

	/// For `kind == .playlist` only: the playlist's raw image version stamp.
	public let playlistImage: String?

	/// For `kind == .playlist` only: whether the caller owns the playlist.
	public let isOwner: Bool?

	/// For `kind == .playlist` only: whether the caller was invited to the playlist.
	public let isMember: Bool?

	public init(kind: PinKind, refId: String, pinnedAt: Int64, title: String, subtitle: String? = nil, href: String, coverArt: String? = nil, coverMediaId: String? = nil, media: JSONValue? = nil, playlistImage: String? = nil, isOwner: Bool? = nil, isMember: Bool? = nil) {
		self.kind = kind
		self.refId = refId
		self.pinnedAt = pinnedAt
		self.title = title
		self.subtitle = subtitle
		self.href = href
		self.coverArt = coverArt
		self.coverMediaId = coverMediaId
		self.media = media
		self.playlistImage = playlistImage
		self.isOwner = isOwner
		self.isMember = isMember
	}

	/// `pinnedAt` converted to a `Date`.
	public var pinnedAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(pinnedAt) / 1000)
	}
}

/// The result of `Pins.pin`/`Pins.unpin`.
public struct PinResponse: Codable, Sendable, Hashable {
	/// Whether the item is now pinned. The spec doesn't mark it required, so it may be absent.
	public let pinned: Bool?

	public init(pinned: Bool? = nil) {
		self.pinned = pinned
	}
}
