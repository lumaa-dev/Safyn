// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/album/` path.
public enum Album: NafynEndpoint {

	/// Get full album/EP details (tracklist, artist, cover art) from a MusicBrainz release-group ID,
	/// with per-track library/request status for the requesting user.
	///
	/// Returns ``AlbumDetail``. Its ``AlbumDetail/releases`` lists the other releases of the release-group
	/// (Deluxe, other countries, reissues); pass one as `release` to show that release instead.
	/// - Parameters:
	///   - aid: MusicBrainz release-group ID.
	///   - release: MusicBrainz release ID, one of ``AlbumDetail/releases``. One that is not a release of this
	///     album is ignored server-side.
	case get(aid: String, release: String? = nil)

	public var path: String {
		switch self {
			case .get(let aid, _):
				return "/api/v1/album/\(aid)"
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .get(_, let release):
				guard let release else { return [] }
				return [URLQueryItem(name: "release", value: release)]
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .get:
				return [.get]
		}
	}
}
