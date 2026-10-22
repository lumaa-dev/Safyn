// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/track` path.
public enum Track: NafynEndpoint {

	/// Get track details from a MusicBrainz recording ID.
	///
	/// Returns ``TrackDetail``.
	/// - Parameter tid: MusicBrainz recording ID.
	case get(tid: String)

	/// Look up a track by its ISRC (International Standard Recording Code).
	///
	/// When no recording has this ISRC and both `title` and `artist` are given, the track is searched by
	/// title + artist instead (same engine as ``Search/search(q:title:artist:upc:isrc:filter:limit:offset:)``)
	/// and the best match is returned if relevant enough — ``TrackDetail/searchFallback`` is then `true`.
	///
	/// Returns ``TrackDetail``.
	/// - Parameters:
	///   - isrc: An ISRC, e.g. `"USRC17607839"`.
	///   - title: Track title, fallback when no recording has this ISRC. Needs `artist` too.
	///   - artist: Artist name, fallback when no recording has this ISRC. Needs `title` too.
	case getByIsrc(isrc: String, title: String? = nil, artist: String? = nil)

	public var path: String {
		switch self {
			case .get(let tid):
				return "/api/v1/track/\(tid)"
			case .getByIsrc(let isrc, _, _):
				return "/api/v1/track/isrc/\(isrc)"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .get, .getByIsrc:
				return [.get]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .get:
				return []
			case .getByIsrc(_, let title, let artist):
				var items: [URLQueryItem] = []
				if let title {
					items.append(URLQueryItem(name: "title", value: title))
				}
				if let artist {
					items.append(URLQueryItem(name: "artist", value: artist))
				}
				return items
		}
	}
}
