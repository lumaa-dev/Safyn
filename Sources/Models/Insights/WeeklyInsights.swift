// Made by Lumaa

import Foundation

/// A weekly listening summary for the requesting user, with the previous week alongside it for comparison.
///
/// Returned by `Insights.weekly(week:)`. Weeks are ISO-8601 (Monday-based) in the user's own time zone.
public struct WeeklyInsights: Codable, Sendable, Hashable {
	/// The summarized week, as an ISO week, e.g. `2026-W35`.
	public let week: String

	/// The previous week, as an ISO week.
	public let previousWeek: String

	/// This week's totals.
	public let totals: PeriodTotals

	/// The previous week's totals, for comparison.
	public let previousTotals: PeriodTotals

	/// Daily listening activity across the week.
	public let series: [DayPoint]

	/// Daily listening activity across the previous week.
	public let previousSeries: [DayPoint]

	/// Top tracks/albums/artists/playlists for the week.
	public let top: TopRankings

	/// Whether there's enough data this week to show a ranking.
	public let gate: EnoughDataGate

	public init(week: String, previousWeek: String, totals: PeriodTotals, previousTotals: PeriodTotals, series: [DayPoint], previousSeries: [DayPoint], top: TopRankings, gate: EnoughDataGate) {
		self.week = week
		self.previousWeek = previousWeek
		self.totals = totals
		self.previousTotals = previousTotals
		self.series = series
		self.previousSeries = previousSeries
		self.top = top
		self.gate = gate
	}
}
