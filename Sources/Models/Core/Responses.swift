// Made by Lumaa

import Foundation

/// The result of an authentication call (`Auth.login`/`Auth.register`): the authenticated user and their session token.
public struct AuthResponse: Codable, Sendable, Hashable {
	/// The authenticated user.
	public let user: NafynUser

	/// The user's session token. Assign this to ``NafynServer/authToken`` to authenticate subsequent calls.
	public let token: String

	public init(user: NafynUser, token: String) {
		self.user = user
		self.token = token
	}
}

/// The result of removing something that has no extra metadata (e.g. leaving a playlist, deleting a playlist).
public struct RemovedResponse: Codable, Sendable, Hashable {
	/// Whether the item was removed.
	public let removed: Bool

	public init(removed: Bool) {
		self.removed = removed
	}
}

/// The result of permanently erasing an account (`User.deleteAccount(password:)`, `Users.delete(id:)`).
public struct AccountErasedResponse: Codable, Sendable, Hashable {
	/// Whether the account was removed.
	public let removed: Bool

	/// Per-area count of what was erased. The spec leaves its shape open, so it's untyped.
	public let erased: JSONValue?

	public init(removed: Bool, erased: JSONValue? = nil) {
		self.removed = removed
		self.erased = erased
	}
}

/// The result of removing a library track, which may also delete the underlying file.
public struct RemovedWithFileResponse: Codable, Sendable, Hashable {
	/// Whether the library entry was removed.
	public let removed: Bool

	/// Whether the underlying file was deleted (no other user referenced it anymore).
	public let fileDeleted: Bool

	public init(removed: Bool, fileDeleted: Bool) {
		self.removed = removed
		self.fileDeleted = fileDeleted
	}
}

/// The result of `Library.album(id:)`: one album's metadata plus only the tracks the requesting user owns from it.
public struct LibraryAlbumResponse: Codable, Sendable, Hashable {
	/// An album's metadata, extended with cover-derived color info — only populated by
	/// `Library.album(id:)`, unlike ``AlbumRow`` on its own.
	public struct Album: Codable, Sendable, Hashable {
		/// The album's metadata.
		public let row: AlbumRow

		/// Dominant colors extracted from `row.coverArt`, most-dominant first.
		public let imageColors: [String]

		/// Black or white, whichever contrasts best (WCAG) against `imageColors[0]`.
		public let textColor: String

		public init(row: AlbumRow, imageColors: [String], textColor: String) {
			self.row = row
			self.imageColors = imageColors
			self.textColor = textColor
		}

		public init(from decoder: Decoder) throws {
			self.row = try AlbumRow(from: decoder)
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.imageColors = try container.decode([String].self, forKey: .imageColors)
			self.textColor = try container.decode(String.self, forKey: .textColor)
		}

		public func encode(to encoder: Encoder) throws {
			try row.encode(to: encoder)
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(imageColors, forKey: .imageColors)
			try container.encode(textColor, forKey: .textColor)
		}

		private enum CodingKeys: String, CodingKey {
			case imageColors, textColor
		}
	}

	/// The album's metadata.
	public let album: Album

	/// The tracks from this album the requesting user owns.
	public let tracks: [MediaRow]

	public init(album: Album, tracks: [MediaRow]) {
		self.album = album
		self.tracks = tracks
	}
}

/// The result of `Library.track(id:)`: one library track's metadata, extended with cover-derived
/// color info — only populated by this endpoint, unlike ``MediaRow`` on its own.
public struct LibraryTrackResponse: Codable, Sendable, Hashable {
	/// The track's metadata.
	public let row: MediaRow

	/// Dominant colors extracted from `row.coverArt`, most-dominant first.
	public let imageColors: [String]

	/// Black or white, whichever contrasts best (WCAG) against `imageColors[0]`.
	public let textColor: String

	public init(row: MediaRow, imageColors: [String], textColor: String) {
		self.row = row
		self.imageColors = imageColors
		self.textColor = textColor
	}

	public init(from decoder: Decoder) throws {
		self.row = try MediaRow(from: decoder)
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.imageColors = try container.decode([String].self, forKey: .imageColors)
		self.textColor = try container.decode(String.self, forKey: .textColor)
	}

	public func encode(to encoder: Encoder) throws {
		try row.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(imageColors, forKey: .imageColors)
		try container.encode(textColor, forKey: .textColor)
	}

	private enum CodingKeys: String, CodingKey {
		case imageColors, textColor
	}
}

