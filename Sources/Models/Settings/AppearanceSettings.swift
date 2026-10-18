// Made by Lumaa

import Foundation

/// The requesting user's display preferences (file size / duration visibility in track lists), from
/// `User.appearanceSettings`/`User.updateAppearanceSettings(showFileSize:showDuration:)`. Always
/// scoped to the caller.
public struct AppearanceSettings: Codable, Sendable, Hashable {
	/// Whether track lists should show file size. Turning this on requires `manageMusic`/`admin` —
	/// attempting to without it is silently ignored, not rejected.
	public let showFileSize: Bool

	/// Whether track lists should show duration.
	public let showDuration: Bool

	public init(showFileSize: Bool, showDuration: Bool) {
		self.showFileSize = showFileSize
		self.showDuration = showDuration
	}
}
