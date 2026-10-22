// Made by Lumaa

import Foundation

/// A track lookup result, returned by `Track.get(tid:)` and `Track.get(isrc:)`.
public struct TrackDetail: Codable, Sendable, Hashable {
	/// The track's resolved media info.
	public let info: MediaInfo

	/// The MusicBrainz release-group ID of the album this track belongs to, if known.
	public let albumMbid: String?

	/// `true` when no recording had the requested ISRC and the track was found by title + artist instead.
	/// Only present on `Track.getByIsrc` responses.
	public let searchFallback: Bool?

	/// How much of the release date MusicBrainz actually knows. Only present on `Track.get` responses.
	public let releaseDatePrecision: ReleaseDatePrecision?

	/// `false` while the release date hasn't started anywhere yet; unreleased tracks can't be requested.
	/// Only present on `Track.get` responses.
	public let released: Bool?

	/// Whether the requesting user follows this upcoming track. Only present on `Track.get` responses.
	public let subscribed: Bool?

	/// Whether the requesting user has a request for this track that is waiting or being processed.
	/// Only present on `Track.get` responses. Also check ``MediaInfo/inLibrary`` on ``info`` before requesting.
	public let requested: Bool?

	public init(info: MediaInfo, albumMbid: String?, searchFallback: Bool? = nil, releaseDatePrecision: ReleaseDatePrecision? = nil, released: Bool? = nil, subscribed: Bool? = nil, requested: Bool? = nil) {
		self.info = info
		self.albumMbid = albumMbid
		self.searchFallback = searchFallback
		self.releaseDatePrecision = releaseDatePrecision
		self.released = released
		self.subscribed = subscribed
		self.requested = requested
	}

	public init(from decoder: Decoder) throws {
		self.info = try MediaInfo(from: decoder)
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.albumMbid = try container.decodeIfPresent(String.self, forKey: .albumMbid)
		self.searchFallback = try container.decodeIfPresent(Bool.self, forKey: .searchFallback)
		self.releaseDatePrecision = try container.decodeIfPresent(ReleaseDatePrecision.self, forKey: .releaseDatePrecision)
		self.released = try container.decodeIfPresent(Bool.self, forKey: .released)
		self.subscribed = try container.decodeIfPresent(Bool.self, forKey: .subscribed)
		self.requested = try container.decodeIfPresent(Bool.self, forKey: .requested)
	}

	public func encode(to encoder: Encoder) throws {
		try info.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(albumMbid, forKey: .albumMbid)
		try container.encodeIfPresent(searchFallback, forKey: .searchFallback)
		try container.encodeIfPresent(releaseDatePrecision, forKey: .releaseDatePrecision)
		try container.encodeIfPresent(released, forKey: .released)
		try container.encodeIfPresent(subscribed, forKey: .subscribed)
		try container.encodeIfPresent(requested, forKey: .requested)
	}

	private enum CodingKeys: String, CodingKey {
		case albumMbid, searchFallback, releaseDatePrecision, released, subscribed, requested
	}
}
