// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/library/` path.
public enum Library: NafynEndpoint {

	/// Remove a track from the requesting user's own library. If no other user still references the
	/// underlying file, it's deleted too.
	///
	/// Returns ``RemovedWithFileResponse``.
	/// - Parameter id: Media ID.
	case remove(id: String)

	/// Remove a track from a specific user's library. Only that user themselves, or a user with `manageMusic`, may do this.
	///
	/// Returns ``RemovedWithFileResponse``.
	/// - Parameters:
	///   - id: Media ID.
	///   - userId: ID of the user whose library entry is being removed.
	case removeForUser(id: String, userId: String)

	/// Get synced lyrics for a library track, tried across providers (Cider, LRCLIB) in order until one has a match.
	///
	/// Returns ``Lyrics``.
	/// - Parameter id: Media ID.
	case lyrics(id: String)

	/// Stream an owned track's audio file, with HTTP Range support for progressive playback.
	///
	/// Returns raw audio `Data` — send this with ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``.
	/// - Parameters:
	///   - id: Media ID.
	///   - token: Auth token, as a fallback for clients that can't set the Authorization header (e.g. `<audio>` elements).
	///   - range: A standard HTTP byte-range value, e.g. `"bytes=0-1023"`.
	case stream(id: String, token: String? = nil, range: String? = nil)

	/// List every album the requesting user owns at least one track from, aggregated from their library.
	///
	/// Returns `[`` AlbumRow``]`.
	case albums

	/// List every media row across every user's library, with owner usernames. Requires `manageMusic`.
	///
	/// Returns `[`` LibraryMediaEntry``]`.
	case all

	/// List the requesting user's recently played tracks/albums/playlists, most recent first.
	///
	/// Returns `[`` RecentlyPlayedEntry``]`.
	case recentlyPlayed

	/// Record a track/album/playlist as recently played for the requesting user.
	///
	/// Returns ``RecordedResponse``.
	/// - Parameters:
	///   - type: The kind of media being recorded.
	///   - refId: Media ID (track), release-group ID (album), or playlist ID.
	case recordRecentlyPlayed(type: RecentEntryKind, refId: String)

	/// List every track in the requesting user's library.
	///
	/// Returns `[`` MediaRow``]`.
	case tracks

	public var path: String {
		switch self {
			case .remove(let id):
				return "/api/v1/library/\(id)"
			case .removeForUser(let id, let userId):
				return "/api/v1/library/\(id)/\(userId)"
			case .lyrics(let id):
				return "/api/v1/library/\(id)/lyrics"
			case .stream(let id, _, _):
				return "/api/v1/library/\(id)/stream"
			case .albums:
				return "/api/v1/library/albums"
			case .all:
				return "/api/v1/library/all"
			case .recentlyPlayed, .recordRecentlyPlayed:
				return "/api/v1/library/recently-played"
			case .tracks:
				return "/api/v1/library/tracks"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .remove, .removeForUser:
				return [.delete]
			case .lyrics, .stream, .albums, .all, .recentlyPlayed, .tracks:
				return [.get]
			case .recordRecentlyPlayed:
				return [.post]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .stream(_, let token, _):
				guard let token else { return [] }
				return [URLQueryItem(name: "token", value: token)]
			default:
				return []
		}
	}

	public var headers: [String: String] {
		switch self {
			case .stream(_, _, let range):
				guard let range else { return [:] }
				return ["Range": range]
			default:
				return [:]
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .recordRecentlyPlayed(let type, let refId):
				return AnyEncodable(RecordRecentlyPlayedRequest(type: type, refId: refId))
			default:
				return nil
		}
	}
}

struct RecordRecentlyPlayedRequest: Encodable, Sendable {
	let type: RecentEntryKind
	let refId: String
}
