// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/pins` path — pinning albums, playlists and tracks.
public enum Pins: NafynEndpoint {

	/// List the requesting user's pinned albums, playlists and tracks, newest pin first.
	///
	/// A pin whose target is gone (or no longer visible to the caller) is dropped.
	///
	/// Returns `[`` PinnedItem``]`.
	case list

	/// Pin an album, playlist or track. Idempotent.
	///
	/// The caller must be able to see the target: a track or album in their library, a playlist they
	/// own, were invited to, or that is public. A 404 means nothing like that is visible to the caller.
	///
	/// Returns ``PinResponse``.
	/// - Parameters:
	///   - kind: Whether `refId` is an album, a playlist or a track.
	///   - refId: Media ID (track), release-group MBID (album) or playlist ID.
	case pin(kind: PinKind, refId: String)

	/// Unpin an album, playlist or track. Idempotent.
	///
	/// Returns ``PinResponse``.
	/// - Parameters:
	///   - kind: Whether `refId` is an album, a playlist or a track.
	///   - refId: Media ID (track), release-group MBID (album) or playlist ID.
	case unpin(kind: PinKind, refId: String)

	public var path: String {
		switch self {
			case .list, .pin, .unpin:
				return "/api/v1/pins"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .list:
				return [.get]
			case .pin:
				return [.post]
			case .unpin:
				return [.delete]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .unpin(let kind, let refId):
				return [
					URLQueryItem(name: "kind", value: kind.rawValue),
					URLQueryItem(name: "refId", value: refId)
				]
			default:
				return []
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .pin(let kind, let refId):
				return AnyEncodable(PinRequest(kind: kind, refId: refId))
			default:
				return nil
		}
	}
}

struct PinRequest: Encodable, Sendable {
	let kind: PinKind
	let refId: String
}
