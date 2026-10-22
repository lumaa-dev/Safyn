// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/search` and `/api/v1/metadata` paths.
public enum Search: NafynEndpoint {

	/// Search MusicBrainz for albums, tracks, and/or artists. Albums and tracks are normalized, filtered
	/// (Official digital releases only) and ranked; results with a front cover come first, and at most one
	/// result has ``MediaInfo/bestResult`` set.
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

	/// List the song metadata providers (Deezer, iTunes, ReccoBeats, Discogs, TheAudioDB, Genius) and
	/// whether each is enabled on this server.
	///
	/// Returns `[`` MetadataProvider``]`.
	case metadataProviders

	/// Look up song metadata across the enabled providers. `q` is free text (`Artist - Title` enables
	/// fielded searches), an ISRC, a platform ID (`deezer:track:3135556`, `itunes:1440857781`,
	/// `spotify:track:<id>`, `discogs:release:249504`, `genius:song:378195`, `theaudiodb:track:32724184`)
	/// or a supported Deezer/Apple Music/Spotify/Discogs/Genius/TheAudioDB link.
	///
	/// Returns ``MetadataSearchResponse``.
	/// - Parameters:
	///   - q: Text, ISRC, platform ID, or link.
	///   - limit: Maximum number of results.
	case searchMetadata(q: String, limit: Double? = nil)

	/// Resolve one ``MetadataSearchResult/ref`` to the MusicBrainz recording or release-group it opens
	/// as in Nafyn. Only needed for text-search hits — ISRC/ID lookups already resolve this up front via
	/// ``searchMetadata(q:limit:)``.
	///
	/// Returns ``MetadataResolveResponse``.
	/// - Parameter ref: A result's ``MetadataSearchResult/ref``.
	case resolveMetadata(ref: String)

	public var path: String {
		switch self {
			case .search:
				return "/api/v1/search"
			case .metadataProviders:
				return "/api/v1/metadata/providers"
			case .searchMetadata:
				return "/api/v1/metadata/search"
			case .resolveMetadata:
				return "/api/v1/metadata/resolve"
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
			case .metadataProviders:
				return []
			case .searchMetadata(let q, let limit):
				var items = [URLQueryItem(name: "q", value: q)]
				if let limit {
					items.append(URLQueryItem(name: "limit", value: String(limit)))
				}
				return items
			case .resolveMetadata(let ref):
				return [URLQueryItem(name: "ref", value: ref)]
		}
	}
}
