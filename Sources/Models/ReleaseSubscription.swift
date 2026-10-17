// Made by Lumaa

import Foundation

/// How much of an album's release date MusicBrainz actually knows, from ``AlbumDetail/releaseDatePrecision``.
public enum ReleaseDatePrecision: String, Codable, Sendable, Hashable {
	/// The full day is known.
	case day

	/// Only the month is known; the date is padded to its first day.
	case month

	/// Only the year is known; the date is padded to its first day.
	case year
}

/// The kind of media a release subscription follows.
public enum ReleaseSubscriptionKind: String, Codable, Sendable, Hashable {
	/// An unreleased album (MusicBrainz release-group).
	case album

	/// An unreleased track (MusicBrainz recording).
	case track
}

/// An unreleased album or track the requesting user follows, from `Subscriptions.list` and `Subscriptions.create`.
///
/// At local midnight on ``releaseDate`` (in ``timezone``) the user is notified over APNs and their own webhooks.
public struct ReleaseSubscription: Codable, Sendable, Hashable, Identifiable {
	/// The subscription's ID.
	public let id: String

	/// The MusicBrainz ID that was followed (release-group for an album, recording for a track).
	public let musicbrainzId: String

	/// Whether this follows an album or a track.
	public let type: ReleaseSubscriptionKind

	/// The title, if known.
	public let title: String?

	/// The artist's name, if known.
	public let artistName: String?

	/// A cover art URL, if one is known.
	public let coverArt: String?

	/// The release date, as an ISO-8601 calendar date (`yyyy-MM-dd`).
	public let releaseDate: String

	/// The IANA timezone the release moment is computed in, e.g. `"Europe/Paris"`.
	public let timezone: String

	/// Local midnight on ``releaseDate`` in ``timezone``, as a Unix timestamp in milliseconds.
	public let releaseAt: Int64

	/// When the release notification was delivered, as a Unix timestamp in milliseconds, or `nil` if still pending.
	///
	/// Delivered subscriptions stay listed for 30 days.
	public let notifiedAt: Int64?

	/// When the subscription was created, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	public init(id: String, musicbrainzId: String, type: ReleaseSubscriptionKind, title: String?, artistName: String?, coverArt: String?, releaseDate: String, timezone: String, releaseAt: Int64, notifiedAt: Int64?, createdAt: Int64) {
		self.id = id
		self.musicbrainzId = musicbrainzId
		self.type = type
		self.title = title
		self.artistName = artistName
		self.coverArt = coverArt
		self.releaseDate = releaseDate
		self.timezone = timezone
		self.releaseAt = releaseAt
		self.notifiedAt = notifiedAt
		self.createdAt = createdAt
	}

	/// `releaseAt` converted to a `Date`.
	public var releaseAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(releaseAt) / 1000)
	}

	/// `notifiedAt` converted to a `Date`, if the notification was delivered.
	public var notifiedAtDate: Date? {
		notifiedAt.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000) }
	}

	/// `createdAt` converted to a `Date`.
	public var createdAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
	}
}
