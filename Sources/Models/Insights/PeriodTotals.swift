// Made by Lumaa

import Foundation

/// Aggregate listening totals over a period (month, week, or year), used across the `Insights` summary endpoints.
public struct PeriodTotals: Codable, Sendable, Hashable {
	/// Total wall-clock minutes actually played.
	public let totalMinutes: Int

	/// Total number of plays.
	public let totalPlays: Int

	/// Number of distinct tracks played.
	public let uniqueTracks: Int

	/// Number of distinct albums played.
	public let uniqueAlbums: Int

	/// Number of distinct artists played.
	public let uniqueArtists: Int

	/// Number of distinct playlists played from.
	public let uniquePlaylists: Int

	/// The longest run of consecutive days with any listening, if computed for this period.
	public let longestStreakDays: Int?

	public init(totalMinutes: Int, totalPlays: Int, uniqueTracks: Int, uniqueAlbums: Int, uniqueArtists: Int, uniquePlaylists: Int, longestStreakDays: Int?) {
		self.totalMinutes = totalMinutes
		self.totalPlays = totalPlays
		self.uniqueTracks = uniqueTracks
		self.uniqueAlbums = uniqueAlbums
		self.uniqueArtists = uniqueArtists
		self.uniquePlaylists = uniquePlaylists
		self.longestStreakDays = longestStreakDays
	}
}
