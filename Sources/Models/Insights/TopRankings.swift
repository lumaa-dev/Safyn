// Made by Lumaa

import Foundation

/// Ranked top entities by type for a period, embedded in `MonthlyInsights`, `WeeklyInsights`, and `YearlyInsights`.
public struct TopRankings: Codable, Sendable, Hashable {
	/// Top tracks for the period, if any.
	public let track: [RankedEntity]?

	/// Top albums for the period, if any.
	public let album: [RankedEntity]?

	/// Top artists for the period, if any.
	public let artist: [RankedEntity]?

	/// Top playlists for the period, if any.
	public let playlist: [RankedEntity]?

	public init(track: [RankedEntity]?, album: [RankedEntity]?, artist: [RankedEntity]?, playlist: [RankedEntity]?) {
		self.track = track
		self.album = album
		self.artist = artist
		self.playlist = playlist
	}
}
