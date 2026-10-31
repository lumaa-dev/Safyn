// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/artist/` path.
public enum Artist: NafynEndpoint {

	/// Get artist details: name, Last.fm bio/image (if `LASTFM_API_KEY` is configured), and their
	/// discography from MusicBrainz with per-album library status for the requesting user.
	///
	/// Returns ``ArtistDetail``.
	/// - Parameter aid: MusicBrainz artist ID.
	case get(aid: String)

	/// Get an artist's picture: the Last.fm profile photo MusicBrainz links to the artist, else TheAudioDB,
	/// then Last.fm.
	///
	/// Returns ``ArtistImageResponse``, whose ``ArtistImageResponse/image`` is `nil` when none has one.
	/// A 429 means too many lookups; a 503 means MusicBrainz is unavailable.
	/// - Parameter aid: MusicBrainz artist ID.
	case image(aid: String)

	public var path: String {
		switch self {
			case .get(let aid):
				return "/api/v1/artist/\(aid)"
			case .image(let aid):
				return "/api/v1/artist/\(aid)/image"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .get, .image:
				return [.get]
		}
	}
}
