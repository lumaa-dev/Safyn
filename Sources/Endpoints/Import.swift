// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/import` path — importing a playlist from another service.
///
/// The whole list is handed over once; the server resolves every track to a MusicBrainz recording (ISRC first,
/// then title + artist) and requests it in the background, pacing itself. Poll ``get(id:)`` for progress.
public enum Import: NafynEndpoint {

	/// Start importing a playlist. Requires `requestTracks`; at most 1000 tracks, one running import per user
	/// (a second one is a 409).
	///
	/// Returns ``PlaylistImport`` (without ``PlaylistImport/items``).
	/// - Parameters:
	///   - tracks: The playlist's tracks, in order.
	///   - source: Where the list comes from, e.g. `"apple-music"` (informational).
	///   - name: The playlist's name (informational).
	case create(tracks: [ImportTrack], source: String? = nil, name: String? = nil)

	/// One of the requesting user's imports, with every track's outcome in ``PlaylistImport/items``.
	///
	/// Returns ``PlaylistImport``.
	/// - Parameter id: The import's ID.
	case get(id: String)

	/// The requesting user's imports, newest first, without their tracks. Finished imports are kept 30 days. Paginated.
	///
	/// Returns ``PaginatedResponse``<``PlaylistImport``>.
	/// - Parameters:
	///   - page: Page number, 1-indexed. Defaults to `1` server-side when omitted.
	///   - limit: Maximum number of results per page.
	case all(page: Int? = nil, limit: Int? = nil)

	public var path: String {
		switch self {
			case .create, .all:
				return "/api/v1/import"
			case .get(let id):
				return "/api/v1/import/\(id)"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .create:
				return [.post]
			case .get, .all:
				return [.get]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .all(let page, let limit):
				var items: [URLQueryItem] = []
				if let page {
					items.append(URLQueryItem(name: "page", value: String(page)))
				}
				if let limit {
					items.append(URLQueryItem(name: "limit", value: String(limit)))
				}
				return items
			default:
				return []
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .create(let tracks, let source, let name):
				return AnyEncodable(CreateImportRequest(source: source, name: name, tracks: tracks))
			default:
				return nil
		}
	}
}

struct CreateImportRequest: Encodable, Sendable {
	let source: String?
	let name: String?
	let tracks: [ImportTrack]
}
