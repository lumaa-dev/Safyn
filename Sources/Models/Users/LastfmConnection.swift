// Made by Lumaa

import Foundation

/// The user's Last.fm connection, from ``User/lastfm``. Scrobbling happens on the server, from the play events every
/// client reports.
public struct LastfmConnection: Codable, Sendable, Hashable {
	/// The instance can scrobble (it has a Last.fm API key and secret). When `false`, connecting is refused.
	public let available: Bool

	/// The connected Last.fm account, `nil` while none is.
	public let username: String?

	/// Plays are scrobbled (`false` when not connected or paused).
	public let scrobbling: Bool

	/// An account is connected.
	public var isConnected: Bool { self.username != nil }

	public init(available: Bool, username: String?, scrobbling: Bool) {
		self.available = available
		self.username = username
		self.scrobbling = scrobbling
	}
}

/// Where the Last.fm sign-in returns to (``User/connectLastfm(client:)``).
public enum LastfmClient: String, Codable, Sendable, Hashable {
	/// `/settings?lastfm=connected|error` on the web app.
	case web
	/// `nafyn://lastfm?status=connected|error`, for `ASWebAuthenticationSession`.
	case app
}

/// The last.fm page to open to connect an account, from ``User/connectLastfm(client:)``.
public struct LastfmConnectResponse: Codable, Sendable, Hashable {
	public let url: URL

	public init(url: URL) {
		self.url = url
	}
}
