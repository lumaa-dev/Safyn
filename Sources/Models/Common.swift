// Made by Lumaa

import Foundation

/// Either a fully-resolved artist, or a bare artist name.
///
/// The Nafyn API returns whichever it has available at lookup time: a full ``ArtistInfo`` when the
/// artist is known to MusicBrainz, or a plain string when it isn't. Decoding always tries the object
/// shape first and falls back to a string, which is safe because decoding a JSON object as `String`
/// never accidentally succeeds.
public enum ArtistRef: Codable, Sendable, Hashable {
	case info(ArtistInfo)
	case name(String)

	/// The artist's display name, regardless of which case this is.
	public var name: String {
		switch self {
			case .info(let info):
				return info.name
			case .name(let name):
				return name
		}
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let info = try? container.decode(ArtistInfo.self) {
			self = .info(info)
		} else {
			self = .name(try container.decode(String.self))
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
			case .info(let info):
				try container.encode(info)
			case .name(let name):
				try container.encode(name)
		}
	}
}

/// Either a fully-resolved user, or a bare user ID.
///
/// Mirrors ``ArtistRef``'s decode strategy: object shape first, string fallback.
public enum UserRef: Codable, Sendable, Hashable {
	case user(NafynUser)
	case id(String)

	/// The referenced user's ID, regardless of which case this is.
	public var id: String {
		switch self {
			case .user(let user):
				return user.id
			case .id(let id):
				return id
		}
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let user = try? container.decode(NafynUser.self) {
			self = .user(user)
		} else {
			self = .id(try container.decode(String.self))
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
			case .user(let user):
				try container.encode(user)
			case .id(let id):
				try container.encode(id)
		}
	}
}

/// A bitfield of permissions granted to a ``NafynUser``, matching the Nafyn server's `Permission` enum.
///
/// `admin` implicitly grants every other permission — use ``has(_:)``/``hasAll(_:)`` rather than
/// ``contains(_:)`` when checking whether a user is allowed to do something, since plain `contains`
/// only does a structural bitwise check and won't account for that override.
public struct Permissions: OptionSet, Codable, Sendable, Hashable {
	public let rawValue: Int

	public init(rawValue: Int) {
		self.rawValue = rawValue
	}

	/// No permissions.
	public static let none = Permissions([])

	/// Request albums for download.
	public static let requestAlbums = Permissions(rawValue: 1 << 0)

	/// Request individual tracks for download.
	public static let requestTracks = Permissions(rawValue: 1 << 1)

	/// Manage download requests made by any user (accept/reject/reprioritize).
	public static let manageRequests = Permissions(rawValue: 1 << 2)

	/// Album requests made by this user are automatically accepted.
	public static let autoacceptAlbums = Permissions(rawValue: 1 << 3)

	/// Track requests made by this user are automatically accepted.
	public static let autoacceptTracks = Permissions(rawValue: 1 << 4)

	/// Manage user accounts (create/edit/delete users, manage registration tokens).
	public static let manageAccounts = Permissions(rawValue: 1 << 5)

	/// Manage the shared music library (delete others' tracks, view all library entries).
	public static let manageMusic = Permissions(rawValue: 1 << 6)

	/// Manage server notifications.
	public static let manageNotifications = Permissions(rawValue: 1 << 7)

	/// Full administrative access; implicitly grants every other permission.
	public static let admin = Permissions(rawValue: 1 << 8)

	/// Whether this permission set includes `permission`, treating ``admin`` as granting everything.
	public func has(_ permission: Permissions) -> Bool {
		if contains(.admin) {
			return true
		}
		return !intersection(permission).isEmpty
	}

	/// Whether this permission set includes every permission in `permissions`, treating ``admin`` as granting everything.
	public func hasAll(_ permissions: [Permissions]) -> Bool {
		if contains(.admin) {
			return true
		}
		return permissions.allSatisfy { !intersection($0).isEmpty }
	}

	/// Whether a user with `actorPermissions` may edit the account (profile fields and permission bits) of a user with `targetPermissions`.
	///
	/// `admin` can edit anyone. `manageAccounts` can edit themselves, or anyone who doesn't have
	/// `manageAccounts`/`admin` — i.e. non-admins with `manageAccounts` can't touch other admins or
	/// account managers, only regular users (and themselves).
	public static func canManage(actorId: String, actorPermissions: Permissions, targetId: String, targetPermissions: Permissions) -> Bool {
		if actorPermissions.contains(.admin) {
			return true
		}
		guard actorPermissions.contains(.manageAccounts) else {
			return false
		}
		if actorId == targetId {
			return true
		}
		return targetPermissions.isDisjoint(with: [.manageAccounts, .admin])
	}

