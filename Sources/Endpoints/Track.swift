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
	/// When several recordings share the ISRC, the one whose title, artist and length agree is returned. When no
	/// recording has this ISRC (or it is `nil`) and both `title` and `artist` are given, the track is searched by
	/// title + artist instead (same engine as ``Search/search(q:title:artist:upc:isrc:filter:limit:offset:)``)
	/// and the best match is returned if relevant enough — or, with `duration`, if its length agrees.
	/// ``TrackDetail/searchFallback`` is then `true`.
	///
	/// To import a whole playlist, prefer ``Import/create(tracks:source:name:)``.
	///
	/// Returns ``TrackDetail``.
	/// - Parameters:
	///   - isrc: An ISRC, e.g. `"USRC17607839"`; `nil` searches by `title` + `artist` straight away.
	///   - title: Track title, fallback when no recording has this ISRC. Needs `artist` too.
	///   - artist: Artist name, fallback when no recording has this ISRC. Needs `title` too.
	///   - duration: Track length in seconds, as the other service reports it.
	case getByIsrc(isrc: String?, title: String? = nil, artist: String? = nil, duration: Int? = nil)

	/// What the path carries for a `nil` ISRC: a well-formed code with the never-assigned `ZZ` prefix, which
	/// the server skips straight to its title + artist search for.
	static let placeholderISRC = "ZZZZZ0000000"

	public var path: String {
		switch self {
			case .get(let tid):
				return "/api/v1/track/\(tid)"
			case .getByIsrc(let isrc, _, _, _):
				return "/api/v1/track/isrc/\(isrc ?? Self.placeholderISRC)"
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
			case .getByIsrc(_, let title, let artist, let duration):
				var items: [URLQueryItem] = []
				if let title {
					items.append(URLQueryItem(name: "title", value: title))
				}
				if let artist {
					items.append(URLQueryItem(name: "artist", value: artist))
				}
				if let duration {
					items.append(URLQueryItem(name: "duration", value: String(duration)))
				}
				return items
		}
	}
}
