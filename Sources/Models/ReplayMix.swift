// Made by Lumaa

import Foundation

/// A Replay Mix: the requesting user's top 100 tracks for a year, or the All-Time mix.
///
/// Returned by `Insights.replayMix()` (the live, current-year mix) and `Insights.archivedReplayMix(year:)`
/// (a past year, or `"all-time"`, frozen as it stood at the end of that year). Read-only by design —
/// no playlist endpoint can rename, reorder, add to, or delete a Replay Mix.
public struct ReplayMix: Codable, Sendable, Hashable {
	/// One archived mix' summary, as listed in ``archive``.
	public struct ArchiveSummary: Codable, Sendable, Hashable {
		/// The mix's year, if known.
		public let year: Int?

		/// The mix's virtual identifier, if known.
		public let id: String?

		/// The number of tracks in the mix, if known.
		public let trackCount: Int?

		/// When the mix was last refreshed, as a Unix timestamp in milliseconds, if known.
		public let refreshedAt: Int64?

		public init(year: Int?, id: String?, trackCount: Int?, refreshedAt: Int64?) {
			self.year = year
			self.id = id
			self.trackCount = trackCount
			self.refreshedAt = refreshedAt
		}
	}

	/// A virtual identifier for this mix, e.g. `"replay-2026"`.
	///
	/// This is also how the mix appears over the Subsonic API, where it is likewise read-only.
	public let id: String

	/// The mix's year, or `0` for the All-Time mix.
	public let year: Int

	/// Whether this is the All-Time mix rather than a specific year.
	public let isAllTime: Bool

	/// When this mix was last refreshed, as a Unix timestamp in milliseconds.
	///
	/// The live mix is rebuilt every Monday; an archived mix is never rebuilt.
	public let refreshedAt: Int64?

	/// The mix's tracks, in ranked order.
	public let entries: [ReplayEntry]

	/// Every stored mix, newest first, including All-Time.
	public let archive: [ArchiveSummary]?

	public init(id: String, year: Int, isAllTime: Bool, refreshedAt: Int64?, entries: [ReplayEntry], archive: [ArchiveSummary]?) {
		self.id = id
		self.year = year
		self.isAllTime = isAllTime
		self.refreshedAt = refreshedAt
		self.entries = entries
		self.archive = archive
	}
}