	/// Decodes either a plain integer bitfield, or an array of individual permission flag values to OR together.
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let intValue = try? container.decode(Int.self) {
			self.init(rawValue: intValue)
		} else if let flagValues = try? container.decode([Int].self) {
			self.init(rawValue: flagValues.reduce(0) { $0 | $1 })
		} else {
			self.init(rawValue: 0)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}
}

/// The kind of a music release, as used by ``AlbumDetail``, ``AlbumRow``, and ``MediaRow``.
public enum AlbumKind: String, Codable, Sendable, Hashable {
	case album
	case ep
}

/// The kind of media returned by ``MediaInfo``, which (unlike ``AlbumKind``) can also refer to a single track.
public enum MediaKind: String, Codable, Sendable, Hashable {
	case album
	case ep
	case track
}

/// The kind of media a ``RecentlyPlayedEntry`` refers to, or that `Library.recordRecentlyPlayed` records.
public enum RecentEntryKind: String, Codable, Sendable, Hashable {
	case track
	case album
	case playlist
}

/// The kind of media a ``NafynRequest`` is for, or that `Request.create` creates.
public enum RequestKind: String, Codable, Sendable, Hashable {
	case album
	case track
}

/// The lifecycle status of a ``NafynRequest``.
public enum RequestStatus: String, Codable, Sendable, Hashable {
	case waiting
	case searching
	case downloading
	case processing
	case completed
	case failed
}

/// Whether a ``PlaylistRow`` is visible to anonymous visitors.
public enum PlaylistPrivacy: String, Codable, Sendable, Hashable {
	case `public`
	case `private`
}

/// How a ``PlaylistRow``'s entries are ordered.
public enum PlaylistSortMode: String, Codable, Sendable, Hashable {
	case manual
	case title
	case artist
	case addedBy
	case duration
}

/// Restricts `Search.search` results to one media type.
public enum SearchFilter: String, Codable, Sendable, Hashable {
	case album
	case track
	case artist
	case all
}

/// The service that provided a set of synced lyrics.
public enum LyricsProvider: String, Codable, Sendable, Hashable {
	case appleMusic
	case cider
	case lrclib
	case cache
}

/// Where a ``PlayEventInput`` play started from.
public enum PlayEventSource: String, Codable, Sendable, Hashable {
	case library
	case playlist
	case album
	case track
}

/// The status of a ``HighlightReel``'s optional server-rendered MP4.
public enum ReelStatus: String, Codable, Sendable, Hashable {
	case none
	case queued
	case rendering
	case ready
	case failed
}

/// The kind of entity a ``RankedEntity`` ranks, or that `Insights.top(type:period:week:month:year:)` ranks.
public enum RankedEntityKind: String, Codable, Sendable, Hashable {
	case track
	case album
	case artist
	case playlist
}

/// A page of items from a paginated list endpoint, alongside the pagination cursor state.
///
/// Used by endpoints whose OpenAPI schema documents this exact envelope shape (e.g. `Library.all`).
/// Some other "paginated" list endpoints (e.g. `Library.albums`, `Library.tracks`, `Playlist.list`)
/// leave their response schema untyped in the spec — see the "Known spec ambiguities" section of
/// this package's documentation before assuming they use this same envelope.
public struct PaginatedResponse<Item: Codable & Sendable & Hashable>: Codable, Sendable, Hashable {
	/// This page's items.
	public let items: [Item]

	/// The current page number.
	public let page: Int

	/// The maximum number of items per page.
	public let limit: Int

	/// The total number of items across every page.
	public let total: Int

	/// Whether there are more pages beyond this one.
	public let hasMore: Bool

	public init(items: [Item], page: Int, limit: Int, total: Int, hasMore: Bool) {
		self.items = items
		self.page = page
		self.limit = limit
		self.total = total
		self.hasMore = hasMore
	}
}

/// A tri-state value for `PATCH` request fields that distinguish "leave unchanged", "clear to null", and "set to a new value".
///
/// Plain `Optional` can't express this over the wire: `JSONEncoder` omits `nil` properties entirely,
/// so there's no way to tell "don't change this" (omit the key) apart from "clear this" (send `null`)
/// with a bare `String?`. Types with `Patchable` fields (e.g. `Playlist.UpdateRequest`) must implement
/// a custom `encode(to:)` that switches on each case: `.unset` skips the key, `.clear` calls
/// `encodeNil(forKey:)`, and `.value` encodes normally.
public enum Patchable<T: Encodable & Sendable>: Sendable {
	/// Don't send this field; leave the server-side value unchanged.
	case unset

	/// Send `null`; clear the server-side value.
	case clear

	/// Send this value.
	case value(T)
}
