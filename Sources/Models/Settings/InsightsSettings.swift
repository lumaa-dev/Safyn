// Made by Lumaa

import Foundation

/// The requesting user's listening-history preferences, from `Insights.settings()`/`Insights.updateSettings(historyEnabled:tzOffsetMinutes:)`.
///
/// Always scoped to the caller — there is no way to read or change another user's setting.
public struct InsightsSettings: Codable, Sendable, Hashable {
	/// Whether listening history is being recorded. Opt-in; `false` by default and for users who have never touched the setting.
	public let historyEnabled: Bool

	/// When this setting was last switched on, as a Unix timestamp in milliseconds, if ever.
	public let enabledAt: Int64?

	/// When this setting was last switched off, as a Unix timestamp in milliseconds, if ever.
	public let disabledAt: Int64?

	/// Minutes to add to UTC to reach the user's local time; decides where their day, week, and year boundaries fall.
	public let tzOffsetMinutes: Int

	/// Plays are scrobbled to Last.fm, so a client keeps reporting them (`Insights.ingestEvents`) even with the history
	/// off. Only sent by `Insights.settings()`; `nil` from older servers and from the update.
	public let scrobbling: Bool?

	public init(historyEnabled: Bool, enabledAt: Int64?, disabledAt: Int64?, tzOffsetMinutes: Int, scrobbling: Bool? = nil) {
		self.historyEnabled = historyEnabled
		self.enabledAt = enabledAt
		self.disabledAt = disabledAt
		self.tzOffsetMinutes = tzOffsetMinutes
		self.scrobbling = scrobbling
	}
}
