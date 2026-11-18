// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/search` path.
public enum Search: NafynEndpoint {

	/// Search MusicBrainz for albums, tracks, and/or artists. ``SearchResult/results`` is ONE list of all three
	/// kinds, the most likely answer first and the least likely last. Albums and tracks are normalized, filtered
	/// (Official digital releases only; no Deluxe/Remaster/Live/Remix edition or version unless the query says so,
	/// but a track is still found on a Deluxe album) and ranked; at most one result has ``MediaInfo/bestResult`` set.
	///
	/// Returns ``SearchResult``.
	/// - Parameters:
	///   - q: Free-text query. `Artist - Title` is tried in both orders.
	///   - title: Song or album title. Takes precedence over the title part of `q`.
	///   - artist: Artist name (any language: aliases are matched).
	///   - upc: UPC-A/EAN-13 barcode of the album. Needs `title` and `artist` too. Invalid codes are ignored.
	///   - isrc: ISRC of the track. Needs `title` and `artist` too. Invalid codes are ignored.
	///   - filter: Restrict results to one result type. Defaults to `.all` server-side when omitted.
	///   - limit: Maximum number of results per category.
	///   - offset: Pagination offset. Defaults to `0` server-side when omitted.
	case search(q: String, title: String? = nil, artist: String? = nil, upc: String? = nil, isrc: String? = nil, filter: SearchFilter? = nil, limit: Double? = nil, offset: Double? = nil)

	public var path: String {
		switch self {
			case .search:
				return "/api/v1/search"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		[.get]
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .search(let q, let title, let artist, let upc, let isrc, let filter, let limit, let offset):
				var items = [URLQueryItem(name: "q", value: q)]
				if let title {
					items.append(URLQueryItem(name: "title", value: title))
				}
				if let artist {
					items.append(URLQueryItem(name: "artist", value: artist))
				}
				if let upc {
					items.append(URLQueryItem(name: "upc", value: upc))
				}
				if let isrc {
					items.append(URLQueryItem(name: "isrc", value: isrc))
				}
				if let filter {
					items.append(URLQueryItem(name: "filter", value: filter.rawValue))
				}
				if let limit {
					items.append(URLQueryItem(name: "limit", value: String(limit)))
				}
				if let offset {
					items.append(URLQueryItem(name: "offset", value: String(offset)))
				}
				return items
		}
	}
}
