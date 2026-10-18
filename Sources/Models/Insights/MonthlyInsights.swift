// Made by Lumaa

import Foundation

/// A monthly listening summary for the requesting user, with the previous month's totals for comparison.
///
/// Returned by `Insights.monthly(month:)`. Months are the user's local calendar months.
public struct MonthlyInsights: Codable, Sendable, Hashable {
	/// The summarized month, as `YYYY-MM`.
	public let month: String

	/// The previous month, as `YYYY-MM`.
	public let previousMonth: String

	/// This month's totals.
	public let totals: PeriodTotals

	/// The previous month's totals, for comparison.
	public let previousTotals: PeriodTotals

	/// Daily listening activity across the month.
	public let series: [DayPoint]

	/// Listening activity by hour of day across the month.
	public let hourHistogram: [HourPoint]

	/// Top tracks/albums/artists/playlists for the month.
	public let top: TopRankings

	/// Whether there's enough data this month to show a ranking.
	public let gate: EnoughDataGate

	public init(month: String, previousMonth: String, totals: PeriodTotals, previousTotals: PeriodTotals, series: [DayPoint], hourHistogram: [HourPoint], top: TopRankings, gate: EnoughDataGate) {
		self.month = month
		self.previousMonth = previousMonth
		self.totals = totals
		self.previousTotals = previousTotals
		self.series = series
		self.hourHistogram = hourHistogram
		self.top = top
		self.gate = gate
	}
}
