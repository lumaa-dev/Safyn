// Made by Lumaa

import Foundation

/// Listening activity for one calendar day, e.g. within a `MonthlyInsights`/`WeeklyInsights` series.
public struct DayPoint: Codable, Sendable, Hashable {
	/// The day, as an ISO-8601 date (`YYYY-MM-DD`).
	public let date: String

	/// The number of minutes listened on this day.
	public let minutes: Int

	/// The number of tracks played on this day.
	public let plays: Int

	public init(date: String, minutes: Int, plays: Int) {
		self.date = date
		self.minutes = minutes
		self.plays = plays
	}
}
