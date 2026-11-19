// Made by Lumaa

import Foundation

/// The user's ListenBrainz connection, from ``User/listenBrainz``. Scrobbling happens on the server, from the play
/// events every client reports.
public struct ListenBrainzConnection: Codable, Sendable, Hashable {
	/// The connected ListenBrainz account, `nil` while none is.
	public let username: String?

	/// Plays are scrobbled (`false` when not connected or paused).
	public let scrobbling: Bool

	/// An account is connected.
	public var isConnected: Bool { self.username != nil }

	public init(username: String?, scrobbling: Bool) {
		self.username = username
		self.scrobbling = scrobbling
	}
}
