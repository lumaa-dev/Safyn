// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/import` path — importing a playlist from another service.
///
/// The whole list is handed over once; the server resolves every track to a MusicBrainz recording (ISRC first,
/// then title + artist) and requests it in the background, pacing itself. Poll ``get(id:)`` for progress.
public enum Import: NafynEndpoint {

	/// Start importing a playlist (tracks) or a collection (albums, requested whole). Tracks require `requestTracks`,
	/// albums `requestAlbums`; at most 1000 items in all, one running import per user (a second one is a 409).
	///
	/// Returns ``PlaylistImport`` (without ``PlaylistImport/items``).
	/// - Parameters:
	///   - tracks: The playlist's tracks, in order.
	///   - albums: Albums to request whole (a record collection), after the tracks.
	///   - source: Where the list comes from, e.g. `"apple-music"`, `"discogs"` (informational).
	///   - name: The playlist's name (informational).
	case create(tracks: [ImportTrack] = [], albums: [ImportAlbum] = [], source: String? = nil, name: String? = nil)

	/// Import the albums of a public Discogs collection: the server reads the collection itself (the `username`
	/// given, else the Discogs username on the user's profile) and starts an album import. Requires
	/// `requestAlbums`. Can take several seconds for a large collection.
	///
	/// Returns ``PlaylistImport`` (without ``PlaylistImport/items``).
	/// - Parameter username: Discogs username; `nil` uses the one on the profile.
	case discogs(username: String? = nil)

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
			case .discogs:
				return "/api/v1/import/discogs"
			case .get(let id):
				return "/api/v1/import/\(id)"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .create, .discogs:
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
			case .create(let tracks, let albums, let source, let name):
				return AnyEncodable(CreateImportRequest(source: source, name: name, tracks: tracks.isEmpty ? nil : tracks, albums: albums.isEmpty ? nil : albums))
			case .discogs(let username):
				return AnyEncodable(DiscogsImportRequest(username: username))
			default:
				return nil
		}
	}
}

struct CreateImportRequest: Encodable, Sendable {
	let source: String?
	let name: String?
	let tracks: [ImportTrack]?
	let albums: [ImportAlbum]?
}

struct DiscogsImportRequest: Encodable, Sendable {
	let username: String?
}