/// The result of `Library.recordRecentlyPlayed(type:refId:)`.
public struct RecordedResponse: Codable, Sendable, Hashable {
	/// Whether the entry was recorded.
	public let recorded: Bool

	public init(recorded: Bool) {
		self.recorded = recorded
	}
}

/// The result of `Playlist.reorder(pid:order:)`.
public struct ReorderedResponse: Codable, Sendable, Hashable {
	/// Whether the playlist was reordered.
	public let reordered: Bool

	public init(reordered: Bool) {
		self.reordered = reordered
	}
}

/// Whether open registration is currently allowed, from `Settings.registrationOpen()`/`Settings.setRegistrationOpen(_:)`.
public struct RegistrationOpenResponse: Codable, Sendable, Hashable {
	/// Whether `/register` currently allows sign-up without a registration token.
	public let open: Bool

	public init(open: Bool) {
		self.open = open
	}
}

/// The result of `User.createApiToken(name:)`: a newly created API token, including its plaintext value.
///
/// The `token` field is only ever returned here, at creation time — it can't be retrieved again
/// afterward. Compare with ``ApiTokenSummary``, which omits it.
public struct CreateApiTokenResponse: Codable, Sendable, Hashable {
	/// The token's ID.
	public let id: String

	/// The ID of the user this token belongs to.
	public let userId: String

	/// A user-assigned label for this token, if one was set.
	public let name: String?

	/// The plaintext token value. Shown only this once.
	public let token: String

	/// When this token was created, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	/// When this token was last used, as a Unix timestamp in milliseconds, if it's been used.
	public let lastUsedAt: Int64?

	public init(id: String, userId: String, name: String?, token: String, createdAt: Int64, lastUsedAt: Int64?) {
		self.id = id
		self.userId = userId
		self.name = name
		self.token = token
		self.createdAt = createdAt
		self.lastUsedAt = lastUsedAt
	}
}

/// One year's side-by-side totals, from `Insights.compareYears(years:)`.
public struct YearComparisonEntry: Codable, Sendable, Hashable {
	/// The year.
	public let year: Int

	/// Total minutes listened this year.
	public let totalMinutes: Int

	/// Total plays this year.
	public let totalPlays: Int

	/// Distinct tracks played this year.
	public let uniqueTracks: Int

	/// Distinct albums played this year.
	public let uniqueAlbums: Int

	/// Distinct artists played this year.
	public let uniqueArtists: Int

	/// Minutes listened per month, 12 entries, January first.
	public let monthlyMinutes: [Int]

	public init(year: Int, totalMinutes: Int, totalPlays: Int, uniqueTracks: Int, uniqueAlbums: Int, uniqueArtists: Int, monthlyMinutes: [Int]) {
		self.year = year
		self.totalMinutes = totalMinutes
		self.totalPlays = totalPlays
		self.uniqueTracks = uniqueTracks
		self.uniqueAlbums = uniqueAlbums
		self.uniqueArtists = uniqueArtists
		self.monthlyMinutes = monthlyMinutes
	}
}

/// The result of `Insights.ingestEvents(events:token:)`.
public struct IngestPlayEventsResponse: Codable, Sendable, Hashable {
	/// The number of events newly written to the store.
	public let accepted: Int

	/// The number of entries dropped as malformed, duplicated within the batch, or referencing a track outside the user's library.
	public let rejected: Int

	/// `false` means the batch was accepted and discarded; the client should stop sending events.
	public let historyEnabled: Bool

	public init(accepted: Int, rejected: Int, historyEnabled: Bool) {
		self.accepted = accepted
		self.rejected = rejected
		self.historyEnabled = historyEnabled
	}
}

/// The result of `Insights.deleteHistory()`.
public struct DeletedResponse: Codable, Sendable, Hashable {
	/// Whether the data was deleted.
	public let deleted: Bool

	public init(deleted: Bool) {
		self.deleted = deleted
	}
}

/// The result of `Insights.requestReelVideo(year:)`.
public struct RequestReelVideoResponse: Codable, Sendable, Hashable {
	/// The reel's rendering status after the request.
	///
	/// Requesting a reel already queued or rendering is a no-op, so this simply reflects the current status.
	public let reelStatus: ReelStatus

	public init(reelStatus: ReelStatus) {
		self.reelStatus = reelStatus
	}
}

/// The `/api/_nafyn` health check response, used internally by ``NafynInstance/connect(appName:to:session:)``.
struct NafynPingResponse: Codable, Sendable {
	struct ServerInfo: Codable, Sendable {
		let id: UUID
		let date: Int64
	}

	let nafyn: Bool
	let response: ServerInfo
}
