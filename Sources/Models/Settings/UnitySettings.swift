// Made by Lumaa

import Foundation

/// The requesting user's Nafyn Unity preference, from `User.unitySettings`/`User.updateUnitySettings(enabled:)`.
///
/// - Note: Only the official web client honours this; the server doesn't check it when a
///   ``NafynUnitySocket`` connects. Clients should check it themselves before connecting.
public struct UnitySettings: Codable, Sendable, Hashable {
	/// Whether Nafyn Unity is enabled for this account. Defaults to `true` server-side.
	public let enabled: Bool

	public init(enabled: Bool) {
		self.enabled = enabled
	}
}
