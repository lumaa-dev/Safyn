// Made by Lumaa

import Foundation

/// The requesting user's playback preferences (crossfade), from
/// `User.playbackSettings`/`User.updatePlaybackSettings(crossfadeEnabled:crossfadeMs:)`. Always scoped
/// to the caller.
public struct PlaybackSettings: Codable, Sendable, Hashable {
	/// Whether crossfade is enabled. Defaults to `true` server-side.
	public let crossfadeEnabled: Bool

	/// Crossfade length in milliseconds, clamped to 500-12000 server-side. Defaults to `3000`.
	public let crossfadeMs: Int

	public init(crossfadeEnabled: Bool, crossfadeMs: Int) {
		self.crossfadeEnabled = crossfadeEnabled
		self.crossfadeMs = crossfadeMs
	}
}
