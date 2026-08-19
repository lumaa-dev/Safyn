// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/album/` path.
public enum Album: NafynEndpoint {

	/// Get full album/EP details (tracklist, artist, cover art) from a MusicBrainz release-group ID,
	/// with per-track library/request status for the requesting user.
	///
	/// Returns ``AlbumDetail``.
	/// - Parameter aid: MusicBrainz release-group ID.
	case get(aid: String)

	public var path: String {
		switch self {
			case .get(let aid):
				return "/api/v1/album/\(aid)"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .get:
				return [.get]
		}
	}
}
