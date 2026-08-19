// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/search` path.
public enum Search: NafynEndpoint {

	/// Search MusicBrainz for albums, tracks, and/or artists.
	///
	/// Returns ``SearchResult``.
	/// - Parameters:
	///   - q: The search query.
	///   - filter: Restrict results to one result type. Defaults to `.all` server-side when omitted.
	///   - limit: Maximum number of results per category.
	///   - offset: Pagination offset. Defaults to `0` server-side when omitted.
	case search(q: String, filter: SearchFilter? = nil, limit: Double? = nil, offset: Double? = nil)

	public var path: String {
		"/api/v1/search"
	}

	public var methods: [NafynServer.HTTPMethod] {
		[.get]
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .search(let q, let filter, let limit, let offset):
				var items = [URLQueryItem(name: "q", value: q)]
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
