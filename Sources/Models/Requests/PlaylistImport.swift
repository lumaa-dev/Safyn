// Made by Lumaa

import Foundation

/// One track of a playlist to import, as the other service describes it.
public struct ImportTrack: Codable, Sendable, Hashable {
	/// The track's ISRC, when the other service knows it.
	public let isrc: String?

	public let title: String

	/// The artist as the other service displays it (`"A & B"` is fine).
	public let artist: String

	public let album: String?

	/// Length in seconds: picks between recordings sharing an ISRC, and backs a title + artist match.
	public let duration: Int?

	public init(isrc: String?, title: String, artist: String, album: String? = nil, duration: Int? = nil) {
		self.isrc = isrc
		self.title = title
		self.artist = artist
		self.album = album
		self.duration = duration
	}
}

/// Whether a ``PlaylistImport`` is still being worked on.
public enum ImportStatus: String, Codable, Sendable, Hashable {
	case running
	case completed
	/// A status this client doesn't know yet.
	case unknown

	public init(from decoder: Decoder) throws {
		let raw = try decoder.singleValueContainer().decode(String.self)
		self = ImportStatus(rawValue: raw) ?? .unknown
	}
}

/// What became of one track of a ``PlaylistImport``.
public enum ImportItemStatus: String, Codable, Sendable, Hashable {
	/// Not looked at yet.
	case pending
	/// A download request was created (``ImportItem/requestId``).
	case requested
	/// Already in the user's library.
	case owned
	/// A request for it is already waiting or running.
	case alreadyRequested = "already-requested"
	/// No convincing MusicBrainz match.
	case notFound = "not-found"
	/// Not released yet.
	case unreleased
	/// Anything else (``ImportItem/message``), MusicBrainz still unreachable after retries included.
	case error
	/// A status this client doesn't know yet.
	case unknown

	public init(from decoder: Decoder) throws {
		let raw = try decoder.singleValueContainer().decode(String.self)
		self = ImportItemStatus(rawValue: raw) ?? .unknown
	}
}

/// How an ``ImportItem`` was matched to its MusicBrainz recording.
public enum ImportMatchVia: String, Codable, Sendable, Hashable {
	case isrc
	/// By searching its title + artist.
	case search
	/// A value this client doesn't know yet.
	case unknown

	public init(from decoder: Decoder) throws {
		let raw = try decoder.singleValueContainer().decode(String.self)
		self = ImportMatchVia(rawValue: raw) ?? .unknown
	}
}

/// How many tracks of a ``PlaylistImport`` are in each ``ImportItemStatus``.
public struct ImportCounts: Codable, Sendable, Hashable {
	public let pending: Int
	public let requested: Int
	public let owned: Int
	public let alreadyRequested: Int
	public let notFound: Int
	public let unreleased: Int
	public let error: Int

	enum CodingKeys: String, CodingKey {
		case pending, requested, owned, unreleased, error
		case alreadyRequested = "already-requested"
		case notFound = "not-found"
	}

	public init(pending: Int = 0, requested: Int = 0, owned: Int = 0, alreadyRequested: Int = 0, notFound: Int = 0, unreleased: Int = 0, error: Int = 0) {
		self.pending = pending
		self.requested = requested
		self.owned = owned
		self.alreadyRequested = alreadyRequested
		self.notFound = notFound
		self.unreleased = unreleased
		self.error = error
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.pending = try container.decodeIfPresent(Int.self, forKey: .pending) ?? 0
		self.requested = try container.decodeIfPresent(Int.self, forKey: .requested) ?? 0
		self.owned = try container.decodeIfPresent(Int.self, forKey: .owned) ?? 0
		self.alreadyRequested = try container.decodeIfPresent(Int.self, forKey: .alreadyRequested) ?? 0
		self.notFound = try container.decodeIfPresent(Int.self, forKey: .notFound) ?? 0
		self.unreleased = try container.decodeIfPresent(Int.self, forKey: .unreleased) ?? 0
		self.error = try container.decodeIfPresent(Int.self, forKey: .error) ?? 0
	}
}

/// One track of a ``PlaylistImport`` and its outcome.
public struct ImportItem: Codable, Sendable, Hashable, Identifiable {
	/// 0-based index in the submitted list.
	public let position: Int
	public let isrc: String?
	public let title: String
	public let artist: String
	public let album: String?
	/// Length in seconds, as submitted.
	public let duration: Int?
	public let status: ImportItemStatus
	/// The MusicBrainz recording it was matched to.
	public let musicbrainzId: String?
	/// The download request created for it, when ``status`` is ``ImportItemStatus/requested``.
	public let requestId: String?
	public let via: ImportMatchVia?
	public let message: String?

	public var id: Int { self.position }
}

/// A playlist import started with ``Import/create(tracks:source:name:)``.
public struct PlaylistImport: Codable, Sendable, Hashable, Identifiable {
	public let id: String
	public let source: String?
	public let name: String?
	public let status: ImportStatus
	public let total: Int
	/// Tracks no longer ``ImportItemStatus/pending``.
	public let processed: Int
	public let counts: ImportCounts
	/// Unix seconds.
	public let createdAt: Int
	/// Unix seconds.
	public let updatedAt: Int
	/// Every track's outcome; only from ``Import/get(id:)``.
	public let items: [ImportItem]?

	public var createdDate: Date { Date(timeIntervalSince1970: TimeInterval(self.createdAt)) }
	public var updatedDate: Date { Date(timeIntervalSince1970: TimeInterval(self.updatedAt)) }
}
