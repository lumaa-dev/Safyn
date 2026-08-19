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
