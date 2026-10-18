// Made by Lumaa

import Foundation

/// A yearly listening summary for the requesting user.
///
/// Returned by `Insights.yearly(year:)`. Live from the aggregates all year; once the year-end snapshot
/// has been taken (start of December) the frozen copy is returned instead, so a shared year-end package
/// never rewrites itself later.
public struct YearlyInsights: Codable, Sendable, Hashable {
	/// The summarized year.
	public let year: Int

	/// `true` when this is the frozen year-end copy rather than a live computation.
	public let snapshot: Bool

	/// When the year-end snapshot was taken, as a Unix timestamp in milliseconds, if ``snapshot`` is `true`.
	public let snapshotCreatedAt: Int64?

	/// The status of this year's optional server-rendered highlight-reel MP4, if any has been requested.
	public let reelStatus: ReelStatus?

	/// This year's totals.
	public let totals: PeriodTotals

	/// Minutes listened per month, 12 entries, January first.
	public let monthlyMinutes: [Int]

	/// Listening activity by hour of day across the year.
	public let hourHistogram: [HourPoint]

	/// Top tracks/albums/artists/playlists for the year.
	public let top: TopRankings

	/// Every year the user has any data for, newest first.
	public let availableYears: [Int]

	/// Whether there's enough data this year to show a ranking.
	public let gate: EnoughDataGate

	public init(year: Int, snapshot: Bool, snapshotCreatedAt: Int64?, reelStatus: ReelStatus?, totals: PeriodTotals, monthlyMinutes: [Int], hourHistogram: [HourPoint], top: TopRankings, availableYears: [Int], gate: EnoughDataGate) {
		self.year = year
		self.snapshot = snapshot
		self.snapshotCreatedAt = snapshotCreatedAt
		self.reelStatus = reelStatus
		self.totals = totals
		self.monthlyMinutes = monthlyMinutes
		self.hourHistogram = hourHistogram
		self.top = top
		self.availableYears = availableYears
		self.gate = gate
	}
}
