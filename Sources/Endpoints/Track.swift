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
	/// Returns ``TrackDetail``.
	/// - Parameter isrc: An ISRC, e.g. `"USRC17607839"`.
	case getByIsrc(isrc: String)

	public var path: String {
		switch self {
			case .get(let tid):
				return "/api/v1/track/\(tid)"
			case .getByIsrc(let isrc):
				return "/api/v1/track/isrc/\(isrc)"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .get, .getByIsrc:
				return [.get]
		}
	}
}
