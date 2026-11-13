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
	/// To import a whole playlist, prefer ``Import/create(tracks:albums:source:name:)``.
	///
	/// Returns ``TrackDetail``.
	/// - Parameters:
	///   - isrc: An ISRC, e.g. `"USRC17607839"`; `nil` searches by `title` + `artist` straight away.
	///   - title: Track title, fallback when no recording has this ISRC. Needs `artist` too.
	///   - artist: Artist name, fallback when no recording has this ISRC. Needs `title` too.
	///   - duration: Track length in seconds, as the other service reports it.
	case getByIsrc(isrc: String?, title: String? = nil, artist: String? = nil, duration: Int? = nil)

	/// The 30-second preview of a track the user doesn't own, from Apple's iTunes catalogue, served by Nafyn with
	/// HTTP Range support. The server answers 404 when iTunes has no preview of that recording.
	///
	/// Returns raw audio `Data` (AAC in MP4) — send this with ``NafynServer/sendRaw(_:)``, or build its URL for a
	/// player (with `token`, since a player can't set the Authorization header).
	/// - Parameters:
	///   - tid: MusicBrainz recording ID.
	///   - token: Auth token, for clients that can't set the Authorization header (`AVPlayer`, `<audio>`).
	///   - range: A standard HTTP byte-range value, e.g. `"bytes=0-1023"`.
	case preview(tid: String, token: String? = nil, range: String? = nil)

	/// What the path carries for a `nil` ISRC: a well-formed code with the never-assigned `ZZ` prefix, which
	/// the server skips straight to its title + artist search for.
	static let placeholderISRC = "ZZZZZ0000000"

	public var path: String {
		switch self {
			case .get(let tid):
				return "/api/v1/track/\(tid)"
			case .getByIsrc(let isrc, _, _, _):
				return "/api/v1/track/isrc/\(isrc ?? Self.placeholderISRC)"
			case .preview(let tid, _, _):
				return "/api/v1/track/\(tid)/preview"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .get, .getByIsrc, .preview:
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
			case .preview(_, let token, _):
				guard let token else { return [] }
				return [URLQueryItem(name: "token", value: token)]
		}
	}

	public var headers: [String: String] {
		switch self {
			case .preview(_, _, let range):
				guard let range else { return [:] }
				return ["Range": range]
			default:
				return [:]
		}
	}
}
