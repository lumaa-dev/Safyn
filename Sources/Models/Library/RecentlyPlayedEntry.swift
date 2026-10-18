// Made by Lumaa

import Foundation

/// A single entry in the requesting user's recently-played history, as returned by `Library.recentlyPlayed`.
public struct RecentlyPlayedEntry: Codable, Sendable, Hashable {
	/// The kind of media this entry refers to.
	public let type: RecentEntryKind

	/// The MusicBrainz ID (track), release-group ID (album), or playlist ID this entry refers to.
	public let refId: String

	/// When this entry was played, as a Unix timestamp in milliseconds.
	public let playedAt: Int64

	/// The item's title.
	public let title: String

	/// A subtitle (e.g. artist name), if applicable.
	public let subtitle: String?

	/// A cover art URL, if known.
	public let coverArt: String?

	/// For `type == .playlist` only: the playlist's raw image version stamp.
	public let playlistImage: String?

	/// A relative app URL to open this item.
	public let href: String

	public init(type: RecentEntryKind, refId: String, playedAt: Int64, title: String, subtitle: String?, coverArt: String?, playlistImage: String?, href: String) {
		self.type = type
		self.refId = refId
		self.playedAt = playedAt
		self.title = title
		self.subtitle = subtitle
		self.coverArt = coverArt
		self.playlistImage = playlistImage
		self.href = href
	}

	/// `playedAt` converted to a `Date`.
	public var playedAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(playedAt) / 1000)
	}
}
