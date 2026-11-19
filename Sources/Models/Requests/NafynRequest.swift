// Made by Lumaa

import Foundation

/// A download request for a track or album.
public struct NafynRequest: Codable, Sendable, Hashable {
	/// The request's ID.
	public let id: String

	/// The requested item's MusicBrainz ID.
	public let musicbrainzId: String

	/// The requested item's resolved media info, if available.
	public let info: MediaInfo?

	/// Whether this request is for a whole album or a single track.
	public let type: RequestKind

	/// The request's current status.
	public let status: RequestStatus

	/// Who made this request.
	public let requestedBy: UserRef

	/// When this request was created.
	public let createdAt: Date

	/// When this request was last updated.
	public let updatedAt: Date

	public init(id: String, musicbrainzId: String, info: MediaInfo?, type: RequestKind, status: RequestStatus, requestedBy: UserRef, createdAt: Date, updatedAt: Date) {
		self.id = id
		self.musicbrainzId = musicbrainzId
		self.info = info
		self.type = type
		self.status = status
		self.requestedBy = requestedBy
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

/// One account that made a request, as ``Request/requesters`` lists it: the choices of the requests list's `user`
/// filter.
public struct RequestRequester: Codable, Sendable, Hashable, Identifiable {
	/// The account's id: what ``Request/all(limit:offset:succeeded:failed:waiting:processing:type:user:)`` takes as `user`.
	public let id: String

	/// The account's login username.
	public let username: String

	/// A display name, if the user set one.
	public let displayName: String?

	/// The user's avatar, if they have one set.
	public let avatar: String?

	/// The display name, or the username when there is none.
	public var name: String { (self.displayName?.isEmpty == false ? self.displayName : nil) ?? self.username }

	public init(id: String, username: String, displayName: String?, avatar: String?) {
		self.id = id
		self.username = username
		self.displayName = displayName
		self.avatar = avatar
	}
}
