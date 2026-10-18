// Made by Lumaa

import Foundation

/// One song metadata provider and whether it's enabled on this server, from
/// `Search.metadataProviders`. Keyed providers are disabled when their key isn't configured.
public struct MetadataProvider: Codable, Sendable, Hashable, Identifiable {
	/// The provider's ID, e.g. `"deezer"`.
	public let id: String

	/// The provider's display name.
	public let name: String

	/// Whether the provider is enabled on this server.
	public let enabled: Bool?

	/// Whether the provider answers text searches.
	public let search: Bool?

	/// Whether the provider answers ISRC lookups.
	public let isrc: Bool?

	/// Whether the provider answers platform ID lookups.
	public let idLookup: Bool?

	public init(id: String, name: String, enabled: Bool?, search: Bool?, isrc: Bool?, idLookup: Bool?) {
		self.id = id
		self.name = name
		self.enabled = enabled
		self.search = search
		self.isrc = isrc
		self.idLookup = idLookup
	}
}

/// Whether a ``MetadataSearchResult`` or ``MetadataResolveResponse`` describes a track or an album —
/// deliberately separate from ``AlbumKind``/``MediaKind`` since metadata lookups can never surface an EP.
public enum MetadataKind: String, Codable, Sendable, Hashable {
	case track
	case album
}

/// A song metadata provider a `Search.searchMetadata(q:limit:)` result came from.
public enum MetadataProviderKind: String, Codable, Sendable, Hashable {
	case deezer
	case itunes
	case reccobeats
	case discogs
	case theaudiodb
	case genius
}

/// The response of `Search.searchMetadata(q:limit:)`.
public struct MetadataSearchResponse: Codable, Sendable, Hashable {
	/// How `q` was understood (`{ type: "text" | "isrc" | "id", ... }`).
	public let query: JSONValue

	/// The MusicBrainz recording the ISRC/ID lookup resolved to. Always `nil` for text searches.
	public let musicbrainzId: String?

	/// The individual provider results.
	public let results: [MetadataSearchResult]

	/// The providers enabled on this server.
	public let providers: [String]

	public init(query: JSONValue, musicbrainzId: String?, results: [MetadataSearchResult], providers: [String]) {
		self.query = query
		self.musicbrainzId = musicbrainzId
		self.results = results
		self.providers = providers
	}
}

/// One result of `Search.searchMetadata(q:limit:)`.
public struct MetadataSearchResult: Codable, Sendable, Hashable {
	/// The provider this result came from.
	public let provider: MetadataProviderKind

	/// Platform ID to look this record up again with, via `Search.resolveMetadata(ref:)`.
	public let ref: String

	public let kind: MetadataKind

	public let title: String

	public let artists: [String]

	public let album: String?

	/// Duration, in seconds.
	public let duration: Double?

	public let isrc: String?

	/// `YYYY`, `YYYY-MM` or `YYYY-MM-DD`.
	public let releaseDate: String?

	public let genres: [String]?

	/// Artwork URLs, largest first.
	public let artwork: [String]?

	public let previews: [String]?

	public let url: String?

	public let musicbrainzId: String?

	/// Provider-specific extras.
	public let extra: JSONValue?

	public init(provider: MetadataProviderKind, ref: String, kind: MetadataKind, title: String, artists: [String], album: String?, duration: Double?, isrc: String?, releaseDate: String?, genres: [String]?, artwork: [String]?, previews: [String]?, url: String?, musicbrainzId: String?, extra: JSONValue?) {
		self.provider = provider
		self.ref = ref
		self.kind = kind
		self.title = title
		self.artists = artists
		self.album = album
		self.duration = duration
		self.isrc = isrc
		self.releaseDate = releaseDate
		self.genres = genres
		self.artwork = artwork
		self.previews = previews
		self.url = url
		self.musicbrainzId = musicbrainzId
		self.extra = extra
	}
}

/// The response of `Search.resolveMetadata(ref:)` — the MusicBrainz entity a search result's `ref`
/// opens as in Nafyn (`/t/{id}` for a track, `/a/{id}` for an album).
public struct MetadataResolveResponse: Codable, Sendable, Hashable {
	public let kind: MetadataKind

	public let musicbrainzId: String

	public init(kind: MetadataKind, musicbrainzId: String) {
		self.kind = kind
		self.musicbrainzId = musicbrainzId
	}
}
