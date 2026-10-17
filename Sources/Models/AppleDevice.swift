// Made by Lumaa

import Foundation

/// What an APNs token registered through `User.registerDevice` is used for.
public enum AppleDeviceKind: String, Codable, Sendable, Hashable {
	/// The regular device token, for alert pushes.
	case alert

	/// Push-to-start token for request Live Activities.
	case laStartRequest = "la-start:request"

	/// Push-to-start token for release-countdown Live Activities.
	case laStartRelease = "la-start:release"

	/// Push-to-start token for iOS 27 Now Playing remote sessions.
	case nowPlayingStart = "nowplaying-start"
}

/// The APNs gateway a token belongs to.
public enum APNsEnvironment: String, Codable, Sendable, Hashable {
	/// Xcode builds.
	case sandbox

	/// TestFlight / App Store builds.
	case production
}

/// One of the requesting user's registered Apple devices (APNs tokens), from `User.devices`.
///
/// The token itself is never returned.
public struct AppleDevice: Codable, Sendable, Hashable, Identifiable {
	/// The device registration's ID.
	public let id: String

	/// What this token is used for.
	public let kind: AppleDeviceKind

	/// The APNs gateway the token belongs to.
	public let environment: APNsEnvironment

	/// A user-assigned device name, if one was given.
	public let deviceName: String?

	/// The alert events this device wants, or `nil` for every event.
	public let events: [String]?

	/// Whether this was registered by the login making the request.
	public let currentSession: Bool

	/// When the device was registered, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	/// When the device last registered, as a Unix timestamp in milliseconds.
	public let lastSeenAt: Int64

	public init(id: String, kind: AppleDeviceKind, environment: APNsEnvironment, deviceName: String?, events: [String]?, currentSession: Bool, createdAt: Int64, lastSeenAt: Int64) {
		self.id = id
		self.kind = kind
		self.environment = environment
		self.deviceName = deviceName
		self.events = events
		self.currentSession = currentSession
		self.createdAt = createdAt
		self.lastSeenAt = lastSeenAt
	}

	/// `createdAt` converted to a `Date`.
	public var createdAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
	}

	/// `lastSeenAt` converted to a `Date`.
	public var lastSeenAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(lastSeenAt) / 1000)
	}
}

/// What a Live Activity or Now Playing push token registered through `User.registerActivityToken` belongs to.
public enum ActivityKind: String, Codable, Sendable, Hashable {
	/// A download request's Live Activity; `refId` is the request ID.
	case request

	/// A release-countdown Live Activity; `refId` is the release subscription ID.
	case release

	/// A Now Playing remote session; `refId` is the session's `attributes.id`.
	case nowPlaying = "nowplaying"
}
