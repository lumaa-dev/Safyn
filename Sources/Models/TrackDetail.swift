// Made by Lumaa

import Foundation

/// A track lookup result, returned by `Track.get(tid:)` and `Track.get(isrc:)`.
public struct TrackDetail: Codable, Sendable, Hashable {
	/// The track's resolved media info.
	public let info: MediaInfo

	/// The MusicBrainz release-group ID of the album this track belongs to, if known.
	public let albumMbid: String?

	public init(info: MediaInfo, albumMbid: String?) {
		self.info = info
		self.albumMbid = albumMbid
	}

	public init(from decoder: Decoder) throws {
		self.info = try MediaInfo(from: decoder)
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.albumMbid = try container.decodeIfPresent(String.self, forKey: .albumMbid)
	}

	public func encode(to encoder: Encoder) throws {
		try info.encode(to: encoder)
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(albumMbid, forKey: .albumMbid)
	}

	private enum CodingKeys: String, CodingKey {
		case albumMbid
	}
}
