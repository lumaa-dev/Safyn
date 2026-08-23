// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/artist/` path.
public enum Artist: NafynEndpoint {

	/// Get artist details: name, Last.fm bio/image (if `LASTFM_API_KEY` is configured), and their
	/// discography from MusicBrainz with per-album library status for the requesting user.
	///
	/// Returns ``ArtistDetail``.
	/// - Parameter aid: MusicBrainz artist ID.
	case get(aid: String)

	public var path: String {
		switch self {
			case .get(let aid):
				return "/api/v1/artist/\(aid)"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .get:
				return [.get]
		}
	}
}
