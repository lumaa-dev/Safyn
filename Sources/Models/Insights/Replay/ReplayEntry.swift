// Made by Lumaa

import Foundation

/// One track's position in a ``ReplayMix``.
public struct ReplayEntry: Codable, Sendable, Hashable {
	/// The 0-based position in the mix.
	public let position: Int

	/// The media ID.
	public let trackId: String

	/// The ranking score behind this entry's position.
	public let score: Double

	/// The number of times this track was played.
	public let playCount: Int

	/// The total wall-clock milliseconds this track was played.
	public let totalDurationMs: Int64

	/// The total minutes this track was played.
	public let minutes: Int

	/// The track's title, snapshotted at mix build time, if known.
	public let title: String?

	/// The track's subtitle (typically artist name), snapshotted at mix build time, if known.
	public let subtitle: String?

	/// A cover art URL, snapshotted at mix build time, if known.
	public let cover: String?

	/// Whether this track is still playable.
	///
	/// `false` once the track has since left the user's library — it stays listed but can't be played.
	public let available: Bool

	/// The track's full media row, if it's still in the user's library.
	public let media: MediaRow?

	public init(position: Int, trackId: String, score: Double, playCount: Int, totalDurationMs: Int64, minutes: Int, title: String?, subtitle: String?, cover: String?, available: Bool, media: MediaRow?) {
		self.position = position
		self.trackId = trackId
		self.score = score
		self.playCount = playCount
		self.totalDurationMs = totalDurationMs
		self.minutes = minutes
		self.title = title
		self.subtitle = subtitle
		self.cover = cover
		self.available = available
		self.media = media
	}
}
