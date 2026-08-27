// Made by Lumaa

import Foundation

/// Whether a period has enough listening data to show a ranking, used across the `Insights` summary endpoints.
public struct EnoughDataGate: Codable, Sendable, Hashable {
	/// `false` means the client should show the "keep listening" state instead of any ranking.
	public let enough: Bool

	/// The number of distinct tracks played so far.
	public let uniqueTracks: Int

	/// The number of minutes listened so far.
	public let minutes: Int

	/// The number of distinct tracks required for ``enough`` to become `true`.
	public let needUniqueTracks: Int

	/// The number of minutes required for ``enough`` to become `true`.
	public let needMinutes: Int

	public init(enough: Bool, uniqueTracks: Int, minutes: Int, needUniqueTracks: Int, needMinutes: Int) {
		self.enough = enough
		self.uniqueTracks = uniqueTracks
		self.minutes = minutes
		self.needUniqueTracks = needUniqueTracks
		self.needMinutes = needMinutes
	}
}
