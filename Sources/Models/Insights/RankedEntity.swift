// Made by Lumaa

import Foundation

/// One ranked entity (track, album, artist, or playlist) within a period, used across the `Insights`
/// summary endpoints and `Insights.top(type:period:week:month:year:)`.
public struct RankedEntity: Codable, Sendable, Hashable {
	/// The kind of entity this ranking is for.
	public let entityType: RankedEntityKind

	/// The entity's identifier: a media ID for tracks, a release-group MusicBrainz ID for albums, an
	/// artist MusicBrainz ID (or name) for artists, or a playlist ID for playlists.
	public let entityId: String

	/// The 1-based rank within the period.
	public let rank: Int

	/// The ranking score: `(alpha * normalized plays) + (beta * normalized time) + (gamma * recency decay)`.
	public let score: Double

	/// The number of times this entity was played.
	public let playCount: Int

	/// The total wall-clock milliseconds this entity was played.
	public let totalDurationMs: Int64

	/// The total minutes this entity was played.
	public let minutes: Int

	/// When the user first played this entity, as a Unix timestamp in milliseconds, if known.
	public let firstPlayedAt: Int64?

	/// When the user last played this entity, as a Unix timestamp in milliseconds, if known.
	public let lastPlayedAt: Int64?

	/// Whether the user heard this for the first time in this period.
	public let isFirstEver: Bool?

	/// The entity's title, snapshotted at rollup time, if known — this survives the entity leaving the library.
	public let title: String?

	/// The entity's subtitle, snapshotted at rollup time, if known.
	public let subtitle: String?

	/// A cover art URL, snapshotted at rollup time, if known.
	public let cover: String?

	public init(entityType: RankedEntityKind, entityId: String, rank: Int, score: Double, playCount: Int, totalDurationMs: Int64, minutes: Int, firstPlayedAt: Int64?, lastPlayedAt: Int64?, isFirstEver: Bool?, title: String?, subtitle: String?, cover: String?) {
		self.entityType = entityType
		self.entityId = entityId
		self.rank = rank
		self.score = score
		self.playCount = playCount
		self.totalDurationMs = totalDurationMs
		self.minutes = minutes
		self.firstPlayedAt = firstPlayedAt
		self.lastPlayedAt = lastPlayedAt
		self.isFirstEver = isFirstEver
		self.title = title
		self.subtitle = subtitle
		self.cover = cover
	}
}
