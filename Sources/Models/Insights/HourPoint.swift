// Made by Lumaa

import Foundation

/// Listening activity for one hour of the day, in the user's local time, fixed when the data was rolled up.
public struct HourPoint: Codable, Sendable, Hashable {
	/// The hour of day, `0...23`.
	public let hour: Int

	/// The number of tracks played during this hour.
	public let plays: Int

	/// The number of minutes listened during this hour.
	public let minutes: Int

	public init(hour: Int, plays: Int, minutes: Int) {
		self.hour = hour
		self.plays = plays
		self.minutes = minutes
	}
}
